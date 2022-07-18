import SwiftUI
import Charts

struct SingleLineChartView: UIViewRepresentable {
    typealias UIViewType = LineChartView
    
    var entries: [ChartDataEntry]
    var label: String
    
    func makeUIView(context: Context) -> LineChartView {
        let chart = LineChartView()
        chart.data = addData()
        return chart
    }
    
    func updateUIView(_ uiView: LineChartView, context: Context) {
        uiView.data = addData()//This will enable automatic chart update in case data changes.
    }
    
    func addData() -> ChartData {
        let dataSet = LineChartDataSet(entries: entries)
//        dataSet.colors = [.blue]
        dataSet.label = label
        
        let data = LineChartData(dataSet: dataSet)
        
        return data
    }
}
