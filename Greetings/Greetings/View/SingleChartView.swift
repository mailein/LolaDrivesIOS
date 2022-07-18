import SwiftUI
import Charts

struct SingleChartView: UIViewRepresentable {
    typealias UIViewType = BarChartView
    
    var entries: [BarChartDataEntry]
    var label: String
    
    func makeUIView(context: Context) -> BarChartView {
        let chart = BarChartView()
        chart.data = addData()
        return chart
    }
    
    func updateUIView(_ uiView: BarChartView, context: Context) {
        uiView.data = addData()//This will enable automatic chart update in case data changes.
    }
    
    func addData() -> BarChartData {
        let dataSet = BarChartDataSet(entries: entries)
        dataSet.colors = [.green]
        dataSet.label = label
        
        let data = BarChartData(dataSet: dataSet)
        
        return data
    }
}
