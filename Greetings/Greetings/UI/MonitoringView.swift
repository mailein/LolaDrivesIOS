import SwiftUI
import LTSupportAutomotive

struct MonitoringView: View {
//    var commands : [LTOBD2PID] = []
    var rpm: String
    var speed: String
    var temp: String
    
    var body: some View {
        VStack{
            Text("RPM: \(rpm)")
            Text("Speed: \(speed)")
            Text("Tempature: \(temp)")
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

struct MonitoringView_Previews: PreviewProvider {
    static var previews: some View {
        MonitoringView(rpm: "", speed: "", temp: "")
    }
}
