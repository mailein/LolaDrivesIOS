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
                    HStack(alignment: .firstTextBaseline){
                        let bytes = event.getPattern().data?.bytes ?? ""
                        let mode = event.getPattern().data?.mode ?? 0
                        let pid = event.getPattern().data?.pid ?? 0
                        Text("bytes: \(bytes)\tmode: \(mode)\tpid: \(pid)")
                    }
                    
//                    switch event{
//                    case is OxygenSensor1Event:
//                        Text((event as! OxygenSensor1Event).toString())
//                    case is FuelRateMultiEvent:
//                        Text((event as! FuelRateMultiEvent).toString())
//                    }
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
    
    private func type2String(type: EventType)-> some View {
        switch type{
        case .obdResponse:
            return Text("OBD_RESPONSE")
        case .gps:
            return Text("GPS")
        case .error:
            return Text("ERROR")
        case .meta:
            return Text("META")
        case . analyser:
            return Text("ANALYSER")
        case .custom:
            return Text("CUSTOM")
        default:
            return Text("")
        }
    }
}


struct RdeProfileTabView: View{
    var body: some View{
        Text("Speed profile")
    }
}

