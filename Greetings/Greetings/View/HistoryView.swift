import SwiftUI

struct HistoryView: View {
    @EnvironmentObject var viewModel: ViewModel
    
    var body: some View {
        do{//TODO: 
            let dir = try EventStore.dirURL()
        }catch{
            
        }
        
        List {//TODO: open dir to get all files
            ForEach(viewModel.getPpcdfFiles(), id: \.self) {fileURL in
                NavigationLink(destination: HistoryDetailView(file: fileURL)){
                    Text(fileURL.deletingPathExtension().lastPathComponent)
                }
            }
        }
        .navigationTitle("History: \(viewModel.getPpcdfFiles().count) files")
    }
}

struct HistoryView_Previews: PreviewProvider {
    static var previews: some View {
        HistoryView()
    }
}
