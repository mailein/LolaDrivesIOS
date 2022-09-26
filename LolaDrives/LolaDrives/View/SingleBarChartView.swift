import SwiftUI
import Charts

struct SingleBarChartView: UIViewRepresentable {
    typealias UIViewType = BarChartView
    
    var entries: [BarChartDataEntry]
    var label: String
    var xIndex: [String]
    
    func makeUIView(context: Context) -> BarChartView {
        return BarChartView()
    }
    
    func updateUIView(_ uiView: BarChartView, context: Context) {
        addData(to: uiView)//This will enable automatic chart update in case data changes.
        formatXAxis(xAxis: uiView.xAxis)
        setupBalloonMarker(to: uiView)
        uiView.animate(xAxisDuration: 2, yAxisDuration: 2)
    }
    
    func addData(to barChart: BarChartView) {
        let dataSet = BarChartDataSet(entries: entries)
        dataSet.colors = [.green]
        dataSet.label = label
        let data = BarChartData(dataSet: dataSet)
        barChart.data = data
    }
    
    func formatXAxis(xAxis: XAxis) {
        xAxis.labelPosition = .bottom
        xAxis.labelRotatedHeight = 25
        xAxis.labelRotationAngle = -30
        xAxis.valueFormatter = IndexAxisValueFormatter(values: self.xIndex)
    }
    
    func setupBalloonMarker(to barChart: BarChartView) {
        let marker = BalloonMarker(color: UIColor(white: 180/255, alpha: 1),
                                   font: .systemFont(ofSize: 12),
                                   textColor: .white,
                                   insets: UIEdgeInsets(top: 8, left: 8, bottom: 20, right: 8))
        marker.chartView = barChart
        marker.minimumSize = CGSize(width: 80, height: 40)
        barChart.marker = marker
    }
}
