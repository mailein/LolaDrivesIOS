import SwiftUI

struct MenuView: View {
    let menuItems: [MenuItem] = Menu.menuItems
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    @ObservedObject var locationHelper = LocationHelper()
    @EnvironmentObject var viewModel: ViewModel
    @EnvironmentObject var obd: MyOBD
    
//TODO: columns auto fit when phone is rotated
    var body: some View {
        //only need 1 NavigationView, every subview doesn't need it, or it will create a big space above the NavigationTitle in the subview.
        ScrollView{
            LazyVGrid(columns: columns, spacing: 10){
                ForEach(Menu.menuItems, id: \.id){ menuItem in
                    NavigationLink(destination: {
                        switch menuItem.title {
                        case "RDE":
                            if !viewModel.model.started {
                                RdeSettingsView()
                            }else{
                                RdeView()
                            }
                        case "Monitoring":
                            MonitoringView()
                        case "Profiles":
                            ProfilesView()
                        case "History":
                            HistoryView()
                        case "Privacy":
                            PrivacyView()
                        case "Help":
                            HelpView()
                        default:
                            HelpView()
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
            HStack(spacing: 10){
                NavigationLink(destination: AcknowledgementsView(), label: {
                    Text("Acknowledgements")
                })
                Text("|")
                NavigationLink(destination: ImpressumView(), label: {
                    Text("Impressum")
                })
            }
        }
        .LolaNavBarStyle()
        .padding()
        .onAppear{
            locationHelper.checkIfLocationServicesIsEnabled()
            obd.setLocationHelper(locationHelper)
            Uploader().uploadAll()
        }
        .alert(isPresented: $locationHelper.showAlert) {
            locationHelper.alert!
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarTitleDisplayMode(.inline)
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
