import SwiftUI
import Charts

struct SingleBarChartView: UIViewRepresentable {
    typealias UIViewType = BarChartView
    
    var entries: [BarChartDataEntry]
    var label: String
    var xIndex: [String]
    
    func makeUIView(context: Context) -> BarChartView {
        let chart = BarChartView()
        chart.data = addData()
        return chart
    }
    
    func updateUIView(_ uiView: BarChartView, context: Context) {
        uiView.data = addData()//This will enable automatic chart update in case data changes.
        formatXAxis(xAxis: uiView.xAxis)
    }
    
    func addData() -> BarChartData {
        let dataSet = BarChartDataSet(entries: entries)
        dataSet.colors = [.green]
        dataSet.label = label
        
        let data = BarChartData(dataSet: dataSet)
        
        return data
    }
    
    func formatXAxis(xAxis: XAxis) {
        xAxis.labelPosition = .bottom
        xAxis.valueFormatter = IndexAxisValueFormatter(values: self.xIndex)
    }
}
