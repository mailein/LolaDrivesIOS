import SwiftUI

struct CapsuleView: View{
    var barOffset: [Double]
    var ballOffset: [Double]
    
    private var barWidth: CGFloat = 1
    private var ballHeight: CGFloat = 10
    
    init(barOffset: [Double] = [0, 0.5, 1], ballOffset: [Double] = [0, 0.5, 1]){
        self.barOffset = barOffset
        self.ballOffset = ballOffset
    }
    
    var body: some View{
        GeometryReader{ geometry in
            ZStack(alignment: .leading){
                Capsule()
                    .fill(Color.blue)
                    .frame(height: ballHeight)
                ForEach(barOffset, id: \.self){bar in
                    Rectangle()
                        .fill(Color.black)
                        .frame(width: barWidth, height: ballHeight)
                        .offset(x: bar * (geometry.size.width - barWidth), y: 0)
                }
                ForEach(ballOffset, id: \.self) {ball in
                    Circle()
                        .fill(Color.black)
                        .frame(width: ballHeight, height: ballHeight)
                        .offset(x: ball * (geometry.size.width - ballHeight), y: 0)
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
