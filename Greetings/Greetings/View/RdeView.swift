import SwiftUI

struct RdeView: View {
    @EnvironmentObject var viewModel: ViewModel
    @EnvironmentObject var obd: MyOBD
    
    @Binding var dynamics: Dynamics
    
    var body: some View {
        ScrollView{
            VStack(spacing: 25){
                TopIndicatorsSection(dynamics: $dynamics)
//                    .border(Color.yellow)
                
                NOxSection()
//                    .border(Color.yellow)
                
                ForEach([Category.URBAN, Category.RURAL, Category.MOTORWAY], id: \.self) { terrain in
                    CategoryDistanceDynamicsSection(terrain: terrain)
//                        .border(Color.yellow)
                }
                
                StopRdeNavLink()
            }
        }
        .navigationBarItems(trailing: ConnectedDisconnectedView(connected: viewModel.model.isConnected))
        .navigationBarTitleDisplayMode(.inline)
        .foregroundColor(.gray)
        .font(.subheadline)
        .padding()
    }
    
    struct TopIndicatorsSection: View{
        @EnvironmentObject var obd: MyOBD
        
        @Binding var dynamics: Dynamics
        
        var body: some View{
            VStack{
                HStack(spacing: 20){
                    VStack{
                        Text("\(Int(dynamics.durationTotal))")
                            .font(.largeTitle)
                        Text("Total Time")
                    }
                    VStack{
                        Text("\(Int(dynamics.distanceTotal))")
                            .font(.largeTitle)
                        Text("Total Distance")
                    }
                }
                Spacer()
                Text("Valid RDE trip: \(obd.outputValues[17] == 1 ? "!" : "?")")
                    .font(.largeTitle)
            }
        }
    }

    struct NOxSection: View{
        @EnvironmentObject var obd: MyOBD
        
        var body: some View{
            VStack{
                Text("NOₓ")
                    .font(.title3)
                    .frame(maxWidth: .infinity, alignment: .leading)
                CapsuleView()
                Text("\(String(format: "%.2f", obd.outputValues[16])) mg/km")
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }

    struct CategoryDistanceDynamicsSection: View{
        @EnvironmentObject var obd: MyOBD
        
        var terrain: Category
        
        var body: some View{
            VStack{
                Text(terrain.rawValue)
                    .font(.title3)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                CapsuleView()
                
                HStack{
                    switch terrain{
                    case Category.URBAN:
                        Text("\(String(format: "%.2f", obd.outputValues[1])) km")
                        Spacer()
                        let seconds = Int(obd.outputValues[4])
                        let minutes = Int(seconds / 60)
                        let hours = Int(seconds / 3600)
                        Text("\(hours):\(minutes - hours * 60):\(seconds - hours * 3600 - minutes * 60)")
                    case Category.RURAL:
                        Text("\(String(format: "%.2f", obd.outputValues[2])) km")
                        Spacer()
                        let seconds = Int(obd.outputValues[5])
                        let minutes = Int(seconds / 60)
                        let hours = Int(seconds / 3600)
                        Text("\(hours):\(minutes - hours * 60):\(seconds - hours * 3600 - minutes * 60)")
                    case Category.MOTORWAY:
                        Text("\(String(format: "%.2f", obd.outputValues[3])) km")
                        Spacer()
                        let seconds = Int(obd.outputValues[6])
                        let minutes = Int(seconds / 60)
                        let hours = Int(seconds / 3600)
                        Text("\(hours):\(minutes - hours * 60):\(seconds - hours * 3600 - minutes * 60)")
                    }
                }
                
                HStack(alignment: .center){
                    Text("Dynamics")
                    CapsuleView()
                }
            }
        }
    }

    struct StopRdeNavLink: View{
        @EnvironmentObject var viewModel: ViewModel
        @EnvironmentObject var obd: MyOBD
        
        var body: some View{
            NavigationLink(destination: RdeLogView(), label: {
                Text("Stop RDE test")
                    .bold()
                    .font(.title2)
                    .frame(width: 280, height: 50)
                    .background(Color(.systemRed))
                    .foregroundColor(.white)
                    .cornerRadius(10)
            })
                .simultaneousGesture(TapGesture().onEnded{
                    obd.disconnect()
                    viewModel.model.isConnected = false
                })
        }
    }
}

//struct RdeView_Previews: PreviewProvider {
//    static var previews: some View {
//        RdeView()
//    }
//}
