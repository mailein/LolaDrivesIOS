//
//  PcdfParser.swift
//  Greetings
//
//  Created by Mei Chen on 09.08.21.
//

import Foundation
import pcdfcore

struct PatternParser {
    
    func parse() -> [PCDFEvent] {
//        let content = specFile(filename: "ppcdf/nox-valid.ppcdf")
        let content = specFile(filename: "ppcdf/2021-09-13_11-45-26.ppcdf")
//        let content = specFile(filename: "ppcdf/2021-09-13_12-02-52.ppcdf")
//        let content = specFile(filename: "ppcdf/2021-09-13_12-03-30.ppcdf")
//        let content = specFile(filename: "ppcdf/2021-09-13_12-04-29.ppcdf")
//        let content = specFile(filename: "ppcdf/2021-09-13_12-12-53.ppcdf")
//        let content = specFile(filename: "ppcdf/2021-09-13_15-07-19.ppcdf")
        let lines = content.components(separatedBy: "\n")
        var events : [PCDFEvent] = []
        
        for l in lines{
            let line = l.trimmingCharacters(in: .whitespacesAndNewlines)
            if line.isEmpty{
                continue
            }
            let event = PCDFEvent.Companion().fromString(string: line)
            let intermediate = event.toIntermediate()
            events.append(intermediate)
        }
        
        return events
    }
    
}
