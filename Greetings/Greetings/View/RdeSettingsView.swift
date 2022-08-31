import SwiftUI

struct RdeSettingsView: View{
    @EnvironmentObject var viewModel: ViewModel
    @EnvironmentObject var obd: MyOBD
    @State var unableToTap = false
    
    var body: some View{
        VStack{
            Text("RDE Test configuration")
                .font(.title)
            Text("Choose a distance for your test ride")
                .font(.subheadline)
                .foregroundColor(.gray)
            Spacer()

            Text("\(Int(viewModel.model.distanceSetting)) km")
                .font(.system(size: 60))
            
            Slider(
                value: $viewModel.model.distanceSetting,
                in: 48...100
            ) {
                Text("distance")
            } minimumValueLabel: {
                Text("48")
            } maximumValueLabel: {
                Text("100")
            }
                .padding(10)
            
            NavigationLink(destination: HelpView(), label: {
                Text("An RDE ride takes between 90 and 120 mimnutes, and has to be at least 48km long. For more detailed information about RDE rides, simply click on this text.")
                    .foregroundColor(.gray)
            })
            Spacer()
            
            NavigationLink(destination: RdeView()){
                Text("Start RDE test")
                    .bold()
                    .font(.title2)
                    .frame(width: 280, height: 50)
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .simultaneousGesture(TapGesture().onEnded{
                if !viewModel.isStartLiveMonitoringButton() {
                    unableToTap = true
                } else {
                    unableToTap = false
                    viewModel.startRDE()
                    obd.run(isLiveMonitoring: false, selectedCommands: [])
                }
            })
        }
        .alert("Unable to start RDE test during live monitoring", isPresented: $unableToTap){ Button("OK", role: .cancel, action: {}) }
        .toolbar{
            ToolbarItem(placement: .navigationBarTrailing){
                ConnectedDisconnectedView(connected: obd.isConnected())
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .padding()
    }
}

struct RdeSettingView_Previews: PreviewProvider {
    static var previews: some View {
        RdeSettingsView()
    }
}
