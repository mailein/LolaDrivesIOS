import SwiftUI
//import LTSupportAutomotive

struct MonitoringView: View {
    @EnvironmentObject var viewModel: ViewModel
    
    var body: some View {
        let selectedProfile = viewModel.getSelectedProfile()
        List(selectedProfile.commands.filter({$0.enabled}), id: \.id) { command in
            HStack{
                Text(command.name)
                Spacer()
                VStack(alignment: .trailing){
                    switch command.pid {
                    case "05":
                        Text(viewModel.getOBD()?.myCoolantTemp ?? "No data")
                    case "0C":
                        Text(viewModel.getOBD()?.myRPM ?? "No data")
                    case "0D":
                        Text(viewModel.getOBD()?.mySpeed ?? "No data")
                    case "0F":
                        Text(viewModel.getOBD()?.myIntakeTemp ?? "No data")
                    case "10":
                        Text(viewModel.getOBD()?.myMAFRate ?? "No data")
                    case "66":
                        Text(viewModel.getOBD()?.myMAFRateSensor ?? "No data")
                    case "24":
                        Text(viewModel.getOBD()?.myOxygenSensor1 ?? "No data")
                    case "2C":
                        Text(viewModel.getOBD()?.myCommandedEgr ?? "No data")
                    case "2F":
                        Text(viewModel.getOBD()?.myFuelTankLevelInput ?? "No data")
                    case "3C":
                        Text(viewModel.getOBD()?.myCatalystTemp11 ?? "No data")
                    case "3E":
                        Text(viewModel.getOBD()?.myCatalystTemp12 ?? "No data")
                    case "3D":
                        Text(viewModel.getOBD()?.myCatalystTemp21 ?? "No data")
                    case "3F":
                        Text(viewModel.getOBD()?.myCatalystTemp22 ?? "No data")
                    case "44":
                        Text(viewModel.getOBD()?.myAirFuelEqvRatio ?? "No data")
                    case "46":
                        Text(viewModel.getOBD()?.myTemp ?? "No data")
                    case "4F":
                        Text("\(viewModel.getOBD()?.myMaxValueFuelAirEqvRatio ?? "No data") | \(viewModel.getOBD()?.myMaxValueOxygenSensorVoltage ?? "No data") | \(viewModel.getOBD()?.myMaxValueOxygenSensorCurrent ?? "No data") | \(viewModel.getOBD()?.myMaxValueIntakeMAP ?? "No data")")
                    case "50":
                        Text(viewModel.getOBD()?.myMaxAirFlowRate ?? "No data")
                    case "51":
                        Text(viewModel.getOBD()?.myFuelType ?? "No data")
                    case "5C":
                        Text(viewModel.getOBD()?.myEngineOilTemp ?? "No data")
                    case "68":
                        Text(viewModel.getOBD()?.myIntakeAirTempSensor ?? "No data")
                    case "83":
                        Text(viewModel.getOBD()?.myNox ?? "No data")
                    case "A1":
                        Text(viewModel.getOBD()?.myNoxCorrected ?? "No data")
                    case "A7":
                        Text(viewModel.getOBD()?.myNoxAlternative ?? "No data")
                    case "A8":
                        Text(viewModel.getOBD()?.myNoxCorrectedAlternative ?? "No data")
                    case "86":
                        Text(viewModel.getOBD()?.myPmSensor ?? "No data")
                    case "5E":
                        Text(viewModel.getOBD()?.myFuelRate ?? "No data")
                    case "9D":
                        Text(viewModel.getOBD()?.myEngineFuelRateMulti ?? "No data")
                    case "9E":
                        Text(viewModel.getOBD()?.myEngineExhaustFlowRate ?? "No data")
                    case "2D":
                        Text(viewModel.getOBD()?.myEgrError ?? "No data")
                    default:
                        Text("")
                    }
                }
            }
        }
        .navigationBarTitle("Monitoring")
//        .navigationBarTitleDisplayMode(.inline)
        .toolbar{
            ToolbarItem(placement: .navigationBarTrailing){
                ConnectedDisconnectedView(connected: viewModel.model.isConnected)
            }
        }
    }
}

struct MonitoringView_Previews: PreviewProvider {
    static var previews: some View {
        MonitoringView()
    }
}
