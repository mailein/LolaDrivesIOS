//
//  RDEValidator.swift
//  Greetings
//
//  Created by Mei Chen on 05.08.21.
//

import Foundation
import pcdfcore

let VERBOSITY_MODE = false

class RDEValidator {
    let activity: MainActivity
    
    init(Activity : MainActivity){
        activity = Activity
    }
    
    // Last event time in seconds.
    private var time: Double = 0.0
    
    var isPaused = false

    // The sensor profile of the car which is determined.
    var rdeProfile: [OBDCommand] = []
    private var fuelType = ""
    private var fuelRateSupported = false
    private var faeSupported = false

    
    // Second OBDSource used for determination of the sensor profile.
        private let source = OBDSource( //todo
            activity.mBluetoothSocket?.inputStream,
            activity.mBluetoothSocket?.outputStream,
            Channel(10000),
            [],
            activity.mUUID
        )

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
        let supported = checkSupportedPids(suppPids: suppPids, fuelType: fuelType)
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
            if(event is NOXSensorEvent){
                inputs[.NOX_PPM] = Double((event as! NOXSensorEvent).sensor1_2)
                
            }
        }
    }

    func specFile(filename: String) -> String{
        let file = filename //this is the file. we will write to and read from it
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let fileURL = dir.appendingPathComponent(file)
            //reading
            do {
                print(dir)
                return try String(contentsOf: fileURL, encoding: .utf8)
            }
            catch {
                //I put the spec file in this dir
                print(dir)
                return "a"
            }
        }
        return "b"
    }
    
    private func checkSupportedPids(suppPids: [Int], fuelType: String) -> Bool {
        
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
