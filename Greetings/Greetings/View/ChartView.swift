import SwiftUI
import SwiftUICharts

struct ChartView: View {
    @StateObject private var eventStore = EventStore()
    var file: URL
    var title: String
    var keyPrefix: String
    var scaler: Int
    
    var body: some View {
        BarChartView(data: ChartData(values: eventStore.chartData), title: title, form: ChartForm.extraLarge, dropShadow: false, valueSpecifier: "%.2f")
            .onAppear{
                EventStore.load(fileURL: file) { result in
                    if case .success(let events) = result {
                        let rdeValidator = RDEValidator()
                        do {
                            eventStore.outputs = try rdeValidator.monitorOffline(data: events)
                            eventStore.chartData = eventStore.outputs
                                .filter{ $0.key.contains(keyPrefix) }
                                .map{ ($0.key.replacingOccurrences(of: keyPrefix, with: ""), $0.value * Double(scaler)) } //nox in mg
                                .sorted(by: { (a, b) in
                                    return Int(a.0.components(separatedBy: "_")[0]) ?? 0 < Int(b.0.components(separatedBy: "_")[0]) ?? 0
                                })
                            print("chart data: \(eventStore.chartData)")
                        } catch {
                            print(error.localizedDescription)
                        }
                        print("rde result successfully loaded \(events.count) events")
                    }
                }
            }
    }
}
