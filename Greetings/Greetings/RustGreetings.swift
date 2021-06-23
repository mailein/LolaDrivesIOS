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
    
    func sendevent(inputs: [Double]) -> ([Double], Int32){
        let pointer: UnsafeMutablePointer<Double> = UnsafeMutablePointer(mutating: inputs)
        let result = rust_sendevent(pointer)
        let tuple = rust_tuple(count: result.rust_count, array: result.rust_array)
        let swift_result: [Double] = Array(UnsafeBufferPointer(start: tuple.array, count: Int(tuple.count)))
        return (swift_result, tuple.count)
    }
}
