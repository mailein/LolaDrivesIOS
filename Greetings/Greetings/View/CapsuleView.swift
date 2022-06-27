import SwiftUI

struct CapsuleView: View{
    var barOffsets: [Double]
    var ballOffsets: [Double]
    var width: Double
    var capsuleCategory: CapsuleCategory
    
    private var barWidth: CGFloat = 1
    private var ballHeight: CGFloat = 10
    
    let VERBOSITY_MODE = true
    
    init(barOffsets: [Double] = [0, 1], ballOffsets: [Double] = [0, 1], capsuleCategory: CapsuleCategory, width: Double = 0){
        self.barOffsets = barOffsets
        self.ballOffsets = ballOffsets
        self.capsuleCategory = capsuleCategory
        self.width = width
    }
    
    var body: some View{
        GeometryReader{ geometry in
            ZStack(alignment: .leading){
                Capsule()
                    .fill(Color.blue)
                    .frame(height: ballHeight)
                if width != 0 {
                    let color: Color =
                    (capsuleCategory == .NOX && width > barOffsets[1]) ||
                    (capsuleCategory == .DISTANCE && (width < barOffsets[0] || width > barOffsets[1])) ?
                        .red : (((capsuleCategory == .NOX && width <= barOffsets[0]) ||
                                 (capsuleCategory == .DISTANCE && width >= barOffsets[0] && width <= barOffsets[1])) ? .green : .yellow)
                    Capsule()
                        .fill(color)
                        .frame(width: geometry.size.width * width)
                    if VERBOSITY_MODE {
                        Text(String(format: "%.2f", width))
                            .foregroundColor(color)
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
                    let color: Color =
                    (capsuleCategory == .DYNAMICS_HIGH && ballOffsets[0] > barOffsets[0]) ||
                    (capsuleCategory == .DYNAMICS_LOW && ballOffsets[0] < barOffsets[0]) ? .red : .green
                    Circle()
                        .fill(color)
                        .frame(width: ballHeight, height: ballHeight)
                        .offset(x: ball * (geometry.size.width - ballHeight), y: 0)
                    if VERBOSITY_MODE {
                        Text(String(format: "%.2f", ball))
                            .foregroundColor(color)
                            .position(x: ball * (geometry.size.width - ballHeight), y: 20)
                    }
                }
            }
        }
        .frame(height: ballHeight)
//        .border(Color.yellow)
    }
}

enum CapsuleCategory {
    case NOX
    case DISTANCE
    case DYNAMICS_LOW
    case DYNAMICS_HIGH
}
