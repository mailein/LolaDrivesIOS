import SwiftUI

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
            VStack{
                Image("elm_logo_green")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 25)
                Text("connected")
            }
            .foregroundColor(.green)
        }else{
            VStack{
                Image("elm_logo_red")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 25)
                Text("disconnected")
            }
            .foregroundColor(.red)
        }
    }
}
