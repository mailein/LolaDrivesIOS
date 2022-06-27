import SwiftUI

struct CapsuleView: View{
    var barOffsets: [Double]
    var ballOffsets: [Double]
    var width: Double
    var isHigherWarning: Bool
    
    private var barWidth: CGFloat = 1
    private var ballHeight: CGFloat = 10
    
    let VERBOSITY_MODE = true
    
    init(barOffsets: [Double] = [0, 1], ballOffsets: [Double] = [0, 1], isHigherWarning: Bool = false, width: Double = 0){
        self.barOffsets = barOffsets
        self.ballOffsets = ballOffsets
        self.isHigherWarning = isHigherWarning
        self.width = width
    }
    
    var body: some View{
        GeometryReader{ geometry in
            ZStack(alignment: .leading){
                Capsule()
                    .fill(Color.blue)
                    .frame(height: ballHeight)
                if width != 0 {
                    let color: Color = width >= barOffsets[1] ? .red : (width >= barOffsets[0] ? .yellow : .green)
                    Capsule()
                        .fill(color)
                        .frame(width: geometry.size.width * width)
                    if VERBOSITY_MODE {
                        Text(String(format: "%.2f", width))
                            .foregroundColor(.green)
                            .position(x: 40, y: -10)
                    }
                }
                ForEach(barOffsets, id: \.self){bar in
                    Rectangle()
                        .fill(Color.black)
                        .frame(width: barWidth, height: ballHeight)
                        .offset(x: bar * (geometry.size.width - barWidth), y: 0)
                    if VERBOSITY_MODE {
                        Text(String(format: "%.2f", bar))
                            .position(x: bar * (geometry.size.width - barWidth), y: -10)
                    }
                }
                ForEach(ballOffsets, id: \.self) {ball in
                    let color: Color = (isHigherWarning && ballOffsets[0] > barOffsets[0]) || (!isHigherWarning && ballOffsets[0] < barOffsets[0]) ? .red : .yellow
                    Circle()
                        .fill(color)
                        .frame(width: ballHeight, height: ballHeight)
                        .offset(x: ball * (geometry.size.width - ballHeight), y: 0)
                    if VERBOSITY_MODE {
                        Text(String(format: "%.2f", ball))
                            .foregroundColor(.yellow)
                            .position(x: ball * (geometry.size.width - ballHeight), y: 20)
                    }
                }
            }
        }
        .frame(height: ballHeight)
//        .border(Color.yellow)
    }
}

struct CapsuleView_Previews: PreviewProvider {
    static var previews: some View {
        CapsuleView()
    }
}
