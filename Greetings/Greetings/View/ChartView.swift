import SwiftUI
import SwiftUICharts

struct ChartView: View {
    @StateObject private var eventStore = EventStore()
    var file: URL
    var title: String
    
    var body: some View {
        BarChartView(data: ChartData(values: eventStore.avgNoxAtFuelRate), title: title, form: ChartForm.extraLarge, dropShadow: false, valueSpecifier: "%.2f")
            .onAppear{
                EventStore.load(fileURL: file) { result in
                    if case .success(let events) = result {
                        let rdeValidator = RDEValidator()
                        do {
                            eventStore.outputs = try rdeValidator.monitorOffline(data: events)
                            eventStore.avgNoxAtFuelRate = eventStore.outputs
                                .filter{ $0.key.contains("nox_avg_at_fuel_rate") }
                                .map{ ($0.key.replacingOccurrences(of: "nox_avg_at_fuel_rate_", with: ""), $0.value * 1000) } //nox in mg
                                .sorted(by: { (a, b) in
                                    return Int(a.0.components(separatedBy: "_")[0]) ?? 0 < Int(b.0.components(separatedBy: "_")[0]) ?? 0
                                })
                            print("avg nox: \(eventStore.avgNoxAtFuelRate)")
                        } catch {
                            print(error.localizedDescription)
                        }
                        print("rde result successfully loaded \(events.count) events")
                    }
                }
            }
    }
}
