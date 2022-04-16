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
    
    // LOLA
    let rustGreetings = RustGreetings()
    let fileContent = specFile(filename: "rde-lola-test-drive-spec-no-percentile1.lola")//even if it's in a folder, no need to add folder name
    var supportedPidsChecked = false
    var monitorInited = false
    
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
    var _locationHelper: LocationHelper?
    
    //RTLola outputs
//    var outputNames : [String] = [
//        "d",
//        "d_u",
//        "d_r",
//        "d_m",
//        "t_u",
//        "t_r",
//        "t_m",
//        "u_avg_v",
//        "r_avg_v",
//        "m_avg_v",
//        "u_va_pct",
//        "r_va_pct",
//        "m_va_pct",
//        "u_rpa",
//        "r_rpa",
//        "m_rpa",
//        "nox_per_kilometer",
//        "is_valid_test",
//        "not_rde_test"
//    ]
    var outputValues : [Double]
    
    //ppcdf
    var events: [pcdfcore.PCDFEvent]
    
    init(){
        _serviceUUIDs = []
        _pids = []
        _transporter = LTBTLESerialTransporter()
        _locationHelper = nil
        outputValues = [Double](repeating: 0, count: 19)
        events = []
    }
    
    public func viewDidLoad () -> () {
        var ma : [CBUUID] = [CBUUID.init(string: "FFF0"), CBUUID.init(string: "FFE0"), CBUUID.init(string: "BEEF"), CBUUID.init(string: "E7810A71-73AE-499D-8C15-FAA9AEF0C3F2")]
        _serviceUUIDs = ma
        
        //use notificationcenter, only call updateSensorData() when adapter status is Discovering / Connected
        NotificationCenter.default.addObserver(self, selector: #selector(onAdapterChangedState), name: Notification.Name(LTOBD2AdapterDidUpdateState), object: nil)
        
        self.connect()
        rustGreetings.initmonitor(s: fileContent)
    }
    
    private func connect () -> () {
        _transporter = LTBTLESerialTransporter.init(identifier: nil, serviceUUIDs: _serviceUUIDs)
        //The closure is called after transporter has connected! So updateSensorData() should be called inside the closure after adapter connects
        _transporter.connect({(inputStream : InputStream?, outputStream : OutputStream?) -> () in
            if((inputStream == nil)){
                print("Could not connect to OBD2 adapter")
                return;
            }
            self._obd2Adapter = LTOBD2AdapterELM327.init(inputStream: inputStream!, outputStream: outputStream!)
            self._obd2Adapter!.connect()
            print("adapter init and connected")
                                })
        
        _transporter.startUpdatingSignalStrength(withInterval: 1.0)
    }
    
    public func disconnect () -> () {
        for event in events {
            let json = event.serialize()
            
        }
        
        _obd2Adapter?.disconnect()
        _transporter.disconnect()
    }
    
    private func updateSensorData () -> () {
        let coolantTemp = LTOBD2PID_COOLANT_TEMP_05.forMode1()
        let rpm = LTOBD2PID_ENGINE_RPM_0C.forMode1()
        let speed = LTOBD2PID_VEHICLE_SPEED_0D.forMode1()
        let intakeTemp = LTOBD2PID_INTAKE_TEMP_0F.forMode1()
        let mafRate = LTOBD2PID_MAF_FLOW_10.forMode1()
        let oxygenSensor1 = LTOBD2PID_OXYGEN_SENSOR_INFO_2_SENSOR_0_24.forMode1()
        let commandedEgr = LTOBD2PID_COMMANDED_EGR_2C.forMode1()
        let egrError = LTOBD2PID_EGR_ERROR_2D.forMode1()
        let fuelTankLevelInput = LTOBD2PID_FUEL_TANK_LEVEL_2F.forMode1()
        let catalystTemp11 = LTOBD2PID_CATALYST_TEMP_B1S1_3C.forMode1()
        let catalystTemp12 = LTOBD2PID_CATALYST_TEMP_B1S2_3E.forMode1()
        let catalystTemp21 = LTOBD2PID_CATALYST_TEMP_B2S1_3D.forMode1()
        let catalystTemp22 = LTOBD2PID_CATALYST_TEMP_B2S2_3F.forMode1()
        let airFuelEqvRatio = LTOBD2PID_AIR_FUEL_EQUIV_RATIO_44.forMode1()
        let temp = LTOBD2PID_AMBIENT_TEMP_46.forMode1()
        let maxValueFuelAirEqvRatio = LTOBD2PID_MAX_VALUE_FUEL_AIR_EQUIVALENCE_RATIO_4F.forMode1()
        let maxValueOxygenSensorVoltage = LTOBD2PID_MAX_VALUE_OXYGEN_SENSOR_VOLTAGE_4F.forMode1()
        let maxValueOxygenSensorCurrent = LTOBD2PID_MAX_VALUE_OXYGEN_SENSOR_CURRENT_4F.forMode1()
        let maxValueIntakeMAP = LTOBD2PID_MAX_VALUE_INTAKE_MAP_4F.forMode1()
        let maxAirFlowRate = LTOBD2PID_MAX_VALUE_MAF_AIR_FLOW_RATE_50.forMode1()
        let fuelType = LTOBD2PID_FUEL_TYPE_51.forMode1()
        let engineOilTemp = LTOBD2PID_ENGINE_OIL_TEMP_5C.forMode1()
        let fuelRate = LTOBD2PID_ENGINE_FUEL_RATE_5E.forMode1()
        let mafRateSensor = LTOBD2PID_MASS_AIR_FLOW_SNESOR_66.forMode1()
        let intakeAirTempSensor = LTOBD2PID_INTAKE_AIR_TEMP_SENSOR_68.forMode1()
        let nox = LTOBD2PID_NOX_SENSOR_83.forMode1()
        let pmSensor = LTOBD2PID_PATICULATE_MATTER_SENSOR_86.forMode1()
        let fuelRateMulti = LTOBD2PID_ENGINE_FUEL_RATE_MULTI_9D.forMode1()
        let engineExhaustFlowRate = LTOBD2PID_ENGINE_EXHAUST_FLOW_RATE_9E.forMode1()
        let noxCorrected = LTOBD2PID_NOX_SENSOR_CORRECTED_A1.forMode1()
        let noxAlternative = LTOBD2PID_NOX_SENSOR_ALTERNATIVE_A7.forMode1()
        let noxCorrectedAlternative = LTOBD2PID_NOX_SENSOR_CORRECTED_ALTERNATIVE_A8.forMode1()
        
        let supportedPid00 = LTOBD2PID_SUPPORTED_COMMANDS1_00.forMode1()
        
        //TODO: send commands based on current profile
        _obd2Adapter?.transmitMultipleCommands([supportedPid00, speed, temp, nox, fuelRate, mafRate, airFuelEqvRatio, coolantTemp, rpm, intakeTemp, mafRateSensor, oxygenSensor1, commandedEgr, fuelTankLevelInput, catalystTemp11, catalystTemp12, catalystTemp21, catalystTemp22, maxValueFuelAirEqvRatio, maxValueOxygenSensorVoltage, maxValueOxygenSensorCurrent, maxValueIntakeMAP, maxAirFlowRate, fuelType, engineOilTemp, intakeAirTempSensor, noxCorrected, noxAlternative, noxCorrectedAlternative, pmSensor, fuelRateMulti, engineExhaustFlowRate, egrError], completionHandler: {
            (commands : [LTOBD2Command])->() in
            DispatchQueue.main.async {
                if self.startTime == nil {
                    self.startTime = Date()
                }
                let duration = Date().timeIntervalSince(self.startTime!) //in seconds, because in rust Duration::new(seconds: time, nanoseconds: 0)
                self.mySpeed = speed.formattedResponse
                self.addToEvents(command: speed, duration: duration)
                
                self.printCommandResponse(command: supportedPid00)
                print("connectedECUs: \(supportedPid00.connectedECUs)")
                self.printCommandResponse(command: speed)
                
                let altitude = self._locationHelper?.altitude
                self.myAltitude = "\(altitude ?? 0) m"
                self.addToEvents(duration: duration, altitude: altitude, longitude: self._locationHelper!.longitude, latitude: self._locationHelper?.latitude, gps_speed: self._locationHelper?.gps_speed)
                
                self.myTemp = temp.formattedResponse
                self.myNox = nox.formattedResponse
                self.myFuelRate = fuelRate.formattedResponse
                self.myMAFRate = mafRate.formattedResponse
                self.myAirFuelEqvRatio = airFuelEqvRatio.formattedResponse
                self.myCoolantTemp = coolantTemp.formattedResponse
                self.myRPM = rpm.formattedResponse
                self.myIntakeTemp = intakeTemp.formattedResponse
                self.myMAFRateSensor = mafRateSensor.formattedResponse
                self.myOxygenSensor1 = oxygenSensor1.formattedResponse
                self.myCommandedEgr = commandedEgr.formattedResponse
                self.myFuelTankLevelInput = fuelTankLevelInput.formattedResponse
                self.myCatalystTemp11 = catalystTemp11.formattedResponse
                self.myCatalystTemp12 = catalystTemp12.formattedResponse
                self.myCatalystTemp21 = catalystTemp21.formattedResponse
                self.myCatalystTemp22 = catalystTemp22.formattedResponse
                self.myMaxValueFuelAirEqvRatio = maxValueFuelAirEqvRatio.formattedResponse
                self.myMaxValueOxygenSensorVoltage = maxValueOxygenSensorVoltage.formattedResponse
                self.myMaxValueOxygenSensorCurrent = maxValueOxygenSensorCurrent.formattedResponse
                self.myMaxValueIntakeMAP = maxValueIntakeMAP.formattedResponse
                self.myMaxAirFlowRate = maxAirFlowRate.formattedResponse
                self.myFuelType = fuelType.formattedResponse
                self.myEngineOilTemp = engineOilTemp.formattedResponse
                self.myIntakeAirTempSensor = intakeAirTempSensor.formattedResponse
                self.myNoxCorrected = noxCorrected.formattedResponse
                self.myNoxAlternative = noxAlternative.formattedResponse
                self.myNoxCorrectedAlternative = noxCorrectedAlternative.formattedResponse
                self.myPmSensor = pmSensor.formattedResponse
                self.myEngineFuelRateMulti = fuelRateMulti.formattedResponse
                self.myEngineExhaustFlowRate = engineExhaustFlowRate.formattedResponse
                self.myEgrError = egrError.formattedResponse
                
                if(speed.gotValidAnswer && altitude != nil && temp.gotValidAnswer && nox.gotValidAnswer
                   && fuelRate.gotValidAnswer && mafRate.gotValidAnswer){
                    var s = [speed.cookedResponse.values.first!.first!.doubleValue,
                             altitude!,
                             temp.cookedResponse.values.first!.first!.doubleValue,
                             nox.cookedResponse.values.first!.first!.doubleValue,
                             fuelRate.cookedResponse.values.first!.first!.doubleValue,
                             mafRate.cookedResponse.values.first!.first!.doubleValue,
                             duration]
                    
                    self.outputValues = self.rustGreetings.sendevent(inputs: &s, len_in: 7)
                    print("*********** rtlola outputs: \(self.outputValues)")
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    self.updateSensorData()
                }
            }
        })
    }
    
    //OBDEvent
    private func addToEvents(command: LTOBD2Command, duration: TimeInterval) {
        if command.gotValidAnswer {
            let raw = command.rawResponse[0]//header #bytes response
            let firstSpaceIndex = raw.firstIndex(of: " ")!
            let afterFirstSpaceIndex = raw.index(after: firstSpaceIndex)
            let secondSpaceIndex = raw[afterFirstSpaceIndex...].firstIndex(of: " ")!
            let header = raw[..<firstSpaceIndex]
            let response = raw[secondSpaceIndex...].trimmingCharacters(in: .whitespacesAndNewlines)
            
            self.events.append(OBDEvent(source: "ECU-\(header)", timestamp: Int64(duration * 1000000000), bytes: response))//duration is in seconds, timestamp is in nanoseconds
        }else{
            self.events.append(ErrorEvent(source: "OBD got unvalid answer", timestamp: Int64(duration * 1000000000), message: "\(command.rawResponse)"))
        }
    }
    
    //GPSEvent
    private func addToEvents(duration: TimeInterval, altitude: CLLocationDistance?, longitude: CLLocationDegrees?, latitude: CLLocationDegrees?, gps_speed: CLLocationSpeed?){
        if altitude != nil, longitude != nil, latitude != nil, gps_speed != nil {
            self.events.append(GPSEvent(source: "Phone-GPS", timestamp: Int64(duration * 1000000000), longitude: longitude!, latitude: latitude!, altitude: altitude!, speed: gps_speed as? KotlinDouble))//gps_speed: A negative value indicates an invalid speed. Because the actual speed can change many times between the delivery of location events, use this property for informational purposes only.
        }else{
            self.events.append(ErrorEvent(source: "GPS unavailable", timestamp: Int64(duration * 1000000000), message: "altitude: \(altitude), longitude: \(longitude), latitude: \(latitude), gps_speed: \(gps_speed)"))
        }
    }
    
    private func printCommandResponse(command: LTOBD2PID){
        print("============== \(command.description), cookedResponse: \(command.cookedResponse), formattedResponse: \(command.formattedResponse), commandString: \(command.commandString), completionTime: \(command.completionTime), failureResponse: \(command.failureResponse), freezeFrame: \(command.freezeFrame), gotAnswer: \(command.gotAnswer), gotValidAnswer: \(command.gotValidAnswer), isCAN: \(command.isCAN), isRawCommand: \(command.isRawCommand), purpose: \(command.purpose), rawResponse: \(command.rawResponse), selectedECU: \(command.selectedECU)")
    }
    
    @objc func onAdapterChangedState(){
        DispatchQueue.main.async {
            switch self._obd2Adapter?.adapterState{
            case OBD2AdapterStateDiscovering, OBD2AdapterStateConnected:
                self.updateSensorData()
            default:
                print("Unhandled adapter state \(self._obd2Adapter?.friendlyAdapterState)")
            }
        }
    }
}
