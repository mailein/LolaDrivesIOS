import SwiftUI
import pcdfcore

struct HistoryDetailView: View {
    var file: URL
    var body: some View {
        TabView{
            EventLogTabView(file: file)
                .tabItem{
                    Text("Event log")
                }
            RdeProfileTabView()
                .tabItem{
                    Text("RDE profile")
                }
        }
        .navigationTitle(file.deletingPathExtension().lastPathComponent)
    }
}

struct EventLogTabView: View{
    var file: URL
    @StateObject private var eventStore = EventStore()
    
    init(file: URL){
        self.file = file
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
            EventStore.load(fileURL: file){result in
                if case .success(let e) = result {
                    eventStore.events = e
                }
            }
        }
    }
}


struct RdeProfileTabView: View{
    var body: some View{
        Text("Speed profile")
    }
}

