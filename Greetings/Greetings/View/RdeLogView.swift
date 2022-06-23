import SwiftUI
import pcdfcore

struct RdeLogView: View{
    @EnvironmentObject var viewModel: ViewModel
    @EnvironmentObject var obd: MyOBD
    
    var body: some View{
        TabView{
            RdeEventLogView(fileName: obd.getFileName())
                .tabItem{
                    Text("Event Log")
                }
        }
        .toolbar{
            ToolbarItem(placement: .navigationBarLeading){
                Button(action: {
                    viewModel.exitRDE()
                }) {
                    HStack(spacing: 0) {
                        Image(systemName: "chevron.backward")
                            .aspectRatio(contentMode: .fill)
                        Text("Configuration")
                    }
                }
            }
            ToolbarItem(placement: .navigationBarTrailing){
                ConnectedDisconnectedView(connected: obd.isConnected())
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}

struct RdeEventLogView: View{
    let fileName: String
    let outputs: [String: Double]
    
    init(fileName: String) {
        self.fileName = fileName
        do {
            let fileUrl = try EventStore.fileURL(fileName: fileName)
            var events: [PCDFEvent] = []
            EventStore.load(fileURL: fileUrl) { result in
                if case .success(let e) = result {
                    events = e
                }
            }
            let rdeValidator = RDEValidator()
            outputs = try rdeValidator.monitorOffline(data: events)
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    
    var body: some View{
        VStack{
            Text("Valid RDE Trip:")
            Text("Total Duration:")
            Text("Total Distance:")
            Text("NOₓ Emissions:")
        }
    }
}
