import SwiftUI

struct RdeTabView: View {
    @State var selectedTab = 2
    @EnvironmentObject var obd: MyOBD
    var fileName: String
    
    var body: some View{
        TabView(selection: $selectedTab){
            EventLogView(fileName: fileName)
                .tabItem{
                    Label("Event log", systemImage: "doc.plaintext")
                }
                .tag(0)
            ChartsView(fileName: fileName)
                .tabItem{
                    Label("Charts", systemImage: "chart.xyaxis.line")
                }
                .tag(1)
            RdeResultView(fileName: fileName)
                .tabItem{
                    Label("RDE Result", systemImage: "car")
                }
                .tag(2)
        }
        .padding(.top, 1)//a hopefully invisible workaround, otherwise TabView being inside NavigationView causes the navigation bar to be transparent
    }
}
