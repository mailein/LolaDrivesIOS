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
                LineChartView(data: eventStore.speedValues, title: "speed[km/h]", form: ChartForm.extraLarge, rateValue: 0, dropShadow: false)
            }
        }
        .onAppear{
            EventStore.load(fileURL: file) { result in
                if case .success(let events) = result {
                    eventStore.speedValues = events
                        .filter{ ($0 as? OBDEvent)?.toIntermediate() is pcdfcore.SpeedEvent }
                        .map{ Double((($0 as? OBDEvent)?.toIntermediate() as? pcdfcore.SpeedEvent)?.speed ?? 0) }
                }
            }
        }
    }
}
