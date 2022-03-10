import SwiftUI

struct NavBar: ViewModifier{
    func body(content: Content) -> some View {
        content
            .toolbar{
                ToolbarItem(placement: .navigationBarLeading){
                    HomeIconView()
                }
                ToolbarItem(placement: .navigationBarTrailing){
                    ConnectedDisconnectedView(connected: false)
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
    var connected: Bool
    
    var body: some View{
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
    }
}
