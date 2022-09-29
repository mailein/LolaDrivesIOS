import SwiftUI
import pcdfcore
import Charts

struct HistoryDetailView: View {
    var fileURL: URL
    
    var body: some View {
        TabView{
            EventLogView(fileURL: fileURL)
                .tabItem{
                    Label("Event log", systemImage: "doc.plaintext")
                }
            ChartsView(fileURL: fileURL)
                .tabItem{
                    Label("Charts", systemImage: "chart.xyaxis.line")
                }
            RdeResultView(fileName: fileURL.lastPathComponent)
                .tabItem{
                    Label("RDE Result", systemImage: "car")
                }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar{
            ToolbarItem(placement: .principal) {
                Text(fileURL.deletingPathExtension().lastPathComponent)
            }
        }
        .padding(.top, 1)//a hopefully invisible workaround, otherwise TabView being inside NavigationView causes the navigation bar to be transparent
    }
}

struct EventLogView: View{
    var fileURL: URL
    var fileName: String
    @StateObject private var eventStore = EventStore()
    
    init(fileURL: URL){
        self.fileURL = fileURL
        self.fileName = fileURL.lastPathComponent
    }
    
    init(fileName: String){
        do{
            try self.fileURL = EventStore.fileURL(fileName: fileName)
        }catch{
            self.fileURL = URL(fileURLWithPath: "")
        }
        self.fileName = fileName
    }
    
    var body: some View{
        List{
            ForEach(eventStore.events, id: \.hashValue){ event in
                VStack(alignment: .leading){
                    Text(String(describing: event.type))
                        .bold()
                    DurationText(durationInSeconds: event.timestamp/1000000000)
                    Text(event.toIntermediate().description)
                }
            }
        }
        .onAppear{
            EventStore.load(fileURL: fileURL){result in
                if case .success(let e) = result {
                    eventStore.events = e
                }
            }
        }
    }
}

