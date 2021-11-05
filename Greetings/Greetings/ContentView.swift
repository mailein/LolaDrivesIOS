//
//  ContentView.swift
//  Greetings
//
//  Created by Mei Chen on 28.04.21.
//

import SwiftUI
//import pcdfcore

struct ContentView: View {
    // UI
    var menuItems: [MenuItem] = Menu.menuItems
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    // bluetooth
    @ObservedObject var locationHelper = LocationHelper()
    @StateObject var obd = MyOBD()

    var body: some View {
        NavigationView{
            LazyVGrid(columns: columns, spacing: 10){
                ForEach(Menu.menuItems, id: \.id){ menuItem in
                    NavigationLink(destination: {
                        switch menuItem.title {
                        case "RDE":
                            RdeSettingsView(obd: obd)
                        case "Monitoring":
                            MonitoringView(speed: obd.mySpeed, altitude: obd.myAltitude, temp: obd.myTemp,
                                           nox: obd.myNox, fuelRate: obd.myFuelRate, MAFRate: obd.myMAFRate)
                        case "Profiles":
                            ProfilesView()
                        case "History":
                            HistoryView()
                        case "Privacy":
                            PrivacyView()
                        case "Help":
                            HelpView()
                        default:
                            ContentView()
                        }
                    }, label: {
                        VStack(spacing: 10){
                            menuItem.icon
                            Text("\(menuItem.title)")
                        }
                    })
                        .font(.title)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                        .foregroundColor(.white)
                        .background(Color.gray)
                        .cornerRadius(10)
                        .aspectRatio(1, contentMode: .fit)
                }
            }
            .LolaNavBarStyle()
            .padding()
        }
        .onAppear{
            obd._locationHelper = locationHelper
            locationHelper.checkIfLocationServicesIsEnabled()
        }
        .alert(isPresented: $locationHelper.showAlert) {
            locationHelper.alert!
        }
    }
}

//struct ContentView: View {
//    var body: some View {
//        let rustGreetings = RustGreetings()
//        let text = "\(rustGreetings.sayHello(to: "world"))"
//        let num = "\(rustGreetings.add(a:1, b:2))"
//
//        let fileContent = specFile(filename: "rde-lola-test-drive-spec-no-percentile1.lola")
//        let text1 = "\(rustGreetings.initmonitor(s: fileContent))"
//
//        //6 input var in spec.lola, plus 1 time => 7 elements
//        var bytes: [Double] = [18.0, 303.18824990035785, 288.15, 12.0, 15.94, 1.55, 5417.974006502]
//        let a = "\(rustGreetings.sendevent(inputs: &bytes, len_in: UInt32(bytes.count)))"
//
//        var bytes2: [Double] = [18.0, 303.18824990035785, 288.15, 6.0, 15.02, 0.7, 5419.009988532]
//        let a2 = "\(rustGreetings.sendevent(inputs: &bytes2, len_in: UInt32(bytes2.count)))"
//
////        let p = pcdfcore.PCDFEvent(source: "", type: EventType.gps, timestamp: 0)
////        let serializedEvent = p.toIntermediate().serialize()
////        let c = PCDFEvent.Companion().fromString(string: serializedEvent).toIntermediate()
//
////        let d = RDEValidator().monitorOffline(data: [p])
////        let e = PatternParser().toLines(filename: "nox-valid.ppcdf")
//
////        let events = PatternParser().parse()
////        var f = try! RDEValidator().monitorOffline(data: events)
//
//        var obdConnect = false
//        let obd = MyOBD()
//
//        VStack{
//            Text(text)
//            Text(num)
//            Text(text1)
//            Text(a)
//            Text(a2)
////            Text(c.source)
////            Text("parser: \(e)")
////            Text(String(f.count))
//            Button(action: {
//                obdConnect.toggle()
//                if obdConnect {
//                    obd.viewDidLoad()
//                }else{
//                    obd.disconnect()
//                }
//            }, label: {
//                Text("\(obdConnect ? "dis" : "")connect OBD")
//            })
//            Text(obd.mySpeed)
//
//        }
//        .padding()
//    }
//}



struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
