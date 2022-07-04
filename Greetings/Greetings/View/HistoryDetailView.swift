import SwiftUI
import pcdfcore
import Charts

struct HistoryDetailView: View {
    var file: URL
    var body: some View {
        TabView{
            EventLogTabView(file: file)
                .tabItem{
                    Text("Event log")
                }
            ChartView(entries: [
                BarChartDataEntry(x: 1,y: 1),
                BarChartDataEntry(x: 2,y: 2),
                BarChartDataEntry(x: 3,y: 3),
                BarChartDataEntry(x: 4,y: 4),
                BarChartDataEntry(x: 5,y: 5)
            ], label: "avg(NOₓ)")
                .tabItem{
                    Text("Chart")
                }
            RdeResultView(fileName: file.lastPathComponent)
                .tabItem{
                    Text("RDE profile")
                }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar{
            ToolbarItem(placement: .principal) {
                Text(file.deletingPathExtension().lastPathComponent)
            }
        }
        .padding(.top, 1)//a hopefully invisible workaround, otherwise TabView being inside NavigationView causes the navigation bar to be transparent
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

