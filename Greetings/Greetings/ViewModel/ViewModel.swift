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
    
    //MARK: - Intents
    func selectProfile(_ profile: Profile) {
        model.setSelectedProfile(to: profile)
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
    
    func getSelectedProfileCommands() -> [CommandItem]{
        return model.selectedProfile.commands.filter{ $0.enabled }
    }
    
    //MARK: - rde view
    func startRDE() {
        model.startRDE()
    }
        
    func exitRDE() {
        model.exitRDE()
    }
    
    func getDistanceSetting() -> Int {
        return Int(model.distanceSetting)
    }
    
    //MARK: - monitoring view
    func isStartLiveMonitoringButton() -> Bool {
        return model.startLiveMonitoring
    }
    
    func startLiveMonitoringToggle(){
        model.startLiveMonitoring.toggle()
    }
    
    //MARK: - profiles view
    func editProfile(to editedProfile: Profile) {
        model.editProfileData(to: editedProfile)
    }
}

