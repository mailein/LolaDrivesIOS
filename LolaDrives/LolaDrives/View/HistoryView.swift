import SwiftUI

struct HistoryView: View {
    @EnvironmentObject var model: Model
    @EnvironmentObject var obd: MyOBD
    @State var allFiles = EventStore.getAllFiles()
    @State var unableToDelete = false
    
    var body: some View {
        List {
            //need to bind to all files, so that the view updates when a file is deleted
            ForEach($allFiles, id: \.self) {$fileURL in
                NavigationLink(destination: HistoryDetailView(fileURL: fileURL)){
                    Text(fileURL.deletingPathExtension().lastPathComponent)
                }
                .swipeActions(edge: .trailing, allowsFullSwipe: false){
                    Button(role: .destructive){
                        if !model.startLiveMonitoring || obd.isRunning() {
                            unableToDelete = true
                        } else {
                            unableToDelete = false
                            EventStore.removeFile(fileURL)
                            allFiles = EventStore.getAllFiles()//since binding the ForEach parameter to a function doesn't work, use @State to bind a var and update it here.
                        }
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
            }
            .alert("Unable to delete during an ongoing RDE test / live monitoring", isPresented: $unableToDelete) {
                Button("OK", role: .cancel, action: {})
            }
        }
        .navigationTitle("History")
//        .padding(.top, -30)
    }
}

struct HistoryView_Previews: PreviewProvider {
    static var previews: some View {
        HistoryView()
    }
}
