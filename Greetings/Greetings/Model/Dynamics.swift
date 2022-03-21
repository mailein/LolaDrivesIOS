import Foundation
import SwiftUI
        
struct DistanceBar: View{
    //literals
    private let barLowUrban: Double = 0.29
    private let barHighUrban: Double = 0.44
    private let barLowRuralMotorway: Double = 0.23
    private let barHighRuralMotorway: Double = 0.43
    private let barMax: Double = 0.5
    
    var category: Category
    var distance: Double//d-u/r/m //obd.outputValues[1,2,3]
    var totalDistance: Double//d //obd.outputValues[0]
    
    //computed properties
    var barLow: Double {
        get{
            switch category {
            case .URBAN: return barLowUrban
            case .RURAL, .MOTORWAY: return barLowRuralMotorway
            }
        }
    }
    var barHigh: Double {
        get{
            switch category {
            case .URBAN: return barHighUrban
            case .RURAL, .MOTORWAY: return barHighRuralMotorway
            }
        }
    }
    
    var body: some View{
        CapsuleView(barOffset: [barLow / barMax, barHigh / barMax], ballOffset: [totalDistance == 0 ? 0 : barMax * distance / totalDistance])
    }
}

struct DistanceDurationText: View {
    let distance: Double//obd.outputValues[1,2,3]
    let durationInSeconds: Double//t-u/r/m
    let seconds: Int//obd.outputValues[4,5,6]
    let minutes: Int
    let hours: Int
    
    init (distance: Double, durationInSeconds: Double){
        self.distance = distance
        self.durationInSeconds = durationInSeconds
        self.seconds = Int(durationInSeconds)
        self.minutes = Int(seconds / 60)
        self.hours = Int(seconds / 3600)
    }
    
    var body: some View{
        HStack{
            Text("\(String(format: "%.2f", distance)) km")
            Spacer()
            Text("\(hours):\(minutes - hours * 60):\(seconds - hours * 3600 - minutes * 60)")
        }
    }
}

struct DynamicsBar: View{
    //literals
    let barMiddle: Double = 0.5
    let maxRpa = 0.3 // Realistic maximum RPA
    let maxPct = 35.0
    
    var terrain: Category
    let avg_v: Double //obd.outputValues[7,8,9]
    let rpa: Double //obd.outputValues[13,14,15]
    let pct: Double //obd.outputValues[10,11,12]
    
    // Calculate Horizontal Marker Positions
    let rpaThreshold: Double
    let rpaMarkerPercentage: Double
    let ballRpa: Double
    // Calculate Horizontal Marker Positions
    let pctThreshold: Double
    let pctMarkerPercentage: Double
    let ballPct: Double
    
    init(terrain: Category, avg_v: Double, rpa: Double, pct: Double){
        self.terrain = terrain
        self.avg_v = avg_v
        self.rpa = rpa
        self.pct = pct
        
        switch terrain {
        case .URBAN:
            rpaThreshold = -0.0016 * avg_v + 0.1755
            pctThreshold = 0.136 * avg_v + 14.44
        case .RURAL:
            rpaThreshold = -0.0016 * avg_v + 0.1755
            pctThreshold = avg_v <= 74.6 ? 0.136 * avg_v + 14.44 : 0.0742 * avg_v + 18.966
        case .MOTORWAY:
            rpaThreshold = avg_v <= 94.05 ? -0.0016 * avg_v + 0.1755 : 0.025
            pctThreshold = 0.0742 * avg_v + 18.966
        }
        rpaMarkerPercentage = rpaThreshold / maxRpa
        ballRpa = barMiddle * rpa / maxRpa
        pctMarkerPercentage = pctThreshold / maxPct
        ballPct = barMiddle + barMiddle * pct / maxPct
    }
    
    var body: some View{
        HStack(alignment: .center){
            Text("Dynamics")
            
            CapsuleView(barOffset: [rpaMarkerPercentage, barMiddle, pctMarkerPercentage], ballOffset: [ballRpa, ballPct])
        }
    }
    
}

enum Category: String{// no comma for enum case in Swift
    case URBAN = "Urban"
    case RURAL = "Rural"
    case MOTORWAY = "Motorway"
}
