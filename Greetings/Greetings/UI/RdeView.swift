import SwiftUI

struct RdeView: View {
    var obd: MyOBD
    
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
            
            Text("NOₓ")
                .frame(maxWidth: .infinity, alignment: .leading)
            CapsuleView()
            Text("0 mg/km")
                .frame(maxWidth: .infinity, alignment: .leading)
            
            ForEach(["Urban" , "Rural", "Motorway"], id: \.self) { terrain in
                Text("\(terrain)")
                    .frame(maxWidth: .infinity, alignment: .leading)
                CapsuleView()
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
        .onAppear(perform: obd.viewDidLoad)
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
            Text("NOₓ Emissions:")
        }
    }
}

struct CapsuleView: View{
    var barOffset: [Double] = [0, 0.5, 1]
    var ballOffset: [Double] = [0, 0.5, 1]
    
    var barWidth: CGFloat = 1
    var ballHeight: CGFloat = 10
    
    var body: some View{
        GeometryReader{ geometry in
            ZStack(alignment: .leading){
                Capsule()
                    .fill(Color.blue)
                    .frame(height: ballHeight)
                ForEach(barOffset, id: \.self){bar in
                    Rectangle()
                        .fill(Color.black)
                        .frame(width: barWidth, height: ballHeight)
                        .offset(x: bar * (geometry.size.width - barWidth), y: 0)
                }
                ForEach(ballOffset, id: \.self) {ball in
                    Circle()
                        .fill(Color.black)
                        .frame(width: ballHeight, height: ballHeight)
                        .offset(x: ball * (geometry.size.width - ballHeight), y: 0)
                }
            }
        }
//        .border(Color.yellow)
    }
}
