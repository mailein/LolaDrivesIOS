import SwiftUI

struct RdeLogView: View{
    @EnvironmentObject var viewModel: ViewModel
    
    var body: some View{
        TabView{
            RdeEventLogView()
                .tabItem{
                    Text("Event Log")
                }
        }
        .navigationBarItems(leading:
            Button(action: {
                viewModel.model.started = false
            }) {
                HStack(spacing: 0) {
                    Image(systemName: "chevron.backward")
                        .aspectRatio(contentMode: .fill)
                    Text("Configuration")
                }
            }
        )
        .navigationBarItems(trailing: ConnectedDisconnectedView(connected: viewModel.model.isConnected))
        .navigationBarBackButtonHidden(true)
    }
}

struct RdeEventLogView: View{
    var body: some View{
        VStack{
            Text("Valid RDE Trip:")
            Text("Total Duration:")
            Text("Total Distance:")
            Text("NOₓ Emissions:")
        }
    }
}

struct RdeLogView_Previews: PreviewProvider {
    static var previews: some View {
        RdeLogView()
    }
}
