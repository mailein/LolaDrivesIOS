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
        addData(to: uiView)//This will enable automatic chart update in case data changes.
        formatXAxis(xAxis: uiView.xAxis)
//        formatChart(uiView)
        setupBalloonMarker(to: uiView)
    }
    
    func addData(to lineChart: LineChartView) {
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
    
    func formatChart(_ lineChart: LineChartView) {
        lineChart.scaleXEnabled = true
        lineChart.scaleYEnabled = true
        lineChart.doubleTapToZoomEnabled = true
        lineChart.setVisibleXRangeMaximum(20)
    }
    
    func setupBalloonMarker(to lineChart: LineChartView) {
        let marker = BalloonMarker(color: UIColor(white: 180/255, alpha: 1),
                                   font: .systemFont(ofSize: 12),
                                   textColor: .white,
                                   insets: UIEdgeInsets(top: 8, left: 8, bottom: 20, right: 8))
        marker.chartView = lineChart
        marker.minimumSize = CGSize(width: 80, height: 40)
        lineChart.marker = marker
    }
}
