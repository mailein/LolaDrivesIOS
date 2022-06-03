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
    var totalDistance: Int//distance setting in RdeSettingsView
    
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
        CapsuleView(barOffset: [barLow / barMax, barHigh / barMax],
                    ballOffset: [],
                    width: totalDistance == 0 ? 0 : (distance / Double(totalDistance * 1000))  / barMax)//km*1000=m
    }
}

struct DistanceDurationText: View {
    let distanceInMeters: Double//obd.outputValues[1,2,3]
    let durationInSeconds: Double//t-u/r/m
    
    init (distance: Double, durationInSeconds: Double){
        self.distanceInMeters = distance
        self.durationInSeconds = durationInSeconds
    }
    
    var body: some View{
        HStack{
            DistanceText(distanceInMeters: distanceInMeters)
            Spacer()
            DurationText(durationInSeconds: Int64(durationInSeconds))
        }
    }
}

struct DistanceText: View{
    let distanceInMeters: Double
    
    var body: some View{
        if distanceInMeters < 1000 {
            Text("\(Int(distanceInMeters)) m")
        }else{
            Text("\(String(format: "%.2f", distanceInMeters / 1000)) km")
        }
    }
}

struct DurationText: View{
    let durationInSeconds: Int64
    
    var body: some View{
        let h = seconds2Hours(durationInSeconds)
        let m = seconds2Minutes(durationInSeconds)
        let s = seconds2Seconds(durationInSeconds)
        Text("\(String(format: "%02d", h)):\(String(format: "%02d", m)):\(String(format: "%02d", s))")
    }
    
    private func seconds2Seconds(_ seconds: Int64)-> Int{
        return Int(seconds % 60)
    }
    
    private func seconds2Minutes(_ seconds: Int64)-> Int{
        let min = seconds / 60
        return Int(min % 60)
    }
    
    private func seconds2Hours(_ seconds: Int64)-> Int{
        return Int(seconds / 3600)
    }
}

struct DynamicsBar: View{
    //literals
    let offsetRpa = 0.35 // GuidelineDynamicsBarLow Percentage
    let boundaryRpa = 0.605
    let lengthRpa: Double
    let offsetPct = 0.62
    let boundaryPct = 0.88
    let lengthPct: Double
    
    let maxRpa = 0.3 // Realistic maximum RPA
    let maxPct = 35.0
    
    var terrain: Category
    let avg_v: Double //obd.outputValues[7,8,9]
    let _rpa: Double //obd.outputValues[13,14,15]
    let _pct: Double //obd.outputValues[10,11,12]
    
    // Calculate Horizontal Marker Positions
    let rpaThreshold: Double
    let rpaMarkerPercentage: Double
    let ballRpa: Double
    // Calculate Horizontal Marker Positions
    let pctThreshold: Double
    let pctMarkerPercentage: Double
    let ballPct: Double
    
    init(terrain: Category, avg_v: Double, rpa: Double, pct: Double){
        lengthRpa = boundaryRpa - offsetRpa
        lengthPct = boundaryPct - offsetPct
        
        self.terrain = terrain
        self.avg_v = avg_v
        self._rpa = rpa > maxRpa ? 0 : rpa
        self._pct = pct > maxPct ? 0 : pct
        
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
        rpaMarkerPercentage = lengthRpa * rpaThreshold / maxRpa + offsetRpa
        ballRpa = lengthRpa * self._rpa / maxRpa + boundaryRpa
        pctMarkerPercentage = lengthPct * pctThreshold / maxPct + offsetPct
        ballPct = lengthPct * self._pct / maxPct + boundaryPct
    }
    
    var body: some View{
        HStack(alignment: .center){
            Text("Dynamics")
            CapsuleView(barOffset: [rpaMarkerPercentage], ballOffset: [ballRpa])
            CapsuleView(barOffset: [pctMarkerPercentage], ballOffset: [ballPct])
        }
    }
    
}

enum Category: String{// no comma for enum case in Swift
    case URBAN = "Urban"
    case RURAL = "Rural"
    case MOTORWAY = "Motorway"
}
