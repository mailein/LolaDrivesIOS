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
            if eventStore.speedValues.count != 0 {
                LineChartView(data: eventStore.speedValues, title: "speed[km/h]", form: ChartForm.extraLarge, rateValue: 0, dropShadow: false, valueSpecifier: "%.0f")
            }
            if eventStore.noxValues.count != 0 {
                LineChartView(data: eventStore.noxValues, title: "nox[ppm]", form: ChartForm.extraLarge, rateValue: 0, dropShadow: false, valueSpecifier: "%.0f")
            }
        }
        .onAppear{
            EventStore.load(fileURL: file) { result in
                if case .success(let events) = result {
                    let reducedEvents: [OBDIntermediateEvent?] = events
                        .map{
                            let rEvent = ($0 as? OBDEvent)?.toIntermediate()
                            if let rEvent = rEvent {
                                return MultiSensorReducer().reduce(event: rEvent) as? OBDIntermediateEvent
                            } else {
                                return nil
                            }
                        }
                    if reducedEvents.filter{ $0 != nil }.count == 0 {
                        eventStore.speedValues = []
                        eventStore.noxValues = []
                    } else {
                        eventStore.speedValues = reducedEvents
                            .filter{ $0 != nil && $0 is pcdfcore.SpeedEvent }
                            .map{ Double(($0 as! SpeedEvent).speed) }
                        eventStore.noxValues = reducedEvents
                            .filter{ $0 != nil && $0 is pcdfcore.NOXReducedEvent }
                            .map{ Double(($0 as! NOXReducedEvent).nox_ppm) }
                    }
                }
            }
        }
    }
}
