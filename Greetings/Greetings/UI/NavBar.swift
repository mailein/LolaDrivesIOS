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
                Image(systemName: "lightbulb")
                Text("connected")
            }
            .foregroundColor(.green)
        }else{
            VStack{
                Image(systemName: "lightbulb.slash")
                Text("disconnected")
            }
            .foregroundColor(.red)
        }
    }
}
