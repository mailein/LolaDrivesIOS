//
//  RustGreetings.swift
//  Greetings
//
//  Created by Mei Chen on 28.04.21.
//

import Foundation

class RustGreetings {
    func sayHello(to: String) -> String {
        let result = rust_greeting(to)
        let swift_result = String(cString: result!)
        rust_greeting_free(UnsafeMutablePointer(mutating: result))
        return swift_result
    }
    
    func add(a: Int16, b: Int16) -> Int16{
        return rust_add(a,b)
    }
    
    func initmonitor(s: String) -> String{
        let result = rust_initmonitor(s)
        let swift_result = String(cString: result!)
        rust_greeting_free(UnsafeMutablePointer(mutating: result))
        return swift_result
    }
    
    struct rust_tuple {
        let count: Int32
        let array: UnsafeMutablePointer<Double>
    }
    
    func sendevent(inputs: (inout [Double]), len_in: UInt32) -> [Double]{
        var len: UInt32 = 0
        let result = rust_sendevent(&inputs, len_in, &len)
        let swift_result: [Double] = Array(UnsafeBufferPointer(start: result, count: Int(len)))
//        rust_array_free(result)
        return swift_result
    }
}
