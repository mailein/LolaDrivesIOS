//
//  ViewModel.swift
//  UITryout
//
//  Created by Mei Chen on 07.01.22.
//

import SwiftUI
import Foundation

class ViewModel: ObservableObject {
    @Published var model: Model = Model()
    @Published var obd: MyOBD = MyOBD()
    //MARK: - Intents
    func selectProfile(_ profile: Profile) {
        model.setSelectedProfile(to: profile)
        //TODO: set selected profile in MyOBD
    }
    
    func deleteProfile(_ profile: Profile){
        model.deleteProfile(profile)
    }
    
    func addProfile(_ profile: Profile){
        model.addProfile(profile)
    }
    
    func getSelectedProfile() -> Profile{
        return model.selectedProfile
    }
    
    //MARK: - monitoring view
    func getOBD() -> MyOBD {
        return obd
    }
    
    func startOBD(){//Start button in RDE view
        obd.viewDidLoad()
    }
    
    func stopOBD() {//Stop button in RDE view
        obd.disconnect()
    }
    
    func isConnected() -> Bool {
        return obd.isConnected
    }
    
    func getCurrentCommands() -> [CommandItem] {
        if obd.selectedCommands.isEmpty{
            return obd.rdeProfile
        }else{
            return obd.selectedCommands
        }
    }
    
    func isStartLiveMonitoring() -> Bool {
        return model.startLiveMonitoring
    }
    
    func liveMonitoring(){
        if model.startLiveMonitoring {//start live monitoring
            obd.selectedCommands = model.selectedProfile.commands
            obd.viewDidLoad()
        }else{//stop live monitoring
            obd.disconnect()
            obd.selectedCommands = []
        }
        model.startLiveMonitoring.toggle()
    }
}

