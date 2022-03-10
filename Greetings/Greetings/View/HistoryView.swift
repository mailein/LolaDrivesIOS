import SwiftUI

struct HistoryView: View {
    var body: some View {
        TabView{
            EventLogTabView()
                .tabItem{
                    Text("Event log")
                }
            SpeedProfileTabView()
                .tabItem{
                    Text("Speed profile")
                }
        }
    }
}

struct EventLogTabView: View{
    var body: some View{
        Text("Event log")
    }
}

struct SpeedProfileTabView: View{
    var body: some View{
        Text("Speed profile")
    }
}

struct HistoryView_Previews: PreviewProvider {
    static var previews: some View {
        HistoryView()
    }
}
