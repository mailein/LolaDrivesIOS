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
    
    func startOBD() {
        let obd = MyOBD()
        model.obd = obd
        obd.viewDidLoad()
    }
    
    func getOBD() -> MyOBD? {
        return model.obd
    }
}

