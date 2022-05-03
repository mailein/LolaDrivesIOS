import Foundation

struct Model{
    //RDE view
    var started: Bool = false
    var distanceSetting: Int = 84
    //RDE details view
    var totalTime: Double = 0
    
    //Monitoring view
    var startLiveMonitoring: Bool = true
    
    //profiles view
    let defaultProfile: Profile
    let allEnabledProfile: Profile
    var profiles: [Profile]
    var selectedProfile: Profile
    var lastSelectedProfile: Profile
    
    //privacy view
    var dataDonationEnabled: Bool = false
    
    
    init() {
        let defaultCommands = ProfileCommands.commands //TODO: check, this is a copy, right???
        defaultCommands.first(where: {$0.pid == "0D"})?.enabled.toggle()//speed
        defaultCommands.first(where: {$0.pid == "0C"})?.enabled.toggle()//RPM
        defaultProfile = Profile("default_profile", commands: defaultCommands)
        
        let allEnabledCommnds = ProfileCommands.commands
        allEnabledCommnds.forEach{$0.enabled.toggle()}
        allEnabledProfile = Profile("all_supported", commands: allEnabledCommnds)
        
        profiles = [defaultProfile, allEnabledProfile]
        selectedProfile = defaultProfile
        defaultProfile.isSelected = true
        lastSelectedProfile = defaultProfile
    }
    
    //func to update the properties
    //MARK: RDE
    mutating func setDistanceSetting (to newDistanceSetting: Int) {
        self.distanceSetting = newDistanceSetting
    }
    
    //MARK: - Profiles
    mutating func setSelectedProfile (to newProfile: Profile) {
        print("select profile \(newProfile.name)")
        if self.selectedProfile.id == newProfile.id {
            print("you can't deselect without selecting any profile first")
            return
        }
        self.lastSelectedProfile = self.selectedProfile
        let lastIndex = self.profiles.firstIndex(of: self.selectedProfile)
        if lastIndex != nil {
            profiles[lastIndex!].isSelected.toggle()
        }
        self.selectedProfile = newProfile
        let index = self.profiles.firstIndex(of: newProfile)
        if index != nil {
            profiles[index!].isSelected.toggle()
        }
    }
    
    mutating func addProfile (_ newProfile: Profile) {
        self.profiles.append(newProfile)
    }
    
    mutating func deleteProfile (_ profile: Profile) {
        let index = self.profiles.firstIndex(of: profile)
        if index != nil {
            self.profiles.remove(at: index!)
        }
        
        //deleting the selected profile shall set new selected profile
        if profile.id == self.selectedProfile.id && !profiles.isEmpty {
            setSelectedProfile(to: profiles[0])
        }
    }
}
