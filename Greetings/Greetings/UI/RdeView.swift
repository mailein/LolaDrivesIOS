import SwiftUI

struct RdeView: View {
    var totalTime : Int = 0
    var totalDistance : Int = 0
    var validRdeTrip : Bool = false
    var body: some View {
        VStack{
            HStack{
                VStack{
                    Text("\(totalTime)")
                    Text("Total Time")
                }
                VStack{
                    Text("\(totalDistance)")
                    Text("Total Distance")
                }
            }
            Text("Valid RDE trip\(validRdeTrip ? "!" : "?")")
            
            Text("NOx")
                .frame(maxWidth: .infinity, alignment: .leading)
            CapsuleView(barOffset: [0.75, 0.9])
            Text("0 mg/km")
                .frame(maxWidth: .infinity, alignment: .leading)
            
            ForEach(["Urban" , "Rural", "Motorway"], id: \.self) { terrain in
                Text("\(terrain)")
                    .frame(maxWidth: .infinity, alignment: .leading)
                CapsuleView(barOffset: [0.75, 0.9])
                HStack{
                    Text("0 mg/km")
                    Spacer()
                    Text("00:00:00")
                }
                HStack{
                    Text("Dynamics")
                    CapsuleView()
                }
            }
            
            NavigationLink(destination: RdeLogView(), label: {
                Text("Stop RDE test")
                    .bold()
                    .font(.title2)
                    .frame(width: 280, height: 50)
                    .background(Color(.systemRed))
                    .foregroundColor(.white)
                    .cornerRadius(10)
            })
        }
        .navigationBarItems(trailing: ConnectedDisconnectedView(connected: false))
        .foregroundColor(.gray)
        .font(.subheadline)
        .padding(30)
    }
}

struct RdeLogView: View{
    var body: some View{
        TabView{
            RdeEventLogView()
                .tabItem{
                    Text("Event Log")
                }
        }
        .navigationBarItems(trailing: ConnectedDisconnectedView(connected: false))
    }
}

struct RdeEventLogView: View{
    var body: some View{
        VStack{
            Text("Valid RDE Trip:")
            Text("Total Duration:")
            Text("Total Distance:")
            Text("NOx Emissions:")
        }
    }
}

struct CapsuleView: View{
    var barOffset: [Double] = []
    var ballOffset: [Double] = []
    
    var body: some View{
        GeometryReader{ geometry in
            ZStack{
                Capsule()
                    .fill(Color.blue)
                Rectangle()
                    .frame(width: 1)
                Circle()
                    .fill(Color.white)
                    .frame(width: 10, height: 10)
                    .offset(x: -0.1 * geometry.size.width, y: 0)
            }
        }
    }
}
