import SwiftUI
//import LTSupportAutomotive

struct MonitoringView: View {
    @EnvironmentObject var viewModel: ViewModel
    var isStartButton: Bool = true
    
    var body: some View {
        let commands = viewModel.getCurrentCommands()
        VStack{
            ScrollView{
                List(commands.filter({$0.enabled}), id: \.id) { command in
                    HStack{
                        Text(command.name)
                        Spacer()
                        VStack(alignment: .trailing){
                            switch command.pid {
                            case "05":
                                Text(viewModel.getOBD().myCoolantTemp)
                            case "0C":
                                Text(viewModel.getOBD().myRPM)
                            case "0D":
                                Text(viewModel.getOBD().mySpeed)
                            case "0F":
                                Text(viewModel.getOBD().myIntakeTemp)
                            case "10":
                                Text(viewModel.getOBD().myMAFRate)
                            case "66":
                                Text(viewModel.getOBD().myMAFRateSensor)
                            case "24":
                                Text(viewModel.getOBD().myOxygenSensor1)
                            case "2C":
                                Text(viewModel.getOBD().myCommandedEgr)
                            case "2F":
                                Text(viewModel.getOBD().myFuelTankLevelInput)
                            case "3C":
                                Text(viewModel.getOBD().myCatalystTemp11)
                            case "3E":
                                Text(viewModel.getOBD().myCatalystTemp12)
                            case "3D":
                                Text(viewModel.getOBD().myCatalystTemp21)
                            case "3F":
                                Text(viewModel.getOBD().myCatalystTemp22)
                            case "44":
                                Text(viewModel.getOBD().myAirFuelEqvRatio)
                            case "46":
                                Text(viewModel.getOBD().myTemp)
                            case "4F":
                                Text("\(viewModel.getOBD().myMaxValueFuelAirEqvRatio) | \(viewModel.getOBD().myMaxValueOxygenSensorVoltage) | \(viewModel.getOBD().myMaxValueOxygenSensorCurrent) | \(viewModel.getOBD().myMaxValueIntakeMAP)")
                            case "50":
                                Text(viewModel.getOBD().myMaxAirFlowRate)
                            case "51":
                                Text(viewModel.getOBD().myFuelType)
                            case "5C":
                                Text(viewModel.getOBD().myEngineOilTemp)
                            case "68":
                                Text(viewModel.getOBD().myIntakeAirTempSensor)
                            case "83":
                                Text(viewModel.getOBD().myNox)
                            case "A1":
                                Text(viewModel.getOBD().myNoxCorrected)
                            case "A7":
                                Text(viewModel.getOBD().myNoxAlternative)
                            case "A8":
                                Text(viewModel.getOBD().myNoxCorrectedAlternative)
                            case "86":
                                Text(viewModel.getOBD().myPmSensor)
                            case "5E":
                                Text(viewModel.getOBD().myFuelRate)
                            case "9D":
                                Text(viewModel.getOBD().myEngineFuelRateMulti)
                            case "9E":
                                Text(viewModel.getOBD().myEngineExhaustFlowRate)
                            case "2D":
                                Text(viewModel.getOBD().myEgrError)
                            default:
                                Text("")
                            }
                        }
                    }
                }
            }
            Button(action: {
                viewModel.liveMonitoring()
            }, label: {
                if viewModel.isStartLiveMonitoring(){
                    Text("Start Live Monitoring")
                }else{
                    Text("Stop Live Monitoring")
                }
            })
        }
        .navigationBarTitle("Monitoring")
//        .navigationBarTitleDisplayMode(.inline)
        .toolbar{
            ToolbarItem(placement: .navigationBarTrailing){
                ConnectedDisconnectedView(connected: viewModel.isConnected())
            }
        }
    }
}

//struct MonitoringView_Previews: PreviewProvider {
//    static var previews: some View {
//        MonitoringView()
//    }
//}
