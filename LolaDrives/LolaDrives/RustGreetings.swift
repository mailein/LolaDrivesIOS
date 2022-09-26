import Foundation

class RustGreetings {
    //both inputs and outputs should be in the same order as in spec file
    private var INITIAL_RELEVANT_OUTPUTS = [
//        "vp",//is_urban: vp <= 60.0, is_rural: (60.0 < vp) && (vp <= 90.0), is_motorway: 90.0 < vp
//        "altitudep",
//        "temperaturep",
//        "nox_ppmp",
//        "exhaust_mass_flowp",
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
        "a",
//        "va",
//        "u_va_pct_h", //=va if a >= 0.1 && is_urban
            "u_va_pct",
//        "r_va_pct_h", //=va if a >= 0.1 && is_rural
            "r_va_pct",
//        "m_va_pct_h", //=va if a >= 0.1 && is_motorway
            "m_va_pct",
            "u_rpa",
            "r_rpa",
            "m_rpa",
//        "nox_mass_flow",
//        "D_nox_mass",
//        "nox_mass_aggregated",
            "nox_per_kilometer",
            "is_valid_test_num",
            "not_rde_test_num",
        "nox_per_kilometer_u",
        "nox_avg_u",
        "nox_per_kilometer_r",
        "nox_avg_r",
        "nox_per_kilometer_m",
        "nox_avg_m"
        ]
    private var RELEVANT_OUTPUTS: [String] = []
    
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
    
    func initmonitor(s: String, customOutputNames: [String]) -> String{
        print("spec file: \(s)")
        resetRelevantOutputs()
        appendCustomOutputNames(names: customOutputNames)
        let result = rust_initmonitor(s, RELEVANT_OUTPUTS.joined(separator: ","))
        let swift_result = String(cString: result!)
        rust_string_free(UnsafeMutablePointer(mutating: result))
        return swift_result
    }
    
    struct rust_tuple {
        let count: Int32
        let array: UnsafeMutablePointer<Double>
    }
    
    func sendevent(inputs: (inout [Double]), len_in: UInt32) -> [String: Double]{
        var len: UInt32 = 0
        let result = rust_sendevent(&inputs, len_in, &len)
        let swift_result: [Double] = Array(UnsafeBufferPointer(start: result, count: Int(len)))
        rust_array_free(result, len)
        if swift_result.isEmpty {
            return [String: Double]()
        } else {
            let dict = Dictionary(uniqueKeysWithValues: zip(RELEVANT_OUTPUTS, swift_result))
            return dict
        }
    }
    
    func resetRelevantOutputs() {
        self.RELEVANT_OUTPUTS = self.INITIAL_RELEVANT_OUTPUTS
    }
    
    func appendCustomOutputNames(names: [String]) {
        for name in names {
            self.RELEVANT_OUTPUTS.append(name)
        }
    }
}
