import SwiftUI
import SwiftUICharts
import pcdfcore

struct ChartsView: View {
    var file: URL
    @StateObject private var eventStore = EventStore()
    
    var body: some View {
        ScrollView{
            BarChartView(data: ChartData(values: eventStore.avgNoxAtFuelrate), title: "avg(nox)[mg] at fuel rate[l/h]", form: ChartForm.extraLarge, dropShadow: false, valueSpecifier: "%.2f")
            BarChartView(data: ChartData(values: eventStore.avgFuelrateAtSpeed), title: "avg(fuel rate)[l/h] at speed[km/h]", form: ChartForm.extraLarge, dropShadow: false, valueSpecifier: "%.2f")
            if !eventStore.speedValues.isEmpty {
                LineChartView(data: eventStore.speedValues, title: "speed[km/h]", form: ChartForm.extraLarge, rateValue: 0, dropShadow: false, valueSpecifier: "%.0f")
            } else {
                Text("speed chart not available")
            }
            if !eventStore.noxValues.isEmpty {
                LineChartView(data: eventStore.noxValues, title: "nox[ppm]", form: ChartForm.extraLarge, rateValue: 0, dropShadow: false, valueSpecifier: "%.0f")
            } else {
                Text("nox chart not available")
            }
        }
        .onAppear{
            //reset upon different files
            eventStore.resetValues()
            
            EventStore.load(fileURL: file) { result in
                if case .success(let events) = result {
                    //altitude
                    let gpsEvents: [GPSEvent] = events
                        .filter{ $0.type == pcdfcore.EventType.gps }
                        .map{ $0 as! GPSEvent }
                    eventStore.altitudeValues = gpsEvents
                        .map{ $0.altitude }
                    
                    //speed, nox, fuelrate
                    let reducedEvents: [OBDIntermediateEvent] = events
                        .filter{ $0.type == pcdfcore.EventType.obdResponse }
                        .map{
                            let rEvent = ($0 as! OBDEvent).toIntermediate()
                            return MultiSensorReducer().reduce(event: rEvent) as! OBDIntermediateEvent
                        }
                    eventStore.speedValues = reducedEvents
                        .filter{ $0 is pcdfcore.SpeedEvent }
                        .map{ Double(($0 as! SpeedEvent).speed) }
                    eventStore.noxValues = reducedEvents
                        .filter{ $0 is pcdfcore.NOXReducedEvent }
                        .map{ Double(($0 as! NOXReducedEvent).nox_ppm) }
                    eventStore.fuelrateValues = reducedEvents
                        .filter{ $0 is FuelRateReducedEvent }
                        .map{ ($0 as! FuelRateReducedEvent).fuelRate }
                    
                    //avg(nox) at fuelrate, avg(fuelrate) at speed
                    let rdeValidator = RDEValidator()
                    do {
                        eventStore.outputs = try rdeValidator.monitorOfflineFinalOutput(data: events)
                        
                        var keyPrefix = "nox_avg_at_fuel_rate_"
                        var scaler = 1000
                        eventStore.avgNoxAtFuelrate = extract(from: eventStore.outputs, keyPrefix: keyPrefix, scaler: scaler)
                        print("avg(nox) at fuelrate: \(eventStore.avgNoxAtFuelrate)")
                        
                        keyPrefix = "fuel_rate_avg_at_speed_"
                        scaler = 1
                        eventStore.avgFuelrateAtSpeed = extract(from: eventStore.outputs, keyPrefix: keyPrefix, scaler: scaler)
                        print("avg(fuelrate) at speed: \(eventStore.avgNoxAtFuelrate)")
                    } catch {
                        print(error.localizedDescription)
                    }
                    print("rde result successfully loaded \(events.count) events")
                }
            }
        }
    }
    
    func extract(from outputs: [String: Double], keyPrefix: String, scaler: Int) -> [(String, Double)] {
        let ret = outputs
            .filter{ $0.key.contains(keyPrefix) }
            .map{ ($0.key.replacingOccurrences(of: keyPrefix, with: ""), $0.value * Double(scaler)) } //nox in mg
            .sorted(by: { (a, b) in
                return Int(a.0.components(separatedBy: "_")[0]) ?? 0 < Int(b.0.components(separatedBy: "_")[0]) ?? 0
            })
        return ret
    }
}
