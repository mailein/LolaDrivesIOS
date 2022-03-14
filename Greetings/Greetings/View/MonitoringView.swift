import SwiftUI
//import LTSupportAutomotive

struct MonitoringView: View {
    @EnvironmentObject var viewModel: ViewModel
    @EnvironmentObject var obd: MyOBD
    
    var body: some View {
        let selectedProfile = viewModel.getSelectedProfile()
        List(selectedProfile.commands.filter({$0.enabled}), id: \.self) { command in
            HStack{
                Text(command.name)
                Spacer()
                VStack(alignment: .trailing){
                    switch command.pid {
                    case "05":
                        Text(obd.myCoolantTemp)
                    case "0C":
                        Text(obd.myRPM)
                    case "0D":
                        Text(obd.mySpeed)
                    case "0F":
                        Text(obd.myIntakeTemp)
                    case "10":
                        Text(obd.myMAFRate)
                    case "66":
                        Text(obd.myMAFRateSensor)
                    case "24":
                        Text(obd.myOxygenSensor1)
                    case "2C":
                        Text(obd.myCommandedEgr)
                    case "2F":
                        Text(obd.myFuelTankLevelInput)
                    case "3C":
                        Text(obd.myCatalystTemp11)
                    case "3E":
                        Text(obd.myCatalystTemp12)
                    case "3D":
                        Text(obd.myCatalystTemp21)
                    case "3F":
                        Text(obd.myCatalystTemp22)
                    case "44":
                        Text(obd.myAirFuelEqvRatio)
                    case "46":
                        Text(obd.myAmbientAirTemp)
                    case "4F":
                        Text("\(obd.myMaxValueFuelAirEqvRatio) | \(obd.myMaxValueOxygenSensorVoltage) | \(obd.myMaxValueOxygenSensorCurrent) | \(obd.myMaxValueIntakeMAP)")
                    case "50":
                        Text(obd.myMaxAirFlowRate)
                    case "51":
                        Text(obd.myFuelType)
                    case "5C":
                        Text(obd.myEngineOilTemp)
                    case "68":
                        Text(obd.myIntakeAirTempSensor)
                    case "83":
                        Text(obd.myNox)
                    case "A1":
                        Text(obd.myNoxCorrected)
                    case "A7":
                        Text(obd.myNoxAlternative)
                    case "A8":
                        Text(obd.myNoxCorrectedAlternative)
                    case "86":
                        Text(obd.myPmSensor)
                    case "5E":
                        Text(obd.myEngineFuelRate)
                    case "9D":
                        Text(obd.myEngineFuelRateMulti)
                    case "9E":
                        Text(obd.myEngineExhaustFlowRate)
                    case "2D":
                        Text(obd.myEgrError)
                    default:
                        Text("")
                    }
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct MonitoringView_Previews: PreviewProvider {
    static var previews: some View {
        MonitoringView()
    }
}
