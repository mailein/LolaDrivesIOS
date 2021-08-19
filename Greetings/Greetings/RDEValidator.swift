//
//  RDEValidator.swift
//  Greetings
//
//  Created by Mei Chen on 05.08.21.
//

import Foundation
import pcdfcore
//import Files
//
//let projectRepo = "\(Folder.home.path)/Developer/masterThesisLab/RustInIOS/Greetings"

let VERBOSITY_MODE = false

class RDEValidator {
    // Last event time in seconds.
    private var time: Double = 0.0
    
    var isPaused = false

    // The sensor profile of the car which is determined.
    var rdeProfile: [OBDCommand] = []
    private var fuelType = ""
    private var fuelRateSupported = false
    private var faeSupported = false

    enum RDE_RTLOLA_INPUT_QUANTITIES {
        case  VELOCITY
        case     ALTITUDE
        case     TEMPERATURE
        case     NOX_PPM
        case    MASS_AIR_FLOW
        case    FUEL_RATE
        case   FUEL_AIR_EQUIVALENCE
            }

    
    // Latest relevant values from OBD- and GPSSource.
    private var inputs: [RDE_RTLOLA_INPUT_QUANTITIES: Double?] =
        [.VELOCITY : nil,
         .ALTITUDE : nil,
         .TEMPERATURE : nil,
         .NOX_PPM : nil,
         .MASS_AIR_FLOW : nil,
         .FUEL_RATE : nil,
         .FUEL_AIR_EQUIVALENCE : nil]
    
    /*
        Initial data is complete if we received values for all the sensors in the determined sensor profile and GPS data.
        If complete, we can start communicating with the RTLola engine.
     */
    private var initialDataComplete: Bool {
        var countAvailable = 0
        for pair in inputs {
            if (pair.value != nil) {
                countAvailable += 1
            }
        }
        return countAvailable == rdeProfile.count + 1
    }

    let rustGreetings = RustGreetings()

    func monitorOffline(data: [PCDFEvent]) throws -> [Double] { //todo func names to decap. letter
        if(data.isEmpty){
            throw RdeError.IllegalState
        }
        
        let initialEvents = data[0..<13]
        
        // Check initial events for supported PIDs, fuel type, etc.
        var suppPids : [Int] = []
        for event in initialEvents {
            if(event.type == pcdfcore.EventType.obdResponse){
                // Get Supported PIDs
                let iEvent = (event as! pcdfcore.OBDEvent).toIntermediate()
                switch iEvent{
                    case is SupportedPidsEvent:
                        suppPids.append(contentsOf: (iEvent as! SupportedPidsEvent).supportedPids as NSArray as! [Int])
                    // Get Fueltype
                    case is FuelTypeEvent:
                        fuelType = (iEvent as! FuelTypeEvent).fueltype
                    default: break
                }
            }
        }
        
        if(suppPids.isEmpty || fuelType.isEmpty){
            throw RdeError.IllegalState
        }
        
        // Check Supported PIDs
        let supported = checkSupportedPids(supportedPids: suppPids, fuelType: fuelType)
        if(!supported){
            throw RdeError.IllegalState
        }
        
        // Setup RTLola Monitor
        rustGreetings.initmonitor(s: specFile(filename: "rde-lola-test-drive-spec-no-percentile1.lola"))
        
        var result : [Double] = []
        for event in data {
            let lolaResult = collectData(event: event) //todo await, swift5.5
            if(!lolaResult.isEmpty){
                result = lolaResult
            }
        }
        return result
    }

    private func collectData(event: PCDFEvent) -> [Double] { //todo async, swift5.5
        if(event.type == pcdfcore.EventType.gps){
            inputs[.ALTITUDE] = (event as! GPSEvent).altitude
        }else if(event.type == pcdfcore.EventType.obdResponse){
            // Reduces the event if possible (e.g. NOx or FuelRate events) using the PCDFCore library.
            //todo ignore sensorreducer for now
            if(event is SpeedEvent){
                inputs[.VELOCITY] = Double((event as! SpeedEvent).speed)
            }
            if(event is AmbientAirTemperatureEvent){
                inputs[.TEMPERATURE] = Double((event as! AmbientAirTemperatureEvent).temperature) + 273.15  // C -> K
            }
            if(event is MAFAirFlowRateEvent){
                inputs[.MASS_AIR_FLOW] = (event as! MAFAirFlowRateEvent).rate
            }
            if(event is MAFSensorEvent){
                inputs[.MASS_AIR_FLOW] = (event as! MAFSensorEvent).mafSensorA
            }
            if(event is NOXSensorEvent){
                inputs[.NOX_PPM] = Double((event as! NOXSensorEvent).sensor1_2)
            }
            if(event is FuelRateReducedEvent){
                inputs[.FUEL_RATE] = (event as! FuelRateReducedEvent).fuelRate
            }
            if(event is FuelAirEquivalenceRatioEvent){
                inputs[.FUEL_AIR_EQUIVALENCE] = (event as! FuelAirEquivalenceRatioEvent).ratio
            }
        }
        
        // Check whether we have received data for every input needed and that we are not paused (bluetooth disconnected).
        if (initialDataComplete && !isPaused) {
            var inputsToSend : [Double] = []
            for input in inputs.values {
                if(input != nil){
                    inputsToSend.append(input!)
                }
            }
            // Prevent time from going backwards
            time = max(time, Double(event.timestamp) / 1_000_000_000.0)
            inputsToSend.append(time)
            
            if(VERBOSITY_MODE){
                print("Sending(Lola): \(inputsToSend)")
            }
            // Send latest received inputs to the RTLola monitor to update our streams, in return we receive an array of
            // values of selected OutputStreams (see: lola-rust-bridge) which we send to the outputchannel (e.g. the UI).
            let lolaResult = rustGreetings.sendevent(inputs: &inputsToSend, len_in: UInt32(inputsToSend.count))
            if(VERBOSITY_MODE){
                print("Receiving(Lola): \(inputsToSend)")
            }
            // The result may be empty, since we are referring to periodic streams (1 Hz). So we receive updated results
            // every full second.
            if (!lolaResult.isEmpty) {
//                outputChannel.offer(lolaResult)//todo
            }
            return lolaResult
        }
        return []
    }
    
    private func checkSupportedPids(supportedPids: [Int], fuelType: String) -> Bool {
        // If the car is not a diesel or gasoline, the RDE test is not possible since there are no corresponding
        // specifications.
        if(fuelType != "Diesel" && fuelType != "Gasoline"){
            print("Incompatible for RDE: Fuel type unknown or invalid \(fuelType)")
            return false
        }
        
        // Velocity information to determine acceleration, distance travelled and to calculate the driving dynamics.
        if (supportedPids.contains(0x0D)) {
            rdeProfile.append(OBDCommand.speed)
        } else {
            print("Incompatible for RDE: Speed data not provided by the car.")
            return false
        }
        
        // Ambient air temperature for checking compliance with the environmental constraints.
        if (supportedPids.contains(0x46)) {
            rdeProfile.append(OBDCommand.ambientAirTemperature)
        } else {
            print("Incompatible for RDE: Ambient air temperature not provided by the car.")
            return false
        }
        
        // NOx sensor(s) to check for violation of the EU regulations.
        if(supportedPids.contains(0x83)){
            rdeProfile.append(OBDCommand.noxSensor)
        }else if(supportedPids.contains(0xA1)){
            rdeProfile.append(OBDCommand.noxSensorCorrected)
        }else if(supportedPids.contains(0xA7)){
            rdeProfile.append(OBDCommand.noxSensorAlternative)
        }else if(supportedPids.contains(0xA8)){
            rdeProfile.append(OBDCommand.noxSensorCorrectedAlternative)
        }else {
            print("Incompatible for RDE: NOx sensor not provided by the car.")
            return false
        }
        
        // Fuelrate sensors for calculation of the exhaust mass flow. Can be replaced through MAF.
        // TODO: ask Maxi for the EMF PID
        if(supportedPids.contains(0x5E)) {
            rdeProfile.append(OBDCommand.engineFuelRate)
            fuelRateSupported = true
        }else if(supportedPids.contains(0x9D)) {
            rdeProfile.append(OBDCommand.engineFuelRateMulti)
            fuelRateSupported = true
        } else {
            print("RDE: Fuel rate not provided by the car.")
            fuelRateSupported = false
        }

        // Mass air flow rate for the calcuation of the exhaust mass flow.
        if(supportedPids.contains(0x10)) {
            rdeProfile.append(OBDCommand.mafAirFlowRate)
        }else if(supportedPids.contains(0x66)) {
            rdeProfile.append(OBDCommand.mafAirFlowRateSensor)
        } else {
            print("Incompatible for RDE: Mass air flow not provided by the car.")
            return false
        }

        // Fuel air equivalence ratio for a more precise calculation of the fuel rate with MAF.
        if (supportedPids.contains(0x44) && !fuelRateSupported) {
            rdeProfile.append(OBDCommand.fuelAirEquivalenceRatio)
            faeSupported = true
        } else {
            print("RDE: Fuel air equivalence ratio not provided by the car.")
            faeSupported = false
        }

        print("Car compatible for RDE tests.")
        
        return true
    }

    enum RdeError : Error {
        case IllegalState
    }
    
    let header = "//////////////////////////////////////////////////////////\n" +
        "// Test Parameters                                      //\n" +
        "//////////////////////////////////////////////////////////\n" +
        "input v: Float64           // vehicle speed in [km/h]\n" +
        "output vp : Float64 @1Hz :=  v.hold().defaults(to: 0.0) //vehcile speed periodic stream\n" +
        "\n" +
        "input altitude: Float64     // above see level in [m]\n" +
        "output altitudep : Float64 @1Hz := altitude.hold().defaults(to: 0.0) //altitude periodic stream\n" +
        "\n" +
        "input temperature: Float64 // ambient temperature in [K]\n" +
        "output temperaturep: Float64 @1Hz := temperature.hold().defaults(to: 280.0) //temperature periodic " +
        "stream\n" +
        "\n" +
        "// we only do this exemplary for NOx and CO2\n" +
        "input nox_ppm: Float64  // in [ppm]\n" +
        "output nox_ppmp: Float64 @1Hz := nox_ppm.hold().defaults(to: 0.0) //nox periodic stream \n" +
        "\ninput mass_air_flow : Float64 \n"

}
