import SwiftUI
import Charts

struct SingleLineChartView: UIViewRepresentable {
    typealias UIViewType = LineChartView
    
    var entries: [ChartDataEntry]
    var label: String
    var xIndex: [String]
    
    func makeUIView(context: Context) -> LineChartView {
        return LineChartView()
    }
    
    func updateUIView(_ uiView: LineChartView, context: Context) {
        addData(uiView)//This will enable automatic chart update in case data changes.
        formatXAxis(xAxis: uiView.xAxis)
    }
    
    func addData(_ lineChart: LineChartView) {
        let dataSet = LineChartDataSet(entries: entries)
        formatDataSet(dataSet: dataSet, label: self.label, color: .blue)
        let data = LineChartData(dataSet: dataSet)
        lineChart.data = data
    }
    
    func formatDataSet(dataSet: LineChartDataSet, label: String, color: UIColor) {
        dataSet.colors = [color]
        dataSet.valueColors = [color]
        dataSet.circleColors = [color]
        dataSet.label = label
        dataSet.circleRadius = 3
        dataSet.circleHoleRadius = 0
        dataSet.mode = .horizontalBezier
        dataSet.lineWidth = 3
//        dataSet.lineDashLengths = [3]
    }
    
    func formatXAxis(xAxis: XAxis) {
        xAxis.labelPosition = .bottom
        xAxis.valueFormatter = IndexAxisValueFormatter(values: self.xIndex)
    }
}
