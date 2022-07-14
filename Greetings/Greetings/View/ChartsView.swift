import SwiftUI
import SwiftUICharts
import pcdfcore

struct ChartsView: View {
    var file: URL
    @StateObject private var eventStore = EventStore()
    
    var body: some View {
        ScrollView{
            ChartView(file: file, title: "avg(nox)[mg] at fuel rate[l/h]", keyPrefix: "nox_avg_at_fuel_rate_", scaler: 1000)
            ChartView(file: file, title: "avg(fuel rate)[l/h] at speed[km/h]", keyPrefix: "fuel_rate_avg_at_speed_", scaler: 1)
            if !eventStore.speedValues.isEmpty {
                LineChartView(data: eventStore.speedValues, title: "speed[km/h]", form: ChartForm.extraLarge, rateValue: 0, dropShadow: false, valueSpecifier: "%.0f")
            }
            if !eventStore.noxValues.isEmpty {
                LineChartView(data: eventStore.noxValues, title: "nox[ppm]", form: ChartForm.extraLarge, rateValue: 0, dropShadow: false, valueSpecifier: "%.0f")
            }
        }
        .onAppear{
            //reset upon different files
            eventStore.resetValues()
            
            EventStore.load(fileURL: file) { result in
                if case .success(let events) = result {
                    let gpsEvents: [GPSEvent] = events
                        .filter{ $0.type == pcdfcore.EventType.gps }
                        .map{ $0 as! GPSEvent }
                    eventStore.altitudeValues = gpsEvents
                        .map{ $0.altitude }
                    
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
                }
            }
        }
    }
}
