import SwiftUI

struct NavBar: ViewModifier{
    @EnvironmentObject var model: Model
    @EnvironmentObject var obd: MyOBD
    
    func body(content: Content) -> some View {
        content
            .toolbar{
                ToolbarItem(placement: .navigationBarLeading){
                    HomeIconView()
                }
                ToolbarItem(placement: .navigationBarTrailing){
                    ConnectedDisconnectedView(connected: obd.isConnected())
                }
            }
    }
}

extension View{
    func LolaNavBarStyle() -> some View{
        modifier(NavBar())
    }
}

// MARK: - Elements in nav bar
struct HomeIconView: View{
    var body: some View{
        HStack{
            Image(systemName: "house.fill")
            Text("LolaDrives")
        }
    }
}

struct ConnectedDisconnectedView: View{
    @EnvironmentObject var obd: MyOBD
    var connected: Bool
    @State private var showPopover = false
    
    var body: some View{
        Button(action: {
            showPopover = true
        }, label: {
            if connected {
                VStack(alignment: .center, spacing: 0){
                    Image("elm_logo_green")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 30)
                    Text("connected")
                }
                .foregroundColor(.green)
            }else{
                VStack(alignment: .center, spacing: 0){
                    Image("elm_logo_red")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 30)
                    Text("disconnected")
                }
                .foregroundColor(.red)
            }
        })
        .popover(isPresented: $showPopover, content: {
            Text(obd.getConnectedAdapterName())
        })
    }
}
