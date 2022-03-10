import Foundation
import SwiftUI

struct Dynamics{
    private(set) var durationTotal: Double
    private(set) var distanceTotal: Double
    var noxBar = NoxBar()
    var distanceBarUrban: DistanceBar = DistanceBar(category: .URBAN)
    var dynamicsRPABarUrban: DynamicsRPABar = DynamicsRPABar(category: .URBAN)
    
    mutating func setDuration (to newDuration: Double) {
        self.durationTotal = newDuration
    }
    
    mutating func setDistance (to newDistance: Double) {
        self.distanceTotal = newDistance
    }
    
    mutating func setNox (to newNox: Double) {
        self.noxBar.setNoxAmount(to: newNox)
    }
    
    //TODO: other func
}

struct NoxBar{
    //literals
    let barLow: Double = 0.12//g/km
    let barHigh: Double = 0.168//g/km
    let barMax: Double = 0.2//g/km
    
    var noxAmount: Double = 0 //mg/km
    
    mutating func setNoxAmount (to newNoxAmount: Double) {
        self.noxAmount = newNoxAmount
    }
}
        
struct DistanceBar{
    //literals
    private let barLowUrban: Double = 0.29
    private let barLowRuralMotorway: Double = 0.23
    private let barHighUrban: Double = 0.44
    private let barHighRuralMotorway: Double = 0.43
    
    var category: Category
    var distance: Double = 0//d-u/r/m
    var duration: Double = 0//t-u/r/m
    
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
    var durationHour: Int {
        get{
            (Int)(duration / (60 * 60))
        }
    }
    var durationMinute: Int {
        get{
            (Int)((duration - floor(duration / (60 * 60)) * (60 * 60)) / 60)
        }
    }
    var durationSecond: Int {
        get{
            (Int)(duration.truncatingRemainder(dividingBy: 60))
        }
    }
}

struct DynamicsRPABar{
    //literals
    let barCenter: Double = 0.5
    
    var category: Category
    var barLow: Double = 0.25//RPA threashold
    var barHigh: Double = 0.75//PCT95 threashold
    var ballLow: Double = 0//RPA
    var ballHigh: Double = 0.5//PCT95
}

enum Category: String{// no comma for enum case in Swift
    case URBAN = "urban"
    case RURAL = "rural"
    case MOTORWAY = "motorway"
}
