import SwiftUI

struct HistoryView: View {
    @EnvironmentObject var viewModel: ViewModel
    
    var body: some View {
        List {
            ForEach(viewModel.getPpcdfFiles(), id: \.self) {fileURL in
                NavigationLink(destination: HistoryDetailView(file: fileURL)){
                    Text(fileURL.deletingPathExtension().lastPathComponent)
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
