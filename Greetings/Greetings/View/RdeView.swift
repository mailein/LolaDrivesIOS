import SwiftUI

struct RdeView: View {
    @EnvironmentObject var viewModel: ViewModel
    @EnvironmentObject var obd: MyOBD
    
    var body: some View {
        ScrollView{
            VStack(spacing: 25){
                let tu: Double = obd.outputValues.isEmpty ? 0 : obd.outputValues[4] //TODO: get by name instead of index
                let tr: Double = obd.outputValues.isEmpty ? 0 : obd.outputValues[5]
                let tm: Double = obd.outputValues.isEmpty ? 0 : obd.outputValues[6]
                let distance: Double = obd.outputValues.isEmpty ? 0 : obd.outputValues[0]
                let isValid: Double = obd.outputValues.isEmpty ? 0 : obd.outputValues[17]
                let nox: Double = obd.outputValues.isEmpty ? 0 : obd.outputValues[16]
                
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
        .toolbar{
            ToolbarItem(placement: .navigationBarTrailing){
                ConnectedDisconnectedView(connected: obd.isConnected)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .foregroundColor(.gray)
        .font(.subheadline)
        .padding([.bottom, .horizontal])
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
                    let distance = obd.outputValues.isEmpty ? 0 : obd.outputValues[1] //TODO: get by name instead of index
                    let totalDistance = obd.outputValues.isEmpty ? 0 : obd.outputValues[0]
                    let duration = obd.outputValues.isEmpty ? 0 : obd.outputValues[4]
                    let avgv = obd.outputValues.isEmpty ? 0 : obd.outputValues[7]
                    let rpa = obd.outputValues.isEmpty ? 0 : obd.outputValues[13]
                    let pct = obd.outputValues.isEmpty ? 0 : obd.outputValues[10]
                    
                    DistanceBar(category: .URBAN, distance: distance, totalDistance: totalDistance)
                    DistanceDurationText(distance: distance, durationInSeconds: duration)
                    DynamicsBar(terrain: .URBAN, avg_v: avgv, rpa: rpa, pct: pct)
                case .RURAL:
                    let distance = obd.outputValues.isEmpty ? 0 : obd.outputValues[2]
                    let totalDistance = obd.outputValues.isEmpty ? 0 : obd.outputValues[0]
                    let duration = obd.outputValues.isEmpty ? 0 : obd.outputValues[5]
                    let avgv = obd.outputValues.isEmpty ? 0 : obd.outputValues[8]
                    let rpa = obd.outputValues.isEmpty ? 0 : obd.outputValues[14]
                    let pct = obd.outputValues.isEmpty ? 0 : obd.outputValues[11]
                    
                    DistanceBar(category: .RURAL, distance: distance, totalDistance: totalDistance)
                    DistanceDurationText(distance: distance, durationInSeconds: duration)
                    DynamicsBar(terrain: .RURAL, avg_v: avgv, rpa: rpa, pct: pct)
                case .MOTORWAY:
                    let distance = obd.outputValues.isEmpty ? 0 : obd.outputValues[3]
                    let totalDistance = obd.outputValues.isEmpty ? 0 : obd.outputValues[0]
                    let duration = obd.outputValues.isEmpty ? 0 : obd.outputValues[6]
                    let avgv = obd.outputValues.isEmpty ? 0 : obd.outputValues[9]
                    let rpa = obd.outputValues.isEmpty ? 0 : obd.outputValues[15]
                    let pct = obd.outputValues.isEmpty ? 0 : obd.outputValues[12]
                    
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
                })
        }
    }
}
