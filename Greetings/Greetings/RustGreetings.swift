import Foundation

class RustGreetings {
    let RELEVANT_OUTPUTS = [
//        "duration",
            "d",
            "d_u",
            "d_r",
            "d_m",
            "t_u",
            "t_r",
            "t_m",
            "u_avg_v",
            "r_avg_v",
            "m_avg_v",
            "u_va_pct",
            "r_va_pct",
            "m_va_pct",
            "u_rpa",
            "r_rpa",
            "m_rpa",
            "nox_per_kilometer",
            "is_valid_test",
            "not_rde_test"
        ]
    
//    func sayHello(to: String) -> String {
//        let result = rust_greeting(to)
//        let swift_result = String(cString: result!)
//        rust_greeting_free(UnsafeMutablePointer(mutating: result))
//        return swift_result
//    }
//
//    func add(a: Int16, b: Int16) -> Int16{
//        return rust_add(a,b)
//    }
    
    func initmonitor(s: String) -> String{
        let result = rust_initmonitor(s, RELEVANT_OUTPUTS.joined(separator: ","))
        let swift_result = String(cString: result!)
        rust_string_free(UnsafeMutablePointer(mutating: result))
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
