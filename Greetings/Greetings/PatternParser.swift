//
//  PcdfParser.swift
//  Greetings
//
//  Created by Mei Chen on 09.08.21.
//

import Foundation
import pcdfcore

struct PatternParser {
    
    func parse(){
        let s =
            """
            {"source":"00001101-0000-1000-8000-00805f9b34fb","type":"OBD_RESPONSE","timestamp":7787591305037,"data":{"bytes":"49020157424131503531303230354E3433303638"}}
            """
        PCDFEvent.Companion().fromString(string: s).toIntermediate()
    }
    
}
