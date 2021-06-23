//
//  ContentView.swift
//  Greetings
//
//  Created by Mei Chen on 28.04.21.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        let rustGreetings = RustGreetings()
        let text = "\(rustGreetings.sayHello(to: "world"))"
        let num = "\(rustGreetings.add(a:1, b:2))"
//        let text1 = "\(rustGreetings.initmonitor(s: "hello"))"
        let bytes: [Double] = [39, 77, 111, 111, 102, 33, 39, 0]
        let a = "\(rustGreetings.sendevent(inputs: bytes))"
        HStack{
            Text(text)
            Text(num)
//            Text(text1)
            Text(a)
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
