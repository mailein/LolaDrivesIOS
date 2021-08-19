//
//  Util.swift
//  Greetings
//
//  Created by Mei Chen on 19.08.21.
//

import Foundation

func specFile(filename: String) -> String{
    // file name and file type
    let filenameAndType = filename.components(separatedBy: ".")
    var name = filenameAndType[0]
    let type = filenameAndType[1]
    if(filenameAndType.count != 2){
        for (n, x) in filenameAndType.enumerated(){
            if (n != 0 && n != filenameAndType.count - 1) {
                name += "." + x
            }
        }
    }
    // file path
    let bundle = Bundle.main
    let path = bundle.path(forResource: name, ofType: type)
    print(path!)
    
    do {
        return try String(contentsOf: URL(fileURLWithPath: path!), encoding: .utf8)
    }
    catch {
        return "error: read specFile"
    }
}
