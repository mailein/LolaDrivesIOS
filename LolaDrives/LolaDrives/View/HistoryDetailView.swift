import SwiftUI
import pcdfcore
import Charts

struct HistoryDetailView: View {
    var fileURL: URL
    
    var body: some View {
        var fileName = fileURL.lastPathComponent
        
        RdeTabView(selectedTab: 0, fileName: fileName)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar{
            ToolbarItem(placement: .principal) {
                Text(fileURL.deletingPathExtension().lastPathComponent)
            }
        }
    }
}
