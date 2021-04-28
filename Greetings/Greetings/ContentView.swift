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
        Text(text)
            .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
