import SwiftUI

struct RdeView: View {
    @EnvironmentObject var viewModel: ViewModel
    @EnvironmentObject var obd: MyOBD
    
    var body: some View {
        ScrollView{
            VStack(spacing: 25){
                let tu = obd.outputValues.count >= 5 ? obd.outputValues[4] : 0
                let tr = obd.outputValues.count >= 6 ? obd.outputValues[5] : 0
                let tm = obd.outputValues.count >= 7 ? obd.outputValues[6] : 0
                let distance = obd.outputValues.count >= 1 ? obd.outputValues[0] : 0
                let isValid = obd.outputValues.count >= 18 ? obd.outputValues[17] : 0
                let nox = obd.outputValues.count >= 17 ? obd.outputValues[16] : 0
                
                TopIndicatorsSection(t_u: tu, t_r: tr, t_m: tm, totalDistance: distance, isValidTest: isValid)
//                    .border(Color.yellow)
                
                NOxSection(noxAmount: nox)
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
        var t_u: Double//obd.outputValues[4,5,6] // in seconds
        var t_r: Double
        var t_m: Double
        var totalDistance: Double//obd.outputValues[0] // in meters
        var isValidTest: Double//obd.outputValues[17]
        
        var body: some View{
            VStack{
                HStack(spacing: 20){
                    VStack{
                        DurationText(durationInSeconds: t_u + t_r + t_m)
                            .font(.largeTitle)
                        Text("Total Time")
                    }
                    VStack{
                        DistanceText(distanceInMeters: totalDistance)
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
                    let distance = obd.outputValues.count >= 2 ? obd.outputValues[1] : 0
                    let totalDistance = obd.outputValues.count >= 1 ? obd.outputValues[0] : 0
                    let duration = obd.outputValues.count >= 5 ? obd.outputValues[4] : 0
                    let avgv = obd.outputValues.count >= 8 ? obd.outputValues[7] : 0
                    let rpa = obd.outputValues.count >= 14 ? obd.outputValues[13] : 0
                    let pct = obd.outputValues.count >= 11 ? obd.outputValues[10] : 0
                    
                    DistanceBar(category: .URBAN, distance: distance, totalDistance: totalDistance)
                    DistanceDurationText(distance: distance, durationInSeconds: duration)
                    DynamicsBar(terrain: .URBAN, avg_v: avgv, rpa: rpa, pct: pct)
                case .RURAL:
                    let distance = obd.outputValues.count >= 3 ? obd.outputValues[2] : 0
                    let totalDistance = obd.outputValues.count >= 1 ? obd.outputValues[0] : 0
                    let duration = obd.outputValues.count >= 6 ? obd.outputValues[5] : 0
                    let avgv = obd.outputValues.count >= 9 ? obd.outputValues[8] : 0
                    let rpa = obd.outputValues.count >= 15 ? obd.outputValues[14] : 0
                    let pct = obd.outputValues.count >= 12 ? obd.outputValues[11] : 0
                    
                    DistanceBar(category: .RURAL, distance: distance, totalDistance: totalDistance)
                    DistanceDurationText(distance: distance, durationInSeconds: duration)
                    DynamicsBar(terrain: .RURAL, avg_v: avgv, rpa: rpa, pct: pct)
                case .MOTORWAY:
                    let distance = obd.outputValues.count >= 4 ? obd.outputValues[3] : 0
                    let totalDistance = obd.outputValues.count >= 1 ? obd.outputValues[0] : 0
                    let duration = obd.outputValues.count >= 7 ? obd.outputValues[6] : 0
                    let avgv = obd.outputValues.count >= 10 ? obd.outputValues[9] : 0
                    let rpa = obd.outputValues.count >= 16 ? obd.outputValues[15] : 0
                    let pct = obd.outputValues.count >= 13 ? obd.outputValues[12] : 0
                    
                    DistanceBar(category: .MOTORWAY, distance: distance, totalDistance: totalDistance)
                    DistanceDurationText(distance: distance, durationInSeconds: duration)
                    DynamicsBar(terrain: .MOTORWAY, avg_v: avgv, rpa: rpa, pct: pct)
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
