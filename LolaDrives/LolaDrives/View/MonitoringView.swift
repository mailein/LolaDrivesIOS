import SwiftUI
//import LTSupportAutomotive

struct MonitoringView: View {
    @EnvironmentObject var viewModel: ViewModel
    @EnvironmentObject var obd: MyOBD
    
    var body: some View {
        let commands = getCurrentCommands()
        VStack{
            List(commands, id: \.id) { command in
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
                            Text(obd.myTemp)
                        case "4F":
                            switch command.unit {
                            case "LAMBDA":
                                Text(obd.myMaxValueFuelAirEqvRatio)
                            case "V":
                                Text(obd.myMaxValueOxygenSensorVoltage)
                            case "mA":
                                Text(obd.myMaxValueOxygenSensorCurrent)
                            case "kPa":
                                Text(obd.myMaxValueIntakeMAP)
                            default:
                                Text("")
                            }
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
                            Text(obd.myFuelRate)
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
            Button(action: {
                liveMonitoring()
            }, label: {
                let (text, color) = viewModel.isStartLiveMonitoringButton() ? ("Start Live Monitoring", Color.green) : ("Stop Live Monitoring", Color.red)
                Text(text)
                    .bold()
                    .font(.title2)
                    .frame(width: 280, height: 50)
                    .background(color)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .padding()
            })
            .disabled(viewModel.model.isRDEMonitoring)
        }
        .navigationBarTitle("Monitoring")
//        .navigationBarTitleDisplayMode(.inline)
        .toolbar{
            ToolbarItem(placement: .navigationBarTrailing){
                ConnectedDisconnectedView(connected: obd.isConnected())
            }
        }
        .onAppear{
            //rule out current ongoing live monitoring or ongoing rde monitoring
            if viewModel.isStartLiveMonitoringButton() && !obd.isRunning() {
                liveMonitoring()
            }
        }
    }
    
    func getCurrentCommands() -> [CommandItem] {
        if !obd.isLiveMonitoringMode(){
            return obd.getRdeCommands()
        }else{
            return obd.getSelectedCommands().filter({$0.enabled})
        }
    }
    
    func liveMonitoring(){
        if viewModel.isStartLiveMonitoringButton() {//start live monitoring
            obd.run(isLiveMonitoring: true, selectedCommands: viewModel.getSelectedProfileCommands())
        }else{//stop live monitoring
            obd.disconnect()
        }
        viewModel.startLiveMonitoringToggle()
    }
}

//struct MonitoringView_Previews: PreviewProvider {
//    static var previews: some View {
//        MonitoringView()
//    }
//}
