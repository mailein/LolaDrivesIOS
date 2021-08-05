//
//  ContentView.swift
//  Greetings
//
//  Created by Mei Chen on 28.04.21.
//

import SwiftUI
import pcdfcore

struct ContentView: View {
    var body: some View {
        let rustGreetings = RustGreetings()
        let text = "\(rustGreetings.sayHello(to: "world"))"
        let num = "\(rustGreetings.add(a:1, b:2))"
        
        let fileContent = SpecFile(filename: "rde-lola-test-drive-spec-no-percentile1.lola")
        let text1 = "\(rustGreetings.initmonitor(s: fileContent))"
        
        //6 input var in spec.lola, plus 1 time => 7 elements
        var bytes: [Double] = [18.0, 303.18824990035785, 288.15, 12.0, 15.94, 1.55, 5417.974006502]
        let a = "\(rustGreetings.sendevent(inputs: &bytes, len_in: UInt32(bytes.count)))"
        
        var bytes2: [Double] = [18.0, 303.18824990035785, 288.15, 6.0, 15.02, 0.7, 5419.009988532]
        let a2 = "\(rustGreetings.sendevent(inputs: &bytes2, len_in: UInt32(bytes2.count)))"
        
        let p = pcdfcore.PCDFEvent(source: "", type: EventType.gps, timestamp: 0)
        let serializedEvent = p.toIntermediate().serialize()
        let c = PCDFEvent.Companion().fromString(string: serializedEvent).toIntermediate()
        
        HStack{
            Text(text)
            Text(num)
            Text(text1)
            Text(a)
            Text(a2)
        }
        .padding()
    }
}

func SpecFile(filename: String) -> String{
    let file = filename //this is the file. we will write to and read from it
    if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
        let fileURL = dir.appendingPathComponent(file)
        //reading
        do {
            print(dir)
            return try String(contentsOf: fileURL, encoding: .utf8)
        }
        catch {
            //I put the spec file in this dir
            print(dir)
            return "a"
        }
    }
    return "b"
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
