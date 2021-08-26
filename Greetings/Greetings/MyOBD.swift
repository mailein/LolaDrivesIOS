//
//  MyOBD.swift
//  Greetings
//
//  Created by Mei Chen on 26.08.21.
//

import Foundation
import OBD2

class MyOBD{
    
    func a ()->() {
        let obd = OBD2()
        
        obd.connect { [weak self] (success, error) in
                     if let error = error {
                         print("OBD connection failed with \(error)")

                     } else {
                         //perform something
                     }
               }
    }
}
