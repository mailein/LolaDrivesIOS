import Foundation

func specFile(filename: String) -> String{
    // file name and file type
    let filenameAndType = filename.components(separatedBy: ".")
    var name = filenameAndType[0]
    let type = filenameAndType[1]
    if(filenameAndType.count != 2){
        for (n, x) in filenameAndType.enumerated(){
            if (n != 0 && n != filenameAndType.count - 1) {
                name += "." + x
            }
        }
    }
    // file path
    let bundle = Bundle.main
    let path = bundle.path(forResource: name, ofType: type)
//    print(path!)
    
    do {
        return try String(contentsOf: URL(fileURLWithPath: path!), encoding: .utf8)
    }
    catch {
        return "error! Can't read specFile \(filename)"
    }
}

extension BinaryInteger {
    var binaryDescription: String {
        var binaryString = ""
        var internalNumber = self
        for _ in (1...self.bitWidth) {
            binaryString.insert(contentsOf: "\(internalNumber & 1)", at: binaryString.startIndex)
            internalNumber >>= 1
        }
        return binaryString
    }
}

func genCustomSpec(format: String, lastLineFormat: String, nameFormat: String, nameLastLineFormat: String, start: Int, end: Int, step: Int) -> (String, [String]) {
    var str = "\n"
    var names: [String] = []
    for i in stride(from: start, to: end, by: step) {
        str += String(format: format, "\(i)", "\(i+step)")
        str += "\n"
        names.append(String(format: nameFormat, "\(i)", "\(i+step)"))
    }
    str += String(format: lastLineFormat, "\(end)")
    names.append(String(format: nameLastLineFormat, "\(end)"))
    
    return (str, names)
}

func genCustomSpecNoxAvgAtFuelRate() -> (String, [String]) {
    let isFuelRateFormat = "output is_fuel_rate_%1$@_%2$@: Bool := (fuel_ratep >= %1$@.0) && (fuel_ratep < %2$@.0)"
    let noxAtFuelRateFormat = "output nox_at_fuel_rate_%1$@_%2$@_h: Float64 @1Hz := if is_fuel_rate_%1$@_%2$@ then D_nox_mass else 0.0"
    let noxAvgAtFuelRateFormat = "output nox_avg_at_fuel_rate_%1$@_%2$@: Float64 @1Hz := nox_at_fuel_rate_%1$@_%2$@_h.aggregate(over: 2h, using: avg).defaults(to: 0.0)"
    
    let isFuelRateLastLineFormat = "output is_fuel_rate_%1$@_or_more: Bool := fuel_ratep >= %1$@.0"
    let noxAtFuelRateLastLineFormat = "output nox_at_fuel_rate_%1$@_or_more_h: Float64 @1Hz := if is_fuel_rate_%1$@_or_more then D_nox_mass else 0.0"
    let noxAvgAtFuelRateLastLineFormat = "output nox_avg_at_fuel_rate_%1$@_or_more: Float64 @1Hz := nox_at_fuel_rate_%1$@_or_more_h.aggregate(over: 2h, using: avg).defaults(to: 0.0)"
    
    let nameFormat = "nox_avg_at_fuel_rate_%1$@_%2$@"
    let nameLastLineFormat = "nox_avg_at_fuel_rate_%1$@_or_more"
    
    let format = "\(isFuelRateFormat)\n\(noxAtFuelRateFormat)\n\(noxAvgAtFuelRateFormat)"
    let lastLineFormat = "\(isFuelRateLastLineFormat)\n\(noxAtFuelRateLastLineFormat)\n\(noxAvgAtFuelRateLastLineFormat)"
    
    let (spec, names) = genCustomSpec(format: format, lastLineFormat: lastLineFormat, nameFormat: nameFormat, nameLastLineFormat: nameLastLineFormat, start: 0, end: 25, step: 1)
    
    return (spec, names)
}

func genCustomSpecFuelRateAvgAtSpeed() -> (String, [String]) {
    let isSpeedFormat = "output is_speed_%1$@_%2$@: Bool := (vp >= %1$@.0) && (vp < %2$@.0)"
    let fuelRateAtSpeedFormat = "output fuel_rate_at_speed_%1$@_%2$@: Float64 @1Hz := if is_speed_%1$@_%2$@ then fuel_ratep else 0.0"
    let fuelRateAvgAtSpeedFormat = "output fuel_rate_avg_at_speed_%1$@_%2$@: Float64 @1Hz := fuel_rate_at_speed_%1$@_%2$@.aggregate(over: 2h, using: avg).defaults(to: 0.0)"
    
    let isSpeedLastLineFormat = "output is_speed_%1$@_or_more: Bool := (vp >= %1$@.0)"
    let fuelRateAtSpeedLastLineFormat = "output fuel_rate_at_speed_%1$@_or_more: Float64 @1Hz := if is_speed_%1$@_or_more then fuel_ratep else 0.0"
    let fuelRateAvgAtSpeedLastLineFormat = "output fuel_rate_avg_at_speed_%1$@_or_more: Float64 @1Hz := fuel_rate_at_speed_%1$@_or_more.aggregate(over: 2h, using: avg).defaults(to: 0.0)"
    
    let nameFormat = "fuel_rate_avg_at_speed_%1$@_%2$@"
    let nameLastLineFormat = "fuel_rate_avg_at_speed_%1$@_or_more"
    
    let format = "\(isSpeedFormat)\n\(fuelRateAtSpeedFormat)\n\(fuelRateAvgAtSpeedFormat)"
    let lastLineFormat = "\(isSpeedLastLineFormat)\n\(fuelRateAtSpeedLastLineFormat)\n\(fuelRateAvgAtSpeedLastLineFormat)"
    
    let (spec, names) = genCustomSpec(format: format, lastLineFormat: lastLineFormat, nameFormat: nameFormat, nameLastLineFormat: nameLastLineFormat, start: 0, end: 255, step: 5)
    
    return (spec, names)
}


