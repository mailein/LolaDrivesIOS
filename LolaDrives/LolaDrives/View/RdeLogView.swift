import SwiftUI
import pcdfcore

struct RdeLogView: View{
    @State var selectedTab = 2
    @EnvironmentObject var model: Model
    @EnvironmentObject var obd: MyOBD
    
    var body: some View{
        TabView(selection: $selectedTab){
            EventLogView(fileName: obd.getFileName())
                .tabItem{
                    Label("Event log", systemImage: "doc.plaintext")
                }
                .tag(0)
            ChartsView(fileName: obd.getFileName())
                .tabItem{
                    Label("Charts", systemImage: "chart.xyaxis.line")
                }
                .tag(1)
            RdeResultView(fileName: obd.getFileName())
                .tabItem{
                    Label("RDE Result", systemImage: "car")
                }
                .tag(2)
        }
            .toolbar{
//                ToolbarItem(placement: .navigationBarLeading){
//                    Button(action: {
//                        model.exitRDE()
//                    }) {
//                        HStack(spacing: 0) {
//                            Image(systemName: "chevron.backward")
//                                .aspectRatio(contentMode: .fill)
//                            Text("Configuration")
//                        }
//                    }
//                }
                ToolbarItem(placement: .navigationBarTrailing){
                    ConnectedDisconnectedView(connected: obd.isConnected())
                }
            }
//            .navigationBarBackButtonHidden(true)
            .onDisappear{
                model.exitRDE()
            }
    }
}

struct RdeResultView: View{
    let fileName: String
    let fileUrl: URL
    @StateObject private var eventStore = EventStore()
    
    init(fileName: String) {
        self.fileName = fileName
        do {
            fileUrl = try EventStore.fileURL(fileName: fileName)
        } catch {
            fileUrl = URL(fileURLWithPath: "")
            
            fatalError(error.localizedDescription)
        }
    }
    
    var body: some View {
        ScrollView{
            VStack(alignment: .leading){
                RdeResultLine(name: "Valid RDE Trip", imageName: getValidRdeTrip(), helpMsg: .validRdeTrip)
                RdeResultLine(name: "Total Duration", durationText: DurationText(durationInSeconds: Int64(getTotalDuration())), helpMsg: .totalDuration)
                RdeResultLine(name: "Total Distance", distanceText: DistanceText(distanceInMeters: getTotalDistance()))
                RdeResultLine(name: "NOₓ Emissions", value: getNoxPerKilometer(), unit: "mg/km", helpMsg: .nox)
                
                RdeResultSection(category: .URBAN,
                                 t: eventStore.outputs["t_u"] ?? 0,
                                 d: eventStore.outputs["d_u"] ?? 0,
                                 avg: eventStore.outputs["u_avg_v"] ?? 0,
                                 pct: eventStore.outputs["u_va_pct"] ?? 0,
                                 rpa: eventStore.outputs["u_rpa"] ?? 0,
                                 totalDistance: eventStore.outputs["d"] ?? 0)
                
                RdeResultSection(category: .RURAL,
                                 t: eventStore.outputs["t_r"] ?? 0,
                                 d: eventStore.outputs["d_r"] ?? 0,
                                 avg: eventStore.outputs["r_avg_v"] ?? 0,
                                 pct: eventStore.outputs["r_va_pct"] ?? 0,
                                 rpa: eventStore.outputs["r_rpa"] ?? 0,
                                 totalDistance: eventStore.outputs["d"] ?? 0)
                
                RdeResultSection(category: .MOTORWAY,
                                 t: eventStore.outputs["t_m"] ?? 0,
                                 d: eventStore.outputs["d_m"] ?? 0,
                                 avg: eventStore.outputs["m_avg_v"] ?? 0,
                                 pct: eventStore.outputs["m_va_pct"] ?? 0,
                                 rpa: eventStore.outputs["m_rpa"] ?? 0,
                                 totalDistance: eventStore.outputs["d"] ?? 0)
                
            }
            .padding()
        }
        .onAppear{
            EventStore.load(fileURL: fileUrl) { result in
                if case .success(let events) = result {
                    let rdeValidator = RDEValidator()
                    do {
                        eventStore.outputs = try rdeValidator.monitorOffline(data: events)
                    } catch {
                        print(error.localizedDescription)
                    }
                    print("rde result successfully loaded \(events.count) events")
                }
            }
        }
    }
    
    
    func getValidRdeTrip() -> String {
        if eventStore.outputs["is_valid_test_num"] == 1.0 && eventStore.outputs["not_rde_test_num"] != 0.0 {
            return "checkmark"
        } else {
            return "xmark"
        }
    }
    
    func getTotalDuration() -> Double {
        let tu: Double = eventStore.outputs["t_u"] ?? 0
        let tr: Double = eventStore.outputs["t_r"] ?? 0
        let tm: Double = eventStore.outputs["t_m"] ?? 0
        return tu + tr + tm
    }
    
    func getTotalDistance() -> Double {
        let d: Double = eventStore.outputs["d"] ?? 0
        return d
    }
    
    func getNoxPerKilometer() -> Double {
        let nox: Double = eventStore.outputs["nox_per_kilometer"] ?? 0
        return nox * 1000
    }
    
    enum HelpMsg: String {
        case validRdeTrip = "Valid RDE Trip"
        case totalDuration = "Total Duration"
        case nox = "NOₓ Emissions"
        
        case urbanDistance = "Urban - Distance"
        case urbanPct = "Urban - Dynamics High"
        case urbanRpa = "Urban - Dynamics Low"
        
        case ruralDistance = "Rural - Distance"
        case ruralPct = "Rural - Dynamics High"
        case ruralRpa = "Rural - Dynamics Low"
        
        case motorwayDistance = "Motorway - Distance"
        case motorwayPct = "Motorway - Dynamics High"
        case motorwayRpa = "Motorway - Dynamics Low"
    }
    
    struct RdeResultSection: View {
        let category: Category
        let t: Double
        let d: Double
        let avg: Double
        let pct: Double
        let rpa: Double
        let helpDistance: HelpMsg
        let helpDynamicsHigh: HelpMsg
        let helpDynamicsLow: HelpMsg
        let totalDistance: Double
        
        init(category: Category, t: Double, d: Double, avg: Double, pct: Double, rpa: Double, totalDistance: Double) {
            self.category = category
            self.t = t
            self.d = d
            self.avg = avg
            self.pct = pct
            self.rpa = rpa
            self.totalDistance = totalDistance
            switch category {
            case .URBAN:
                self.helpDistance = .urbanDistance
                self.helpDynamicsHigh = .urbanPct
                self.helpDynamicsLow = .urbanRpa
            case .RURAL:
                self.helpDistance = .ruralDistance
                self.helpDynamicsHigh = .ruralPct
                self.helpDynamicsLow = .ruralRpa
            case .MOTORWAY:
                self.helpDistance = .motorwayDistance
                self.helpDynamicsHigh = .motorwayPct
                self.helpDynamicsLow = .motorwayRpa
            }
        }
        
        var body: some View {
            VStack(alignment: .leading){
                Divider()
                Text(category.rawValue).bold()
                RdeResultLine(name: "Duration", durationText: DurationText(durationInSeconds: Int64(t)))
                RdeResultLine(name: "Distance", distanceText: DistanceText(distanceInMeters: d), helpMsg: self.helpDistance, totalDistance: self.totalDistance)
                RdeResultLine(name: "Average Speed", value: avg, unit: "km/h")
                RdeResultLine(name: "Dynamics High", value: pct, unit: "m²/s³", helpMsg: self.helpDynamicsHigh, avg_speed: avg)
                RdeResultLine(name: "Dynamics Low", value: rpa, unit: "m/s²", helpMsg: self.helpDynamicsLow, avg_speed: avg)
            }
        }
    }
    
    struct RdeResultLine: View {
        private let name: String
        private var value: Double? = nil
        private var unit: String? = nil
        private var imageName: String? = nil
        private var duration: DurationText? = nil
        private var distance: DistanceText? = nil
        private var helpMsg: HelpMsg?
        private var totalDistance: Double?
        private var avg_speed: Double?
        
        private let width: CGFloat = 150
        @State private var showPopover = false
        
        init(name: String, value: Double, unit: String, helpMsg: HelpMsg? = nil, avg_speed: Double? = nil) {
            self.name = name
            self.value = value
            self.unit = unit
            self.helpMsg = helpMsg
            self.avg_speed = avg_speed
        }
        
        init(name: String, imageName: String, helpMsg: HelpMsg? = nil) {
            self.name = name
            self.imageName = imageName
            self.helpMsg = helpMsg
        }
        
        init(name: String, durationText: DurationText, helpMsg: HelpMsg? = nil) {
            self.name = name
            self.duration = durationText
            self.helpMsg = helpMsg
        }
        
        init(name: String, distanceText: DistanceText, helpMsg: HelpMsg? = nil, totalDistance: Double? = nil) {
            self.name = name
            self.distance = distanceText
            self.helpMsg = helpMsg
            self.totalDistance = totalDistance
        }
        
        var body: some View {
            HStack(alignment: .center){
                Text("\(name):")
                    .frame(width: width, alignment: .bottomLeading)
                if value != nil && unit != nil {
                    Text("\(String(format: "%.2f", value!)) \(unit!)")
                }
                if imageName != nil {
                    let color = imageName! == "xmark" ? Color.red : Color.green
                    Image(systemName: imageName!)
                        .foregroundColor(color)
                }
                if duration != nil {
                    duration!
                }
                if distance != nil {
                    distance!
                }
                Spacer()
                if helpMsg != nil {
                    Button(action: {
                        showPopover = true
                    }, label: {
                        Image(systemName: "questionmark.circle")
                    })
                    .frame(alignment: .trailing)
                    .popover(isPresented: $showPopover, content: {
                        helpMsgView(help: helpMsg!, totalDistance: self.totalDistance, avg_speed: avg_speed)
                    })
                }
            }
        }
        
        struct helpMsgView: View {
            let help: HelpMsg
            var totalDistance: Double? = -1
            var avg_speed: Double? = -1
            let headlineColor = Color(red: 68/255.0, green: 188/255.0, blue: 212/255.0)//the same as in style.css
            
            init(help: HelpMsg, totalDistance: Double? = nil, avg_speed: Double? = nil){
                self.help = help
                switch help{
                case .urbanDistance, .ruralDistance, .motorwayDistance:
                    self.totalDistance = totalDistance
                    self.avg_speed = nil
                case .urbanPct, .urbanRpa, .ruralPct, .ruralRpa, .motorwayPct, .motorwayRpa:
                    self.totalDistance = nil
                    self.avg_speed = avg_speed
                default:
                    self.totalDistance = nil
                    self.avg_speed = nil
                }
            }
            
            var body: some View {
                VStack(alignment: .leading, spacing: 20){
                    Text(help.rawValue)
                    .font(.title)
                    .bold()
                    .foregroundColor(headlineColor)
                    
                    switch help {
                    case .validRdeTrip:
                        Text("The EU defines several constraints for test drives to be considered as a valid RDE test.")
                        Text("The most important conditions are listed on this result summary page.")
                        Text("If you want to learn more about a constraint, or to get tips on how to keep a value within the acceptable bounds, you can tap on the \(Image(systemName: "questionmark.circle")) next to the respective value.")
                    case .totalDuration:
                        Text("The total duration of a valid RDE-Drive must be between **90 and 120 minutes**")
                        Text("Too short or too long drives can not be valid.")
                    case .nox:
                        Text("The NOₓ emissions value indicates how much nitrogen oxides the tested vehicle emitted per kilometer during the RDE drive.")
                        Text("These values differ depending on the **year of type approval** and the **year of first admission** of the vehicle.")
                        Text("Diesel powered vehicle types approved between September 2017 and December 2019, or vehicles firstly admitted between September 2019 and December 2020, must emit at most **168 mg/km** of nitric oxides. Diesel cars approved or admitted later, must conform to a **120 mg/km** threshold.")
                    case .urbanDistance, .ruralDistance, .motorwayDistance:
                        helpMsgDistanceView(totalDistance: totalDistance!)
                    case .urbanPct, .ruralPct, .motorwayPct:
                        helpMsgPctView(avg_speed: avg_speed!)
                    case .urbanRpa, .ruralRpa, .motorwayRpa:
                        helpMsgRpaView(avg_speed: avg_speed!)
                    }
                }
                .padding()
            }
            
            struct helpMsgDistanceView: View {
                let totalDistance: Double
                
                var body: some View {
                    Text("The Urban Distance indicates how much distance was covered during the test in the **urban segment**, i.e. in towns and cities.")
                    Text("This distance must be greater than **16 km** and must also constitute **29% to 44% of the total distance** of the RDE-Drive.")
                    if totalDistance * 0.44 / 1000.0 < 16.0 {
                        Text("So the distance in this drive must be greater than **16 km**")
                    } else if totalDistance * 0.29 < 16_000 {
                        Text("So the distance in this drive must be between **16 km** and **\(totalDistance * 0.44 / 1000.0) km**")
                    } else {
                        Text("So the distance in this drive must be between **\(totalDistance * 0.29 / 1000.0) km** and **\(totalDistance * 0.44 / 1000.0) km**")
                    }
                }
            }
            
            struct helpMsgPctView: View {
                let avg_speed: Double
                
                var body: some View {
                    Text("In order to exclude driving that could be regarded as **too aggressive**, the high dynamic boundary condition sets an upper limit for the acceleration behavior.")
                    Text("It is checked whether the 95th percentile of the product of acceleration and speed is below a limit set by the EU.")
                    Text("This limit depends on the average speed of the corresponding segment.")
                    
                    Text("In this drive and segment, the upper limit is **\(calculateHighDynamics(avg_speed: avg_speed)) m²/s³**")
                }
                
                func calculateHighDynamics(avg_speed: Double) -> String{
                    let value: Double
                    if avg_speed < 74.6 {
                        if avg_speed == 0.0 {
                            value = 0.0
                        } else {
                            value = 0.136 * avg_speed + 14.44
                        }
                    } else {
                        value = 0.0742 * avg_speed + 18.966
                    }
                    return String(format: "%.2f", value)
                }
            }
            
            struct helpMsgRpaView: View {
                let avg_speed: Double
                
                var body: some View {
                    Text("In order to exclude driving that could be regarded as **too smooth**, the low dynamic boundary condition sets a lower limit for the **relative positive acceleration (RPA)**.")
                    Text("It is checked whether the ratio of the distance accelerated to the total distance of a segment exceeds a limit set by the EU.")
                    Text("This limit depends on the average speed of the corresponding segment.")
                    Text("In this drive and segment, the lower limit is **\(calculateLowDynamics(avg_speed: avg_speed)) m/s²**")
                }
                
                func calculateLowDynamics(avg_speed: Double) -> String {
                    let value: Double
                    if avg_speed < 94.05 {
                        if avg_speed == 0.0 {
                            value = 0.0
                        } else {
                            value = -0.0016 * avg_speed + 0.1755
                        }
                    } else {
                        value = 0.025
                    }
                    return String(format: "%.2f", value)
                }
            }
        }
    }
}
