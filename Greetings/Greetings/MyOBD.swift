import Foundation
import LTSupportAutomotive
import CoreLocation
import SwiftUI
import pcdfcore

class MyOBD: ObservableObject{
    // OBD
    var _serviceUUIDs : [CBUUID]
    var _pids : [LTOBD2Command]
    var _transporter : LTBTLESerialTransporter
    var _obd2Adapter : LTOBD2Adapter?
    var supportedPids: [Int] = [] //pid# in decimal
    var rdeProfile: [CommandItem] = [] // The sensor profile of the car which is determined.
    var fuelRateSupported: Bool = false
    var faeSupported: Bool = false
    let supportedPidCommands: [LTOBD2PID] = ProfileCommands.supportedCommands.map{$0.obdCommand}
    let fuelType = ProfileCommands.commands.getByPid(pid: "51")!.obdCommand
    
    // LOLA
    let rustGreetings = RustGreetings()
//    let fileContent = specFile(filename: "rde-lola-test-drive-spec-no-percentile1.lola")//even if it's in a folder, no need to add folder name
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
    
    @Published var mySpeed : String = ""
    @Published var myAltitude : String = ""
    @Published var myTemp : String = ""
    @Published var myNox: String = ""
    @Published var myFuelRate: String = ""
    @Published var myMAFRate: String = ""
    
    @Published var myAirFuelEqvRatio: String = ""
    @Published var myCoolantTemp: String = ""
    @Published var myRPM: String = ""
    @Published var myIntakeTemp: String = ""
    @Published var myMAFRateSensor: String = ""
    @Published var myOxygenSensor1: String = ""
    @Published var myCommandedEgr: String = ""
    @Published var myFuelTankLevelInput: String = ""
    @Published var myCatalystTemp11: String = ""
    @Published var myCatalystTemp12: String = ""
    @Published var myCatalystTemp21: String = ""
    @Published var myCatalystTemp22: String = ""
    @Published var myMaxValueFuelAirEqvRatio: String = ""
    @Published var myMaxValueOxygenSensorVoltage: String = ""
    @Published var myMaxValueOxygenSensorCurrent: String = ""
    @Published var myMaxValueIntakeMAP: String = ""
    @Published var myMaxAirFlowRate: String = ""
    @Published var myFuelType: String = ""
    @Published var myEngineOilTemp: String = ""
    @Published var myIntakeAirTempSensor: String = ""
    @Published var myNoxCorrected: String = ""
    @Published var myNoxAlternative: String = ""
    @Published var myNoxCorrectedAlternative: String = ""
    @Published var myPmSensor: String = ""
    @Published var myEngineFuelRateMulti: String = ""
    @Published var myEngineExhaustFlowRate: String = ""
    @Published var myEgrError: String = ""
    
    var startTime: Date? = nil
    @ObservedObject var locationHelper = LocationHelper()
    
    //RTLola outputs
    var outputValues : [Double]
    
    //ppcdf
    var events: [pcdfcore.PCDFEvent]
    
    //UI
    var isConnected: Bool
    //if non-empty, use selectedProfile, otherwise use rdeProfile from buildSpec()
    var selectedCommands: [CommandItem]
    var connectedAdapterName: String = ""
    
    init(){
        _serviceUUIDs = []
        _pids = []
        _transporter = LTBTLESerialTransporter()
        outputValues = [Double](repeating: 0, count: 19)
        events = []
        isConnected = false
        selectedCommands = []
        
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
    
    public func viewDidLoad () -> () {
        let ma : [CBUUID] = [CBUUID.init(string: "FFF0"), CBUUID.init(string: "FFE0"), CBUUID.init(string: "BEEF"), CBUUID.init(string: "E7810A71-73AE-499D-8C15-FAA9AEF0C3F2")]
        _serviceUUIDs = ma
        
        //use notificationcenter, only call updateSensorData() when adapter status is Discovering / Connected
        NotificationCenter.default.addObserver(self, selector: #selector(onAdapterChangedState), name: Notification.Name(LTOBD2AdapterDidUpdateState), object: nil)
        
        self.connect()
    }
    
    private func connect () -> () {
        _transporter = LTBTLESerialTransporter.init(identifier: nil, serviceUUIDs: _serviceUUIDs)
        //The closure is called after transporter has connected! So updateSensorData() should be called inside the closure after adapter connects; emmmm, no need, because when the state changed to connected, updateSensorData() will be called
        _transporter.connect{(inputStream : InputStream?, outputStream : OutputStream?) -> () in
            if((inputStream == nil)){
                print("Could not connect to OBD2 adapter")
                return;
            }
            self._obd2Adapter = LTOBD2AdapterELM327.init(inputStream: inputStream!, outputStream: outputStream!)
            self._obd2Adapter!.connect()
            print("adapter init and connected")
            self.isConnected = true
            
            //It seems the correct obd BLE can be automatically discovered and connected,
            //so I only need to show green(connected) or red(disconnected).
            //Unnecessary to show all possible adapters.
            self.connectedAdapterName = self._transporter.getAdapter().name!
            let allDevices = self._transporter.getAllDevices()
            print("adapter: \(self._transporter.getAdapter()), all devices: \(allDevices)")
        }
        _transporter.startUpdatingSignalStrength(withInterval: 1.0)
    }
    
    public func disconnect () -> () {
        for event in events {
            let json = event.serialize()
            
        }
        
        _obd2Adapter?.disconnect()
        _transporter.disconnect()
        self.isConnected = false
    }
    
    private func updateSensorDataForSupportedPids() {
//        let pid900 = LTOBD2PID_VIN_CODE_0902.init()//LTOBD2PID_VIN_CODE_0902.init() causes the bluetooth to fail "The connection has timed out unexpectedly."
        updateSensorDataForSupportedPid(commands: self.supportedPidCommands, index: 0)
    }
    
    private func updateSensorDataForSupportedPid(commands: [LTOBD2PID], index: Int) {
        let pidCommand = commands[index]
        self._obd2Adapter?.transmitCommand(pidCommand, responseHandler: {_ in
            DispatchQueue.main.async {
                //get timestamp
                if self.startTime == nil {
                    self.startTime = Date()
                }
                let duration = Date().timeIntervalSince(self.startTime!)
                
                if (pidCommand.gotValidAnswer) {
                    //generate SupportedPidsEvent
                    let startIndex = pidCommand.commandString.startIndex
                    let i = pidCommand.commandString.index(pidCommand.commandString.startIndex, offsetBy: 2)
                    self.addToEvents(command: pidCommand, duration: duration, isSupportedPidsCommand: true, mode: Int(pidCommand.commandString[startIndex..<i], radix: 16)!, pid: Int(pidCommand.commandString[i...], radix: 16)!)
                    
                    //get supported pids
                    var bitmap: [Bool] = []
                    let cooked: [NSNumber] = pidCommand.cookedResponse.values.first!
                    for num in cooked {
                        let b = self.decimal2Bitmap(num: num.intValue)
                        bitmap.append(contentsOf: b)
                    }
                    for (i, b) in bitmap.enumerated() {
                        if b && (i+1) % 32 != 0{ // %32 to eliminate pids of supported pids
                            self.supportedPids.append(index * 32 + i + 1)//+1 because $01~$20 starts from 0
                        }
                    }
                    print("index: \(index), support \(self.supportedPids)")
                    
                    // recursive to the next supportedPidCommand
                    if pidCommand.cookedResponse.values.first!.last!.intValue % 2 == 1 && index < 6{
                        //D0 is odd number means the next supportedPid is supported.
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            self.updateSensorDataForSupportedPid(commands: commands, index: index + 1)
                        }
                    } else {
                        //fuelType
                        self._obd2Adapter?.transmitCommand(self.fuelType, responseHandler: {_ in
                            DispatchQueue.main.async {
                                //get timestamp
                                if self.startTime == nil {
                                    self.startTime = Date()
                                }
                                let duration = Date().timeIntervalSince(self.startTime!)
                                self.addToEvents(command: self.fuelType, duration: duration)
                                self.myFuelType = self.fuelType.formattedResponse
                                
                                let supported = self.checkSupportedPids(supportedPids: self.supportedPids, fuelType: self.myFuelType)
                                //TODO: if not supported, throw exception?
                                if supported {
                                    let specFile = self.buildSpec()
                                    self.rustGreetings.initmonitor(s: specFile)
                                    self.updateSensorData()
                                }else{
                                    print("ERROR: Car is NOT compatible for RDE tests.")
                                }
                            }
                        })
                    }
                }
            }
        })
    }
    
    private func checkSupportedPids(supportedPids: [Int], fuelType: String) -> Bool {
        // If the car is not a diesel or gasoline, the RDE test is not possible since there are no corresponding
        // specifications.
        if (fuelType != "Diesel" && fuelType != "Gasoline") {
            print("Incompatible for RDE: Fuel type unknown or invalid ('\(fuelType)')")
            return false
        }
        
        // Velocity information to determine acceleration, distance travelled and to calculate the driving dynamics.
        if (supportedPids.contains(0x0D)) {
            rdeProfile.append(CommandItem(pid: "0D", name: "SPEED", unit: "km/h", obdCommand: LTOBD2PID_VEHICLE_SPEED_0D.forMode1()))
        } else {
            print("Incompatible for RDE: Speed data not provided by the car.")
            return false
        }

        // Ambient air temperature for checking compliance with the environmental constraints.
        if (supportedPids.contains(0x46)) {
            rdeProfile.append(CommandItem(pid: "46", name: "AMBIENT AIR TEMPERATURE", unit: "°C", obdCommand: LTOBD2PID_AMBIENT_TEMP_46.forMode1()))
        } else {
            print("Incompatible for RDE: Ambient air temperature not provided by the car.")
            return false
        }

        // NOx sensor(s) to check for violation of the EU regulations.
        if supportedPids.contains(0x83) {
            rdeProfile.append(CommandItem(pid: "83", name: "NOX SENSOR", unit: "ppm", obdCommand: LTOBD2PID_NOX_SENSOR_83.forMode1()))
        } else if supportedPids.contains(0xA1) {
            rdeProfile.append(CommandItem(pid: "A1", name: "NOX SENSOR CORRECTED", unit: "ppm", obdCommand: LTOBD2PID_NOX_SENSOR_CORRECTED_A1.forMode1()))
        } else if supportedPids.contains(0xA7) {
            rdeProfile.append(CommandItem(pid: "A7", name: "NOX SENSOR ALTERNATIVE", unit: "ppm", obdCommand: LTOBD2PID_NOX_SENSOR_ALTERNATIVE_A7.forMode1()))
        } else if supportedPids.contains(0xA8) {
            rdeProfile.append(CommandItem(pid: "A8", name: "NOX SENSOR CORRECTED ALTERNATIVE", unit: "ppm", obdCommand: LTOBD2PID_NOX_SENSOR_CORRECTED_ALTERNATIVE_A8.forMode1()))
        } else {
            print("Incompatible for RDE: NOx sensor not provided by the car.")
            return false
        }

        // Fuelrate sensors for calculation of the exhaust mass flow. Can be replaced through MAF.
        // TODO: ask Maxi for the EMF PID
        if supportedPids.contains(0x5E) {
            rdeProfile.append(CommandItem(pid: "5E", name: "ENGINE FUEL RATE", unit: "L/h", obdCommand: LTOBD2PID_ENGINE_FUEL_RATE_5E.forMode1()))
            fuelRateSupported = true
        } else if supportedPids.contains(0x9D) {
            rdeProfile.append(CommandItem(pid: "9D", name: "ENGINE FUEL RATE MULTI", unit: "g/s", obdCommand: LTOBD2PID_ENGINE_FUEL_RATE_MULTI_9D.forMode1()))
            fuelRateSupported = true
        } else {
            print("RDE: Fuel rate not provided by the car.")
            fuelRateSupported = false
        }

        // Mass air flow rate for the calcuation of the exhaust mass flow.
        if supportedPids.contains(0x10) {
            rdeProfile.append(CommandItem(pid: "10", name: "MAF AIR FLOW RATE", unit: "g/s", obdCommand: LTOBD2PID_MAF_FLOW_10.forMode1()))
        } else if supportedPids.contains(0x66) {
            rdeProfile.append(CommandItem(pid: "66", name: "MAF AIR FLOW RATE SENSOR", unit: "g/s", obdCommand: LTOBD2PID_MASS_AIR_FLOW_SNESOR_66.forMode1()))
        } else {
            print("Incompatible for RDE: Mass air flow not provided by the car.")
            return false
        }

        // Fuel air equivalence ratio for a more precise calculation of the fuel rate with MAF.
        if (supportedPids.contains(0x44) && !fuelRateSupported) {
            rdeProfile.append(CommandItem(pid: "44", name: "FUEL AIR EQUIVALENCE RATIO", unit: "LAMBDA", obdCommand: LTOBD2PID_AIR_FUEL_EQUIV_RATIO_44.forMode1()))
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
            if myFuelType == "Diesel" {
                if (faeSupported) {
                    s.append(specMAFToFuelRateDieselFAE)
                } else {
                    s.append(specMAFToFuelRateDiesel)
                }
            }
            if myFuelType == "Gasoline" {
                if (faeSupported) {
                    s.append(specMAFToFuelRateGasolineFAE)
                } else {
                    s.append(specMAFToFuelRateGasoline)
                }
            }
        }
        if myFuelType == "Diesel" {
            s.append(specFuelRateToCo2Diesel)
            s.append(specFuelRateToEMFDiesel)
        }
        if myFuelType == "Gasoline"{
            s.append(specFuelRateToCo2Gasoline)
            s.append(specFuelRateToEMFGasoline)
        }
        s.append(specBody)

        return s
    }
    
    private func updateSensorData () {
        var commandItems: [CommandItem] = self.rdeProfile
        if !self.selectedCommands.isEmpty {
            commandItems = selectedCommands //TODO: get selecteProfile from Model
        }
        _obd2Adapter?.transmitMultipleCommands(commandItems.map{$0.obdCommand}, completionHandler: {
            (commands : [LTOBD2Command])->() in
            DispatchQueue.main.async {
                //timestamp
                if self.startTime == nil {
                    self.startTime = Date()
                }
                let duration = Date().timeIntervalSince(self.startTime!) //in seconds, because in rust Duration::new(seconds: time, nanoseconds: 0)
                
                //GPS
                let altitude = self.locationHelper.altitude
                self.myAltitude = "\(altitude) m"
                self.addToEvents(duration: duration, altitude: altitude, longitude: self.locationHelper.longitude, latitude: self.locationHelper.latitude, gps_speed: self.locationHelper.gps_speed)
                
                commandItems.forEach { item in
                    let obdCommand = item.obdCommand
                    switch item.pid {
                    case "05":
                        self.myCoolantTemp = obdCommand.formattedResponse
                    case "0C":
                        self.myRPM = obdCommand.formattedResponse
                    case "0D":
                        self.mySpeed = obdCommand.formattedResponse
                    case "0F":
                        self.myIntakeTemp = obdCommand.formattedResponse
                    case "10":
                        self.myMAFRate = obdCommand.formattedResponse
                    case "24":
                        self.myOxygenSensor1 = obdCommand.formattedResponse
                    case "2C":
                        self.myCommandedEgr = obdCommand.formattedResponse
                    case "2D":
                        self.myEgrError = obdCommand.formattedResponse
                    case "2F":
                        self.myFuelTankLevelInput = obdCommand.formattedResponse
                    case "3C":
                        self.myCatalystTemp11 = obdCommand.formattedResponse
                    case "3D":
                        self.myCatalystTemp21 = obdCommand.formattedResponse
                    case "3E":
                        self.myCatalystTemp12 = obdCommand.formattedResponse
                    case "3F":
                        self.myCatalystTemp22 = obdCommand.formattedResponse
                    case "44":
                        self.myAirFuelEqvRatio = obdCommand.formattedResponse
                    case "46":
                        self.myTemp = obdCommand.formattedResponse
                    case "4F":
                        switch item.unit {
                        case "LAMBDA":
                            self.myMaxValueFuelAirEqvRatio = obdCommand.formattedResponse
                        case "V":
                            self.myMaxValueOxygenSensorVoltage = obdCommand.formattedResponse
                        case "mA":
                            self.myMaxValueOxygenSensorCurrent = obdCommand.formattedResponse
                        case "kPa":
                            self.myMaxValueIntakeMAP = obdCommand.formattedResponse
                        default:
                            print("pid 4F, no match unit")
                        }
                    case "50":
                        self.myMaxAirFlowRate = obdCommand.formattedResponse
                    case "51":
                        self.myFuelType = obdCommand.formattedResponse
                    case "5C":
                        self.myEngineOilTemp = obdCommand.formattedResponse
                    case "5E":
                        self.myFuelRate = obdCommand.formattedResponse
                    case "66":
                        self.myMAFRateSensor = obdCommand.formattedResponse
                    case "68":
                        self.myIntakeAirTempSensor = obdCommand.formattedResponse
                    case "83":
                        self.myNox = obdCommand.formattedResponse
                    case "86":
                        self.myPmSensor = obdCommand.formattedResponse
                    case "9D":
                        self.myEngineFuelRateMulti = obdCommand.formattedResponse
                    case "9E":
                        self.myEngineExhaustFlowRate = obdCommand.formattedResponse
                    case "A1":
                        self.myNoxCorrected = obdCommand.formattedResponse
                    case "A7":
                        self.myNoxAlternative = obdCommand.formattedResponse
                    case "A8":
                        self.myNoxCorrectedAlternative = obdCommand.formattedResponse
                    default:
                        print("pid \(item.pid), no match case")
                    }
                    self.addToEvents(command: obdCommand, duration: duration)
                    self.printCommandResponse(command: obdCommand)
                }
                
                let inputCommands: [LTOBD2PID] = self.rdeProfile.map{ $0.obdCommand }
                let gotValidAnswers: [LTOBD2PID] = inputCommands.filter{ $0.gotValidAnswer }
                if inputCommands.count ==  gotValidAnswers.count {
                    //TODO: which order??? where to insert altitude??? // maybe all ok //TODO: varying count
                    var s = [inputCommands[0].cookedResponse.values.first!.first!.doubleValue,//speed
                             altitude,
                             inputCommands[1].cookedResponse.values.first!.first!.doubleValue,//temp
                             inputCommands[2].cookedResponse.values.first!.first!.doubleValue,//nox
                             inputCommands[3].cookedResponse.values.first!.first!.doubleValue,//fuelrate
                             inputCommands[4].cookedResponse.values.first!.first!.doubleValue,//mafrate
                             duration]

                    self.outputValues = self.rustGreetings.sendevent(inputs: &s, len_in: UInt32(s.count))
                    print("*********** rtlola outputs: \(self.outputValues)")
                }

                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    self.updateSensorData()
                }
            }
        })
    }
    
    //GPSEvent
    private func addToEvents(duration: TimeInterval,
                             altitude: CLLocationDistance?,
                             longitude: CLLocationDegrees?,
                             latitude: CLLocationDegrees?,
                             gps_speed: CLLocationSpeed?){
        if altitude != nil, longitude != nil, latitude != nil, gps_speed != nil {
            self.events.append(GPSEvent(source: "Phone-GPS",
                                        timestamp: Int64(duration * 1000000000),
                                        longitude: longitude!, latitude: latitude!,
                                        altitude: altitude!,
                                        speed: gps_speed as? KotlinDouble))//gps_speed: A negative value indicates an invalid speed. Because the actual speed can change many times between the delivery of location events, use this property for informational purposes only.
        }else{
            self.events.append(ErrorEvent(source: "GPS unavailable",
                                          timestamp: Int64(duration * 1000000000),
                                          message: "altitude: \(altitude), longitude: \(longitude), latitude: \(latitude), gps_speed: \(gps_speed)"))
        }
    }
    
    //OBDEvent
    private func addToEvents(command: LTOBD2Command,
                             duration: TimeInterval,
                             isSupportedPidsCommand: Bool = false,
                             mode: Int = 1,
                             pid: Int = -1) {
        if command.gotValidAnswer {
            let raw = command.rawResponse[0]//header #bytes response
            let firstSpaceIndex = raw.firstIndex(of: " ")!
            let afterFirstSpaceIndex = raw.index(after: firstSpaceIndex)
            let secondSpaceIndex = raw[afterFirstSpaceIndex...].firstIndex(of: " ")!
            let header = raw[..<firstSpaceIndex]
            let response = raw[secondSpaceIndex...].trimmingCharacters(in: .whitespacesAndNewlines)
            
            if isSupportedPidsCommand {
                let cooked: [NSNumber] = command.cookedResponse.values.first!
                let supportedPids: [Int] = cooked.map({$0.intValue})
                self.events.append(SupportedPidsEvent(source: "ECU-\(header)", timestamp: Int64(duration * 1000000000), bytes: response, pid: Int32(pid), mode: Int32(mode), supportedPids: NSMutableArray.init(array: supportedPids)))
            } else {
                self.events.append(OBDEvent(source: "ECU-\(header)", timestamp: Int64(duration * 1000000000), bytes: response))//duration is in seconds, timestamp is in nanoseconds
            }
        }else{
            self.events.append(ErrorEvent(source: "OBD got unvalid answer", timestamp: Int64(duration * 1000000000), message: "\(command.rawResponse)"))
        }
    }
    
    private func printCommandResponse(command: LTOBD2PID){
        print("============== \(command.description), cookedResponse: \(command.cookedResponse), formattedResponse: \(command.formattedResponse), commandString: \(command.commandString), completionTime: \(command.completionTime), failureResponse: \(command.failureResponse), freezeFrame: \(command.freezeFrame), gotAnswer: \(command.gotAnswer), gotValidAnswer: \(command.gotValidAnswer), isCAN: \(command.isCAN), isRawCommand: \(command.isRawCommand), purpose: \(command.purpose), rawResponse: \(command.rawResponse), selectedECU: \(command.selectedECU)")
    }
    
    private func decimal2Bitmap(num: Int) -> [Bool]{
        let str = UInt8(num).binaryDescription
        var ret = Array(repeating: false, count: 8)
        for (i, s) in str.enumerated() {
            if s == "1" {
                ret[i] = true
            }
        }
        return ret
    }
    
    @objc func onAdapterChangedState(){
        DispatchQueue.main.async {
            switch self._obd2Adapter?.adapterState{
            case OBD2AdapterStateDiscovering, OBD2AdapterStateConnected:
                self.updateSensorDataForSupportedPids()
            default:
                print("Unhandled adapter state \(self._obd2Adapter?.friendlyAdapterState)")
            }
        }
    }
}
