import Foundation
import pcdfcore

class RDEValidator {
    let VERBOSITY_MODE = true
    
    // Last event time in seconds.
    private var time: Double = 0.0
    
    var isPaused = false //TODO: true if bluetooth is disconnected

    // The sensor profile of the car which is determined.
    var rdeProfile: [OBDCommand] = []
    private var fuelType = ""
    private var fuelRateSupported = false
    private var faeSupported = false
    
    private var specBody: String
    private var specHeader: String
    private var specFuelRateInput: String
    private var specFuelRateToCo2Diesel: String
    private var specFuelRateToEMFDiesel: String
    private var specFuelRateToCo2Gasoline: String
    private var specFuelRateToEMFGasoline: String
    private var specMAFToFuelRateDieselFAE: String
    private var specMAFToFuelRateDiesel: String
    private var specMAFToFuelRateGasolineFAE: String
    private var specMAFToFuelRateGasoline: String
    
    enum RDE_RTLOLA_INPUT_QUANTITIES { 
        case VELOCITY
        case ALTITUDE
        case TEMPERATURE
        case NOX_PPM
        case MASS_AIR_FLOW
        case FUEL_RATE
        case FUEL_AIR_EQUIVALENCE
    }

    enum RdeError : Error {
        case IllegalState
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
    
    init() {
        //load spec file
        specBody = specFile(filename: "spec_body.lola")
        specHeader = specFile(filename: "spec_header.lola")
        specFuelRateInput = specFile(filename: "spec_fuel_rate_input.lola")
        specFuelRateToCo2Diesel = specFile(filename: "spec_fuel_rate_to_co2_diesel.lola")
        specFuelRateToEMFDiesel = specFile(filename: "spec_fuel_rate_to_emf_diesel.spec")
        specFuelRateToCo2Gasoline = specFile(filename: "spec_fuelrate_to_co2_gasoline.lola")
        specFuelRateToEMFGasoline = specFile(filename: "spec_fuelrate_to_emf_gasoline.lola")
        specMAFToFuelRateDieselFAE = specFile(filename: "spec_maf_to_fuel_rate_diesel_fae.lola")
        specMAFToFuelRateDiesel = specFile(filename: "spec_maf_to_fuel_rate_diesel.lola")
        specMAFToFuelRateGasolineFAE = specFile(filename: "spec_maf_to_fuel_rate_gasoline_fae.lola")
        specMAFToFuelRateGasoline = specFile(filename: "spec_maf_to_fuel_rate_gasoline.lola")
    }

    // data are all the events from a ppcdf file
    func monitorOffline(data: [PCDFEvent]) throws -> [Double] { //todo func names to decap. letter
        if(data.isEmpty){
            throw RdeError.IllegalState
        }
        
        let initialEvents = data[0..<13]//TODO: why 13? maybe it's large enough so that all supportedPids-&FuelType-Event are included
        
        // Check initial events for supported PIDs, fuel type, etc.
        var suppPids : [Int] = []
        for event in initialEvents {
            if(event.type == pcdfcore.EventType.obdResponse){
                // Get Supported PIDs
                let iEvent = (event as! OBDEvent).toIntermediate()
                switch iEvent{
                    case is SupportedPidsEvent:
                        suppPids.append(contentsOf: (iEvent as! SupportedPidsEvent).supportedPids as NSArray as! [Int])
                    // Get Fueltype
                    case is FuelTypeEvent:
                        fuelType = (iEvent as! FuelTypeEvent).fueltype
                    default:
                        print("event is not suppPids or fuelType: \(iEvent)")
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
        
        let spec = buildSpec()
        // Setup RTLola Monitor
        rustGreetings.initmonitor(s: spec)
        
        var result : [Double] = []
        for event in data {
            let lolaResult = collectData(event: event) //todo await, swift5.5
            if(!lolaResult.isEmpty){
                result = lolaResult
            }
        }
        
        print("Result: \(result)")
        return result
    }

    private func collectData(event: PCDFEvent) -> [Double] { //todo async, swift5.5
        if(event.type == pcdfcore.EventType.gps){
            inputs[.ALTITUDE] = (event as! GPSEvent).altitude
        }else if(event.type == pcdfcore.EventType.obdResponse){
            // Reduces the event if possible (e.g. NOx or FuelRate events) using the PCDFCore library.
            let iEvent = (event as! OBDEvent).toIntermediate()
            let sensorReducer = MultiSensorReducer()
            let rEvent = sensorReducer.reduce(event: iEvent)
            
            collectOBDEvent(event: rEvent as! OBDIntermediateEvent)
        }
        
        // Check whether we have received data for every input needed and that we are not paused (bluetooth disconnected).
        if (initialDataComplete && !isPaused) {//TODO: actually no need for bluetooth to be active here
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
            // Send latest received inputs to the RTLola monitor to update our streams, in return we receive an array of values of selected OutputStreams (see: lola-rust-bridge) which we send to the outputchannel (e.g. the UI).
            let lolaResult = rustGreetings.sendevent(inputs: &inputsToSend, len_in: UInt32(inputsToSend.count))
            if(VERBOSITY_MODE){
                print("Receiving(Lola): \(lolaResult)")
            }
            // The result may be empty, since we are referring to periodic streams (1 Hz). So we receive updated results every full second.
//            if (!lolaResult.isEmpty) {
//                outputChannel.offer(lolaResult)
//            }
            return Array(lolaResult.values)
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

    private func buildSpec() -> String {
        var s = ""
        s.append(specHeader)

        if fuelRateSupported {
            s.append(specFuelRateInput)
        } else {
            if fuelType == "Diesel" {
                if (faeSupported) {
                    s.append(specMAFToFuelRateDieselFAE)
                } else {
                    s.append(specMAFToFuelRateDiesel)
                }
            }
            if fuelType == "Gasoline" {
                if (faeSupported) {
                    s.append(specMAFToFuelRateGasolineFAE)
                } else {
                    s.append(specMAFToFuelRateGasoline)
                }
            }
        }
        if fuelType == "Diesel" {
            s.append(specFuelRateToCo2Diesel)
            s.append(specFuelRateToEMFDiesel)
        }
        if fuelType == "Gasoline"{
            s.append(specFuelRateToCo2Gasoline)
            s.append(specFuelRateToEMFGasoline)
        }
        s.append(specBody)

        return s
    }
    
    private func collectOBDEvent(event: OBDIntermediateEvent) {
        if(event is SpeedEvent){
            inputs[.VELOCITY] = Double((event as! SpeedEvent).speed)
        }
        if(event is AmbientAirTemperatureEvent){
            inputs[.TEMPERATURE] = Double((event as! AmbientAirTemperatureEvent).temperature) + 273  // C -> K
        }
        if(event is MAFAirFlowRateEvent){
            inputs[.MASS_AIR_FLOW] = (event as! MAFAirFlowRateEvent).rate
        }
        if(event is MAFSensorEvent){
            inputs[.MASS_AIR_FLOW] = (event as! MAFSensorEvent).mafSensorA
        }
        if(event is NOXReducedEvent){//after reduce
            inputs[.NOX_PPM] = Double((event as! NOXReducedEvent).nox_ppm)
        }
        if(event is FuelRateReducedEvent){//after reduce
            inputs[.FUEL_RATE] = (event as! FuelRateReducedEvent).fuelRate
        }
        if(event is FuelAirEquivalenceRatioEvent){
            inputs[.FUEL_AIR_EQUIVALENCE] = (event as! FuelAirEquivalenceRatioEvent).ratio
        }
    }
}
