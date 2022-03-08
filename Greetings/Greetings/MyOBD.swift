import Foundation
import LTSupportAutomotive
import CoreLocation
import SwiftUI

class MyOBD: ObservableObject{
    var _serviceUUIDs : [CBUUID]
    var _pids : [LTOBD2Command]
    var _transporter : LTBTLESerialTransporter
    var _obd2Adapter : LTOBD2Adapter?
    
    // LOLA
    let rustGreetings = RustGreetings()
    let fileContent = specFile(filename: "rde-lola-test-drive-spec-no-percentile1.lola")
    
    @Published var mySpeed : String = ""
    @Published var myAltitude : String = ""
    @Published var myTemp : String = ""
    @Published var myNox: String = ""
    @Published var myFuelRate: String = ""
    @Published var myMAFRate: String = ""
    
    @Published var myMAFRateSensor: String = ""
    @Published var myIntakeAirTempSensor: String = ""
    
//    @Published var myAirFuelEqvRatio2: String = ""
//    @Published var myAirFuelEqvRatio3: String = ""
    var startTime: Date? = nil
    var _locationHelper: LocationHelper?
    
    //RTLola outputs
    var outputNames : [String] = [
        "d",
        "d_u",
        "d_r",
        "d_m",
        "t_u",
        "t_r",
        "t_m",
        "u_avg_v",
        "r_avg_v",
        "m_avg_v",
        "u_va_pct",
        "r_va_pct",
        "m_va_pct",
        "u_rpa",
        "r_rpa",
        "m_rpa",
        "nox_per_kilometer",
        "is_valid_test",
        "not_rde_test"
    ]
    var outputValues : [Double]
    
    //UI: markers and balls in dynamics progress bars
    var dynamicMarkerLowUrban : Double = 0
    var dynamicMarkerLowRural : Double = 0
    var dynamicMarkerLowMotorway : Double = 0
    var dynamicMarkerHighUrban : Double = 0
    var dynamicMarkerHighRural : Double = 0
    var dynamicMarkerHighMotorway : Double = 0
    var circleUrbanLow : Double = 0
    var circleRuralLow : Double = 0
    var circleMotorwayLow : Double = 0
    var circleUrbanHigh : Double = 0
    var circleRuralHigh : Double = 0
    var circleMotorwayHigh : Double = 0
    
    init(){
        _serviceUUIDs = []
        _pids = []
        _transporter = LTBTLESerialTransporter()
        _locationHelper = nil
        outputValues = [Double](repeating: 0, count: 19)
    }
    
    func viewDidLoad () -> () {
        var ma : [CBUUID] = [CBUUID.init(string: "FFF0"), CBUUID.init(string: "FFE0"), CBUUID.init(string: "BEEF"), CBUUID.init(string: "E7810A71-73AE-499D-8C15-FAA9AEF0C3F2")]
        _serviceUUIDs = ma
        
        //use notificationcenter, only call updateSensorData() when adapter status is Discovering / Connected
        NotificationCenter.default.addObserver(self, selector: #selector(onAdapterChangedState), name: Notification.Name(LTOBD2AdapterDidUpdateState), object: nil)
        
        self.connect()
        rustGreetings.initmonitor(s: fileContent)
    }
    
    func connect () -> () {
        var ma : [LTOBD2Command] = [LTOBD2CommandELM327_IDENTIFY.command(),
                                LTOBD2CommandELM327_IGNITION_STATUS.command(),
                                LTOBD2CommandELM327_READ_VOLTAGE.command(),
                                LTOBD2CommandELM327_DESCRIBE_PROTOCOL.command(),

                                LTOBD2PID_VIN_CODE_0902(),
                                LTOBD2PID_FUEL_SYSTEM_STATUS_03.forMode1(),
                                LTOBD2PID_OBD_STANDARDS_1C.forMode1(),
                                LTOBD2PID_FUEL_TYPE_51.forMode1(),

                                LTOBD2PID_ENGINE_LOAD_04.forMode1(),
                                LTOBD2PID_COOLANT_TEMP_05.forMode1(),
                                LTOBD2PID_SHORT_TERM_FUEL_TRIM_1_06.forMode1(),
                                LTOBD2PID_LONG_TERM_FUEL_TRIM_1_07.forMode1(),
                                LTOBD2PID_SHORT_TERM_FUEL_TRIM_2_08.forMode1(),
                                LTOBD2PID_LONG_TERM_FUEL_TRIM_2_09.forMode1(),
                                LTOBD2PID_FUEL_PRESSURE_0A.forMode1(),
                                LTOBD2PID_INTAKE_MAP_0B.forMode1(),

                                LTOBD2PID_ENGINE_RPM_0C.forMode1(),
                                LTOBD2PID_VEHICLE_SPEED_0D.forMode1(),
                                LTOBD2PID_TIMING_ADVANCE_0E.forMode1(),
                                LTOBD2PID_INTAKE_TEMP_0F.forMode1(),
                                LTOBD2PID_MAF_FLOW_10.forMode1(),
                                LTOBD2PID_THROTTLE_11.forMode1(),

                                LTOBD2PID_SECONDARY_AIR_STATUS_12.forMode1(),
                                LTOBD2PID_OXYGEN_SENSORS_PRESENT_2_BANKS_13.forMode1()]
        
        for index in 0..<8{
            ma.append(LTOBD2PID_OXYGEN_SENSORS_INFO_1.pid(forSensor: UInt(index), mode: 1))
        }
        
        ma.append(LTOBD2PID_OXYGEN_SENSORS_PRESENT_4_BANKS_1D.forMode1())
        ma.append(LTOBD2PID_AUX_INPUT_1E.forMode1())
        ma.append(LTOBD2PID_RUNTIME_1F.forMode1())
        ma.append(LTOBD2PID_DISTANCE_WITH_MIL_21.forMode1())
        ma.append(LTOBD2PID_FUEL_RAIL_PRESSURE_22.forMode1())
        ma.append(LTOBD2PID_FUEL_RAIL_GAUGE_PRESSURE_23.forMode1())
        
        for index in 0..<8{
            ma.append(LTOBD2PID_OXYGEN_SENSORS_INFO_2.pid(forSensor: UInt(index), mode: 1))
        }
        
        ma.append(LTOBD2PID_COMMANDED_EGR_2C.forMode1())
        ma.append(LTOBD2PID_EGR_ERROR_2D.forMode1())
        ma.append(LTOBD2PID_COMMANDED_EVAPORATIVE_PURGE_2E.forMode1())
        ma.append(LTOBD2PID_FUEL_TANK_LEVEL_2F.forMode1())
        ma.append(LTOBD2PID_WARMUPS_SINCE_DTC_CLEARED_30.forMode1())
        ma.append(LTOBD2PID_DISTANCE_SINCE_DTC_CLEARED_31.forMode1())
        ma.append(LTOBD2PID_EVAP_SYS_VAPOR_PRESSURE_32.forMode1())
        ma.append(LTOBD2PID_ABSOLUTE_BAROMETRIC_PRESSURE_33.forMode1())
        
        for index in 0..<8{
            ma.append(LTOBD2PID_OXYGEN_SENSORS_INFO_3.pid(forSensor: UInt(index), mode: 1))
        }
        
        ma.append(LTOBD2PID_CATALYST_TEMP_B1S1_3C.forMode1())
        ma.append(LTOBD2PID_CATALYST_TEMP_B2S1_3D.forMode1())
        ma.append(LTOBD2PID_CATALYST_TEMP_B1S2_3E.forMode1())
        ma.append(LTOBD2PID_CATALYST_TEMP_B2S2_3F.forMode1())
        ma.append(LTOBD2PID_CONTROL_MODULE_VOLTAGE_42.forMode1())
        ma.append(LTOBD2PID_ABSOLUTE_ENGINE_LOAD_43.forMode1())
        ma.append(LTOBD2PID_AIR_FUEL_EQUIV_RATIO_44.forMode1())
        ma.append(LTOBD2PID_RELATIVE_THROTTLE_POS_45.forMode1())
        ma.append(LTOBD2PID_AMBIENT_TEMP_46.forMode1())
        ma.append(LTOBD2PID_ABSOLUTE_THROTTLE_POS_B_47.forMode1())
        ma.append(LTOBD2PID_ABSOLUTE_THROTTLE_POS_C_48.forMode1())
        ma.append(LTOBD2PID_ACC_PEDAL_POS_D_49.forMode1())
        ma.append(LTOBD2PID_ACC_PEDAL_POS_E_4A.forMode1())
        ma.append(LTOBD2PID_ACC_PEDAL_POS_F_4B.forMode1())
        ma.append(LTOBD2PID_COMMANDED_THROTTLE_ACTUATOR_4C.forMode1())
        ma.append(LTOBD2PID_TIME_WITH_MIL_4D.forMode1())
        ma.append(LTOBD2PID_TIME_SINCE_DTC_CLEARED_4E.forMode1())
        ma.append(LTOBD2PID_MAX_VALUE_FUEL_AIR_EQUIVALENCE_RATIO_4F.forMode1())
        ma.append(LTOBD2PID_MAX_VALUE_OXYGEN_SENSOR_VOLTAGE_4F.forMode1())
        ma.append(LTOBD2PID_MAX_VALUE_OXYGEN_SENSOR_CURRENT_4F.forMode1())
        ma.append(LTOBD2PID_MAX_VALUE_INTAKE_MAP_4F.forMode1())
        ma.append(LTOBD2PID_MAX_VALUE_MAF_AIR_FLOW_RATE_50.forMode1())
        
        ma.append(LTOBD2PID_NOX_SENSOR_83.forMode1())
        
        _pids = ma
        
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
            
            self.updateSensorData()
                                })
        
        _transporter.startUpdatingSignalStrength(withInterval: 1.0)
    }
    
    func disconnect () -> () {
        _obd2Adapter?.disconnect()
        _transporter.disconnect()
    }
    
    func updateSensorData () -> () {
        print("************adapter nil? \(_obd2Adapter == nil)")
        let speed = LTOBD2PID_VEHICLE_SPEED_0D.forMode1()
        let temp = LTOBD2PID_AMBIENT_TEMP_46.forMode1()
        let nox = LTOBD2PID_NOX_SENSOR_83.forMode1()
        let fuelRate = LTOBD2PID_ENGINE_FUEL_RATE_5E.forMode1()
        let mafRate = LTOBD2PID_MAF_FLOW_10.forMode1()
        
        let airFuelEqvRatio = LTOBD2PID_AIR_FUEL_EQUIV_RATIO_44.forMode1()
        let coolantTemp = LTOBD2PID_COOLANT_TEMP_05.forMode1()
        let rpm = LTOBD2PID_ENGINE_RPM_0C.forMode1()
        let intakeTemp = LTOBD2PID_INTAKE_TEMP_0F.forMode1()
        let mafRateSensor = LTOBD2PID_MASS_AIR_FLOW_SNESOR_66.forMode1()
        let oxygenSensor1 = LTOBD2PID_OXYGEN_SENSOR_INFO_2_SENSOR_0_24.forMode1()
        let commandedEgr = LTOBD2PID_COMMANDED_EGR_2C.forMode1()
        let fuelTankLevelInput = LTOBD2PID_FUEL_TANK_LEVEL_2F.forMode1()
        let catalystTemp11 = LTOBD2PID_CATALYST_TEMP_B1S1_3C.forMode1()
        let catalystTemp12 = LTOBD2PID_CATALYST_TEMP_B1S2_3E.forMode1()
        let catalystTemp21 = LTOBD2PID_CATALYST_TEMP_B2S1_3D.forMode1()
        let catalystTemp22 = LTOBD2PID_CATALYST_TEMP_B2S2_3F.forMode1()
        let ambientAirTemp = LTOBD2PID_AMBIENT_TEMP_46.forMode1()
        let maxValueFuelAirEqvRatio = LTOBD2PID_MAX_VALUE_FUEL_AIR_EQUIVALENCE_RATIO_4F.forMode1()
        let maxValueOxygenSensorVoltage = LTOBD2PID_MAX_VALUE_OXYGEN_SENSOR_VOLTAGE_4F.forMode1()
        let maxValueOxygenSensorCurrent = LTOBD2PID_MAX_VALUE_OXYGEN_SENSOR_CURRENT_4F.forMode1()
        let maxValueIntakeMAP = LTOBD2PID_MAX_VALUE_INTAKE_MAP_4F.forMode1()
        let maxAirFlowRate = LTOBD2PID_MAX_VALUE_MAF_AIR_FLOW_RATE_50.forMode1()
        let fuelType = LTOBD2PID_FUEL_TYPE_51.forMode1()
        let engineOilTemp = LTOBD2PID_ENGINE_OIL_TEMP_5C.forMode1()
        let intakeAirTempSensor = LTOBD2PID_INTAKE_AIR_TEMP_SENSOR_68.forMode1()
        let noxCorrected = LTOBD2PID_NOX_SENSOR_CORRECTED_A1.forMode1()
        let noxAlternative = LTOBD2PID_NOX_SENSOR_ALTERNATIVE_A7.forMode1()
        let noxCorrectedAlternative = LTOBD2PID_NOX_SENSOR_CORRECTED_ALTERNATIVE_A8.forMode1()
        let pmSensor = LTOBD2PID_PATICULATE_MATTER_SENSOR_86.forMode1()
        let engineFuelRate = LTOBD2PID_ENGINE_FUEL_RATE_5E.forMode1()
//        let engineFuelRateMulti = LTOBD2PID_ENGINE_FUEL_RATE_MULTI_9D
//        let engineExhaustFlowRate = LTOBD2PID_ENGINE_EXHAUST_FLOW_RATE_9E
        let egrError = LTOBD2PID_EGR_ERROR_2D.forMode1()
        
        
        _obd2Adapter?.transmitMultipleCommands([speed, temp, nox, fuelRate, mafRate, mafRateSensor, intakeAirTempSensor], completionHandler: {
            (commands : [LTOBD2Command])->() in
            DispatchQueue.main.async {
                if self.startTime == nil {
                    self.startTime = Date()
                }
                let duration = Date().timeIntervalSince(self.startTime!)
                self.mySpeed = speed.formattedResponse
                let altitude = self._locationHelper?.altitude
                self.myAltitude = "\(altitude ?? 0) m"
                self.myTemp = temp.formattedResponse
                self.myNox = nox.formattedResponse
                self.myFuelRate = fuelRate.formattedResponse
                self.myMAFRate = mafRate.formattedResponse
                
                self.myMAFRateSensor = mafRateSensor.formattedResponse
                self.myIntakeAirTempSensor = intakeAirTempSensor.formattedResponse
//                self.myAirFuelEqvRatio2 = airFuelEqvRatio2.formattedResponse
//                self.myAirFuelEqvRatio3 = airFuelEqvRatio3.formattedResponse
                
                print("*********** speed in updateSensorData \(self.mySpeed)")
                print("*********** altitude in updateSensorData \(self.myAltitude)")
                print("*********** temp in updateSensorData \(self.myTemp)")
                print("*********** nox in updateSensorData \(self.myNox)")
                print("*********** fuelRate in updateSensorData \(self.myFuelRate)")
                print("*********** mafRate in updateSensorData \(self.myMAFRate)")
                print("*********** mafRateSensor in updateSensorData \(self.myMAFRateSensor)")
//                print("*********** myAirFuelEqvRatio2 in updateSensorData \(self.myAirFuelEqvRatio2)")
//                print("*********** myAirFuelEqvRatio3 in updateSensorData \(self.myAirFuelEqvRatio3)")
                
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
                    if !self.outputValues.isEmpty {
                        self.handleDynamics(u_avg_v: self.outputValues[7], r_avg_v: self.outputValues[8], m_avg_v: self.outputValues[9], u_rpa: self.outputValues[13], r_rpa: self.outputValues[14], m_rpa: self.outputValues[15], u_va_pct: self.outputValues[10], r_va_pct: self.outputValues[11], m_va_pct: self.outputValues[12])
                    }
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    self.updateSensorData()
                }
            }
        })
    }
    
    private func handleDynamics(u_avg_v: Double,
                                r_avg_v: Double,
                                m_avg_v: Double,
                                u_rpa: Double,
                                r_rpa: Double,
                                m_rpa: Double,
                                u_va_pct: Double,
                                r_va_pct: Double,
                                m_va_pct: Double) {
        // RPA Threshold-Markers
        let offsetRpa = 0.35 // GuidelineDynamicsBarLow Percentage
        let boundaryRpa = 0.605
        let lengthRpa = boundaryRpa - offsetRpa

        let maxRpa = 0.3 // Realistic maximum RPA

        // Calculate Horizontal Marker Positions
        let uRpaThreshold = -0.0016 * u_avg_v + 0.1755
        let rRpaThreshold = -0.0016 * r_avg_v + 0.1755
        var mRpaThreshold = 0.025
        if (m_avg_v <= 94.05) { mRpaThreshold = -0.0016 * m_avg_v + 0.1755 }

        let uRpaMarkerPercentage = uRpaThreshold / maxRpa
        let rRpaMarkerPercentage = rRpaThreshold / maxRpa
        let mRpaMarkerPercentage = mRpaThreshold / maxRpa

//        fragment.guidelineDynamicMarkerLowUrban.setGuidelinePercent(((lengthRpa * uRpaMarkerPercentage) + offsetRpa).toFloat())
//        fragment.guidelineDynamicMarkerLowRural.setGuidelinePercent(((lengthRpa * rRpaMarkerPercentage) + offsetRpa).toFloat())
//        fragment.guidelineDynamicMarkerLowMotorway.setGuidelinePercent(((lengthRpa * mRpaMarkerPercentage) + offsetRpa).toFloat())
        dynamicMarkerLowUrban = (lengthRpa * uRpaMarkerPercentage) + offsetRpa
        dynamicMarkerLowRural = (lengthRpa * rRpaMarkerPercentage) + offsetRpa
        dynamicMarkerLowMotorway = (lengthRpa * mRpaMarkerPercentage) + offsetRpa
        
        // PCT95 Threshold-Markers
        let offsetPct = 0.62
        let boundaryPct = 0.88
        let lengthPct = boundaryPct - offsetPct

        let maxPct = 35.0

        // Calculate Horizontal Marker Positions
        let uPctThreshold = 0.136 * u_avg_v + 14.44
        var rPctThreshold =  0.0742 * r_avg_v + 18.966
        if (r_avg_v <= 74.6) { rPctThreshold = 0.136 * r_avg_v + 14.44 }
        let mPctThreshold = 0.0742 * m_avg_v + 18.966

        let uPctMarkerPercentage = uPctThreshold / maxPct
        let rPctMarkerPercentage = rPctThreshold / maxPct
        let mPctMarkerPercentage = mPctThreshold / maxPct

//        fragment.guidelineDynamicMarkerHighUrban.setGuidelinePercent(((lengthPct * uPctMarkerPercentage) + offsetPct).toFloat())
//        fragment.guidelineDynamicMarkerHighRural.setGuidelinePercent(((lengthPct * rPctMarkerPercentage) + offsetPct).toFloat())
//        fragment.guidelineDynamicMarkerHighMotorway.setGuidelinePercent(((lengthPct * mPctMarkerPercentage) + offsetPct).toFloat())
        dynamicMarkerHighUrban = (lengthPct * uPctMarkerPercentage) + offsetPct
        dynamicMarkerHighRural = (lengthPct * rPctMarkerPercentage) + offsetPct
        dynamicMarkerHighMotorway = (lengthPct * mPctMarkerPercentage) + offsetPct
        
        
        // Calculate RPA Ball Positions
        let uRpaBallPercentage = u_rpa / maxRpa
        let rRpaBallPercentage = r_rpa / maxRpa
        let mRpaBallPercentage = m_rpa / maxRpa

//        fragment.guidelineCircleUrbanLow.setGuidelinePercent(
//            (lengthRpa * uRpaBallPercentage + offsetRpa).toFloat().coerceAtMost(boundaryRpa.toFloat())
//        )
//        fragment.guidelineCircleRuralLow.setGuidelinePercent(
//            (lengthRpa * rRpaBallPercentage + offsetRpa).toFloat().coerceAtMost(boundaryRpa.toFloat())
//        )
//        fragment.guidelineCircleMotorwayLow.setGuidelinePercent(
//            (lengthRpa * mRpaBallPercentage + offsetRpa).toFloat().coerceAtMost(boundaryRpa.toFloat())
//        )
        circleUrbanLow = lengthRpa * uRpaBallPercentage + offsetRpa
        circleUrbanLow = circleUrbanLow > boundaryRpa ? boundaryRpa : circleUrbanLow
        circleRuralLow = lengthRpa * rRpaBallPercentage + offsetRpa
        circleRuralLow = circleRuralLow > boundaryRpa ? boundaryRpa : circleRuralLow
        circleMotorwayLow = lengthRpa * mRpaBallPercentage + offsetRpa
        circleMotorwayLow = circleMotorwayLow > boundaryRpa ? boundaryRpa : circleMotorwayLow
        
        // Calculate PCT Ball Positions
        let uPctBallPercentage = u_va_pct / maxPct
        let rPctBallPercentage = r_va_pct / maxPct
        let mPctBallPercentage = m_va_pct / maxPct

//        fragment.guidelineCircleUrbanHigh.setGuidelinePercent(
//            (lengthPct * uPctBallPercentage + offsetPct).toFloat().coerceAtMost(boundaryPct.toFloat())
//        )
//        fragment.guidelineCircleRuralHigh.setGuidelinePercent(
//            (lengthPct * rPctBallPercentage + offsetPct).toFloat().coerceAtMost(boundaryPct.toFloat())
//        )
//        fragment.guidelineCircleMotorwayHigh.setGuidelinePercent(
//            (lengthPct * mPctBallPercentage + offsetPct).toFloat().coerceAtMost(boundaryPct.toFloat())
//        )
        circleUrbanHigh = lengthPct * uPctBallPercentage + offsetPct
        circleUrbanHigh = circleUrbanLow > boundaryPct ? boundaryPct : circleUrbanLow
        circleRuralHigh = lengthPct * rPctBallPercentage + offsetPct
        circleRuralHigh = circleRuralLow > boundaryPct ? boundaryPct : circleRuralLow
        circleMotorwayHigh = lengthPct * mPctBallPercentage + offsetPct
        circleMotorwayHigh = circleMotorwayLow > boundaryPct ? boundaryPct : circleMotorwayLow
        
        print("*********** dynamics: \nlow: \(dynamicMarkerLowUrban),\(dynamicMarkerLowRural),\(dynamicMarkerLowMotorway)\nhigh:\(dynamicMarkerHighUrban),\(dynamicMarkerHighRural),\(dynamicMarkerHighMotorway)\ncircle low:\(circleUrbanLow),\(circleRuralLow),\(circleMotorwayLow)\ncircle high:\(circleUrbanHigh),\(circleRuralHigh),\(circleMotorwayHigh)")
    }
    
    @objc func onAdapterChangedState(){
        DispatchQueue.main.async {
            switch self._obd2Adapter?.adapterState{
                case OBD2AdapterStateDiscovering,
            OBD2AdapterStateConnected:
                self.updateSensorData()
            default:
                print("Unhandled adapter state \(self._obd2Adapter?.friendlyAdapterState)")
            }
        }
    }
}
