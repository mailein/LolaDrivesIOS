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
        let content = specFile(filename: "nox-valid.ppcdf")
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
