import SwiftUI

struct RdeView: View {
    @EnvironmentObject var viewModel: ViewModel
    @EnvironmentObject var obd: MyOBD
    
    var body: some View {
        ScrollView{
            VStack(spacing: 25){
                TopIndicatorsSection(t_u: obd.outputValues[4], t_r: obd.outputValues[5], t_m: obd.outputValues[6], totalDistance: obd.outputValues[0], isValidTest: obd.outputValues[17])
//                    .border(Color.yellow)
                
                NOxSection(noxAmount: obd.outputValues[16])
//                    .border(Color.yellow)
                
                CategoryDistanceDynamicsSection(terrain: Category.URBAN)
                CategoryDistanceDynamicsSection(terrain: Category.RURAL)
                CategoryDistanceDynamicsSection(terrain: Category.MOTORWAY)
                
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
        var t_u: Double//obd.outputValues[4,5,6]
        var t_r: Double
        var t_m: Double
        var totalDistance: Double//obd.outputValues[0]
        var isValidTest: Double//obd.outputValues[17]
        
        var body: some View{
            VStack{
                HStack(spacing: 20){
                    VStack{
                        Text("\(Int(t_u + t_r + t_m))")
                            .font(.largeTitle)
                        Text("Total Time")
                    }
                    VStack{
                        Text("\(Int(totalDistance))")
                            .font(.largeTitle)
                        Text("Total Distance")
                    }
                }
                Spacer()
                Text("Valid RDE trip: \(isValidTest == 1 ? "!" : "?")")
                    .font(.largeTitle)
            }
        }
    }

    struct NOxSection: View{
        //literals
        let barLow: Double = 0.12//g/km
        let barHigh: Double = 0.168//g/km
        let barMax: Double = 0.2//g/km
        
        var noxAmount: Double //mg/km //obd.outputValues[16]
        
        var body: some View{
            VStack{
                Text("NOₓ")
                    .font(.title3)
                    .frame(maxWidth: .infinity, alignment: .leading)
                CapsuleView(barOffset: [barLow / barMax, barHigh / barMax], ballOffset: [0.001 * noxAmount / barMax])
                Text("\(String(format: "%.2f", noxAmount)) mg/km")
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
                
                switch terrain {
                case .URBAN:
                    DistanceBar(category: .URBAN, distance: obd.outputValues[1], totalDistance: obd.outputValues[0])
                    DistanceDurationText(distance: obd.outputValues[1], durationInSeconds: obd.outputValues[4])
                    DynamicsBar(terrain: .URBAN, avg_v: obd.outputValues[7], rpa: obd.outputValues[13], pct: obd.outputValues[10])
                case .RURAL:
                    DistanceBar(category: .RURAL, distance: obd.outputValues[2], totalDistance: obd.outputValues[0])
                    DistanceDurationText(distance: obd.outputValues[2], durationInSeconds: obd.outputValues[5])
                    DynamicsBar(terrain: .RURAL, avg_v: obd.outputValues[8], rpa: obd.outputValues[14], pct: obd.outputValues[11])
                case .MOTORWAY:
                    DistanceBar(category: .MOTORWAY, distance: obd.outputValues[3], totalDistance: obd.outputValues[0])
                    DistanceDurationText(distance: obd.outputValues[3], durationInSeconds: obd.outputValues[6])
                    DynamicsBar(terrain: .MOTORWAY, avg_v: obd.outputValues[9], rpa: obd.outputValues[15], pct: obd.outputValues[12])
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

struct RdeView_Previews: PreviewProvider {
    static var previews: some View {
        RdeView()
    }
}
