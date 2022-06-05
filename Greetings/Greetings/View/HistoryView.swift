import SwiftUI

struct HistoryView: View {
    @EnvironmentObject var viewModel: ViewModel
    @State var allFiles = EventStore.getAllFiles()
    
    var body: some View {
        List {
            //need to bind to all files, so that the view updates when a file is deleted
            ForEach($allFiles, id: \.self) {$fileURL in
                NavigationLink(destination: HistoryDetailView(file: fileURL)){
                    Text(fileURL.deletingPathExtension().lastPathComponent)
                }
                .swipeActions(edge: .trailing, allowsFullSwipe: false){
                    Button(role: .destructive){
                        EventStore.removeFile(fileURL)
                        allFiles = EventStore.getAllFiles()//since binding the ForEach parameter to a function doesn't work, use @State to bind a var and update it here.
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
            }
        }
        .navigationTitle("History")
    }
}

struct HistoryView_Previews: PreviewProvider {
    static var previews: some View {
        HistoryView()
    }
}
