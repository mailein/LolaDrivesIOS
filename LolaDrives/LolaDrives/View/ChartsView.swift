import SwiftUI
import pcdfcore
import Charts

struct ChartsView: View {
    var fileURL: URL
    var fileName: String
    @StateObject private var eventStore = EventStore()
    @State private var selectedChart: ChartDataName = .avgNoxAtFuelrate
    
    init(fileURL: URL){
        self.fileURL = fileURL
        self.fileName = fileURL.lastPathComponent
    }
    
    init(fileName: String){
        do {
            try self.fileURL = EventStore.fileURL(fileName: fileName)
        }catch{
            self.fileURL = URL(fileURLWithPath: "")
        }
        self.fileName = fileName
    }
    
    var body: some View {
        //ScrollView doesn't work automatically with Charts without specifying the width and height of the chart
        //when tapping on the chart, you can't scroll, you have to tap the blank space outside the chart -> may be use a selector?
        VStack{
            Picker("Please choose a chart", selection: $selectedChart){
                Text("avg nox at fuel rate").tag(ChartDataName.avgNoxAtFuelrate)
                Text("avg fuel rate at speed").tag(ChartDataName.avgFuelrateAtSpeed)
                Text("speed").tag(ChartDataName.speed)
                Text("nox").tag(ChartDataName.nox)
                Text("altitude").tag(ChartDataName.altitude)
                Text("fuel rate").tag(ChartDataName.fuelrate)
                Text("acceleration").tag(ChartDataName.acceleration)
                //            BarChartView(data: ChartData(values: eventStore.avgNoxAtFuelrate), title: "avg(nox)[mg] at fuel rate[l/h]", form: ChartForm.extraLarge, dropShadow: false, valueSpecifier: "%.2f")
                //            BarChartView(data: ChartData(values: eventStore.avgFuelrateAtSpeed), title: "avg(fuel rate)[l/h] at speed[km/h]", form: ChartForm.extraLarge, dropShadow: false, valueSpecifier: "%.2f")
                //            if !eventStore.speedValues.isEmpty {
                //                LineChartView(data: eventStore.speedValues, title: "", form: ChartForm.extraLarge, rateValue: 0, dropShadow: false, valueSpecifier: "%.0f")
                //            } else {
                //                Text("speed chart not available")
                //            }
                //            if !eventStore.noxValues.isEmpty {
                //                LineChartView(data: eventStore.noxValues, title: "nox[ppm]", form: ChartForm.extraLarge, rateValue: 0, dropShadow: false, valueSpecifier: "%.0f")
                //            } else {
                //                Text("nox chart not available")
                //            }
                //            if !eventStore.accelerationValues.isEmpty {
                //                LineChartView(data: eventStore.accelerationValues, title: "acceleration[m/s2]", form: ChartForm.extraLarge, rateValue: 0, dropShadow: false, valueSpecifier: "%.2f")
                //            } else {
                //                Text("acceleration chart not available")
                //            }
            }
            .pickerStyle(.wheel)
            .frame(height: 80)
            switch selectedChart {
            case .avgNoxAtFuelrate:
                SingleBarChartView(entries: eventStore.tuplesToDataEntries(tuples: eventStore.avgNoxAtFuelrate), label: "avg(nox)[mg] at fuel rate[l/h]", xIndex: eventStore.getXIndexValues(tuples: eventStore.avgNoxAtFuelrate))
                    .background(Color.white)//so that the picker choices are not displayed behind the transparent background
            case .avgFuelrateAtSpeed:
                SingleBarChartView(entries: eventStore.tuplesToDataEntries(tuples: eventStore.avgFuelrateAtSpeed), label: "avg(fuel rate)[l/h] at speed[km/h]", xIndex: eventStore.getXIndexValues(tuples: eventStore.avgFuelrateAtSpeed))
                    .background(Color.white)
            case .speed:
                SingleLineChartView(entries: eventStore.arrayToDataEntries(array: eventStore.speedValues), label: "speed[km/h]", xIndex: eventStore.getXIndexValues(array: eventStore.speedValues))
                    .background(Color.white)
            case .nox:
                SingleLineChartView(entries: eventStore.arrayToDataEntries(array: eventStore.noxValues), label: "nox[ppm]", xIndex: eventStore.getXIndexValues(array: eventStore.noxValues))
                    .background(Color.white)
            case .altitude:
                SingleLineChartView(entries: eventStore.arrayToDataEntries(array: eventStore.altitudeValues), label: "altitude[m]", xIndex: eventStore.getXIndexValues(array: eventStore.altitudeValues))
                    .background(Color.white)
            case .fuelrate:
                SingleLineChartView(entries: eventStore.arrayToDataEntries(array: eventStore.fuelrateValues), label: "fuel rate[l/h]", xIndex: eventStore.getXIndexValues(array: eventStore.fuelrateValues))
                    .background(Color.white)
            case .acceleration:
                SingleLineChartView(entries: eventStore.arrayToDataEntries(array: eventStore.accelerationValues), label: "acceleration[m/s2]", xIndex: eventStore.getXIndexValues(array: eventStore.accelerationValues))
                    .background(Color.white)
            }
        }
        .onAppear{
            //reset upon different files
            eventStore.resetValues()
            
            EventStore.load(fileURL: fileURL) { result in
                if case .success(let events) = result {
                    //altitude
                    let gpsEvents: [GPSEvent] = events
                        .filter{ $0.type == pcdfcore.EventType.gps }
                        .map{ $0 as! GPSEvent }
                    eventStore.altitudeValues = gpsEvents
                        .map{ $0.altitude }
                    
                    //speed, nox, fuelrate
                    let reducedEvents: [OBDIntermediateEvent] = events
                        .filter{ $0.type == pcdfcore.EventType.obdResponse }
                        .map{
                            let rEvent = ($0 as! OBDEvent).toIntermediate()
                            return MultiSensorReducer().reduce(event: rEvent) as! OBDIntermediateEvent
                        }
                    eventStore.speedValues = reducedEvents
                        .filter{ $0 is pcdfcore.SpeedEvent }
                        .map{ Double(($0 as! SpeedEvent).speed) }
                    eventStore.noxValues = reducedEvents
                        .filter{ $0 is pcdfcore.NOXReducedEvent }
                        .map{ Double(($0 as! NOXReducedEvent).nox_ppm) }
                    eventStore.fuelrateValues = reducedEvents
                        .filter{ $0 is FuelRateReducedEvent }
                        .map{ ($0 as! FuelRateReducedEvent).fuelRate }
                    
                    let rdeValidator = RDEValidator()
                    do {
                        eventStore.outputs = try rdeValidator.monitorOffline(data: events)
                        
                        //avg(nox) at fuelrate
                        var keyPrefix = "nox_avg_at_fuel_rate_"
                        var scaler = 1000
                        eventStore.avgNoxAtFuelrate = extract(from: eventStore.outputs, keyPrefix: keyPrefix, scaler: scaler)
                        print("avg(nox) at fuelrate: \(eventStore.avgNoxAtFuelrate)")
                        
                        //avg(fuelrate) at speed
                        keyPrefix = "fuel_rate_avg_at_speed_"
                        scaler = 1
                        eventStore.avgFuelrateAtSpeed = extract(from: eventStore.outputs, keyPrefix: keyPrefix, scaler: scaler)
                        print("avg(fuelrate) at speed: \(eventStore.avgFuelrateAtSpeed)")
                        
                        //acceleration
                        var accelerationValues: [Double] = []
                        for output in rdeValidator.allOutputs {
                            if let acceleration = output["a"] {
                                accelerationValues.append(acceleration)
                            }
                        }
                        eventStore.accelerationValues = accelerationValues
                    } catch {
                        print(error.localizedDescription)
                    }
                    print("rde result successfully loaded \(events.count) events")
                }
            }
        }
    }
    
    func extract(from outputs: [String: Double], keyPrefix: String, scaler: Int) -> [(String, Double)] {
        let ret = outputs
            .filter{ $0.key.contains(keyPrefix) }
            .map{ ($0.key.replacingOccurrences(of: keyPrefix, with: ""), $0.value * Double(scaler)) } //nox in mg
            .sorted(by: { (a, b) in
                return Int(a.0.components(separatedBy: "_")[0]) ?? 0 < Int(b.0.components(separatedBy: "_")[0]) ?? 0
            })
        return ret
    }
}
