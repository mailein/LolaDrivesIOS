import SwiftUI
import LTSupportAutomotive

struct MonitoringView: View {
//    var commands : [LTOBD2PID] = []
    var speed: String
    var altitude: String
    var temp: String
    var nox: String
    var fuelRate: String
    var MAFRate: String
    
    var body: some View {
        VStack{
            Text("Speed: \(speed)")
            Text("Altitude: \(altitude)")
            Text("Tempature: \(temp)")
            Text("NOₓ: \(nox)")
            Text("Fuel Rate: \(fuelRate)")
            Text("MAF Rate: \(MAFRate)")
            Spacer()
        }
        
//        List(commands, id: \.self) { command in
//            VStack{
//                Text("\(command.description):")
//                Spacer()
//                Text("\(command.formattedResponse)")
//            }
//        }
    }
}
