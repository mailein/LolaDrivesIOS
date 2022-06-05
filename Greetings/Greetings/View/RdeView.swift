import SwiftUI

struct RdeView: View {
    @EnvironmentObject var viewModel: ViewModel
    @EnvironmentObject var obd: MyOBD
    
    var body: some View {
        ScrollView{
            VStack(spacing: 25){
                let tu: Double = !obd.outputValues.keys.contains("t_u") ? 0 : obd.outputValues["t_u"]!
                let tr: Double = !obd.outputValues.keys.contains("t_r") ? 0 : obd.outputValues["t_r"]!
                let tm: Double = !obd.outputValues.keys.contains("t_m") ? 0 : obd.outputValues["t_m"]!
                let distance: Double = !obd.outputValues.keys.contains("d") ? 0 : obd.outputValues["d"]!
                let isValid: Double = !obd.outputValues.keys.contains("is_valid_test") ? 0 : obd.outputValues["is_valid_test"]!
                let nox: Double = !obd.outputValues.keys.contains("nox_per_kilometer") ? 0 : obd.outputValues["nox_per_kilometer"]!
                
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
                ConnectedDisconnectedView(connected: obd.isConnected())
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .foregroundColor(.gray)
        .font(.subheadline)
        .padding([.bottom, .horizontal])
    }
    
    struct TopIndicatorsSection: View{
        @EnvironmentObject var viewModel: ViewModel
        var t_u: Double//obd.outputValues[4,5,6] // in seconds
        var t_r: Double
        var t_m: Double
        var totalDistance: Double//obd.outputValues[0] // in meters
        var isValidTest: Double//obd.outputValues[17]
        
        var body: some View{
            VStack{
                HStack(spacing: 20){
                    VStack{
                        DurationText(durationInSeconds: Int64(t_u + t_r + t_m))
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
        
        var noxAmount: Double //g/km //obd.outputValues[16]
        
        var body: some View{
            VStack{
                Text("NOₓ")
                    .font(.title3)
                    .frame(maxWidth: .infinity, alignment: .leading)
                let ball = noxAmount / barMax
                CapsuleView(barOffset: [barLow / barMax, barHigh / barMax], ballOffset: [], width: ball)
                Text("\(String(format: "%.2f", 1000 * noxAmount)) mg/km")
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }

    struct CategoryDistanceDynamicsSection: View{
        @EnvironmentObject var viewModel: ViewModel
        @EnvironmentObject var obd: MyOBD
        var terrain: Category
        
        var body: some View{
            VStack{
                Text(terrain.rawValue)
                    .font(.title3)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                switch terrain {
                case .URBAN:
                    let distance = !obd.outputValues.keys.contains("d_u") ? 0 : obd.outputValues["d_u"]!
                    let totalDistance = viewModel.getDistanceSetting()
                    let duration = !obd.outputValues.keys.contains("t_u") ? 0 : obd.outputValues["t_u"]!
                    let avgv = !obd.outputValues.keys.contains("u_avg_v") ? 0 : obd.outputValues["u_avg_v"]!
                    let rpa = !obd.outputValues.keys.contains("u_rpa") ? 0 : obd.outputValues["u_rpa"]!
                    let pct = !obd.outputValues.keys.contains("u_va_pct") ? 0 : obd.outputValues["u_va_pct"]!
                    
                    DistanceBar(category: .URBAN, distance: distance, totalDistance: totalDistance)
                    DistanceDurationText(distance: distance, durationInSeconds: duration)
                    DynamicsBar(terrain: .URBAN, avg_v: avgv, rpa: rpa, pct: pct)
                case .RURAL:
                    let distance = !obd.outputValues.keys.contains("d_r") ? 0 : obd.outputValues["d_r"]!
                    let totalDistance = viewModel.getDistanceSetting()
                    let duration = !obd.outputValues.keys.contains("t_r") ? 0 : obd.outputValues["t_r"]!
                    let avgv = !obd.outputValues.keys.contains("r_avg_v") ? 0 : obd.outputValues["r_avg_v"]!
                    let rpa = !obd.outputValues.keys.contains("r_rpa") ? 0 : obd.outputValues["r_rpa"]!
                    let pct = !obd.outputValues.keys.contains("r_va_pct") ? 0 : obd.outputValues["r_va_pct"]!
                    
                    DistanceBar(category: .RURAL, distance: distance, totalDistance: totalDistance)
                    DistanceDurationText(distance: distance, durationInSeconds: duration)
                    DynamicsBar(terrain: .RURAL, avg_v: avgv, rpa: rpa, pct: pct)
                case .MOTORWAY:
                    let distance = !obd.outputValues.keys.contains("d_m") ? 0 : obd.outputValues["d_m"]!
                    let totalDistance = viewModel.getDistanceSetting()
                    let duration = !obd.outputValues.keys.contains("t_m") ? 0 : obd.outputValues["t_m"]!
                    let avgv = !obd.outputValues.keys.contains("m_avg_v") ? 0 : obd.outputValues["m_avg_v"]!
                    let rpa = !obd.outputValues.keys.contains("m_rpa") ? 0 : obd.outputValues["m_rpa"]!
                    let pct = !obd.outputValues.keys.contains("m_va_pct") ? 0 : obd.outputValues["m_va_pct"]!
                    
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
