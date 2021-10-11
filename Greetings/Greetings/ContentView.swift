//
//  ContentView.swift
//  Greetings
//
//  Created by Mei Chen on 28.04.21.
//

import SwiftUI
import pcdfcore


//struct ContentView: View {
//
//    var menuItems: [MenuItem] = Menu.menuItems
//
//    var body: some View {
//        NavigationView{
//            List(Menu.menuItems, id: \.id){ menuItem in
//                NavigationLink(destination: {
//                    switch menuItem.title {
//                    case "RDE":
//                        RdeSettingsView()
//                    case "Monitoring":
//                        MonitoringView()
//                    case "Profiles":
//                        ProfilesView()
//                    case "History":
//                        HistoryView()
//                    case "Privacy":
//                        PrivacyView()
//                    case "Help":
//                        HelpView()
//                    default:
//                        ContentView()
//                    }
//                }, label: {
//                    HStack{
//                        menuItem.icon
//                        Text("\(menuItem.title)")
//                    }
//                })
//            }
//            .navigationBarItems(leading: HomeIconView(), trailing: ConnectedDisconnectedView(connected: false))
//        }
//    }
//}

struct ContentView: View {
    var body: some View {
        let rustGreetings = RustGreetings()
        let text = "\(rustGreetings.sayHello(to: "world"))"
        let num = "\(rustGreetings.add(a:1, b:2))"

        let fileContent = specFile(filename: "rde-lola-test-drive-spec-no-percentile1.lola")
        let text1 = "\(rustGreetings.initmonitor(s: fileContent))"

        //6 input var in spec.lola, plus 1 time => 7 elements
        var bytes: [Double] = [18.0, 303.18824990035785, 288.15, 12.0, 15.94, 1.55, 5417.974006502]
        let a = "\(rustGreetings.sendevent(inputs: &bytes, len_in: UInt32(bytes.count)))"

        var bytes2: [Double] = [18.0, 303.18824990035785, 288.15, 6.0, 15.02, 0.7, 5419.009988532]
        let a2 = "\(rustGreetings.sendevent(inputs: &bytes2, len_in: UInt32(bytes2.count)))"

//        let p = pcdfcore.PCDFEvent(source: "", type: EventType.gps, timestamp: 0)
//        let serializedEvent = p.toIntermediate().serialize()
//        let c = PCDFEvent.Companion().fromString(string: serializedEvent).toIntermediate()

//        let d = RDEValidator().monitorOffline(data: [p])
//        let e = PatternParser().toLines(filename: "nox-valid.ppcdf")

//        let events = PatternParser().parse()
//        var f = try! RDEValidator().monitorOffline(data: events)

        var obdConnect = false
        let obd = MyOBD()

        VStack{
            Text(text)
            Text(num)
            Text(text1)
            Text(a)
            Text(a2)
//            Text(c.source)
//            Text("parser: \(e)")
//            Text(String(f.count))
            Button(action: {
                obdConnect.toggle()
                if obdConnect {
                    obd.viewDidLoad()
                }else{
                    obd.disconnect()
                }
            }, label: {
                Text("\(obdConnect ? "dis" : "")connect OBD")
            })
            Text(obd.mySpeed)

        }
        .padding()
    }
}



struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
