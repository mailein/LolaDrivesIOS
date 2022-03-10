import Foundation

struct Model{
    //OBD
    let obd: MyOBD
    
    //nav bar
    private var _isConnected: Bool
    var isConnected: Bool {
        get {
            return self._isConnected
        }
        set {
            self._isConnected = newValue
            if(newValue){
                self.obd.viewDidLoad()
            }else{
                self.obd.disconnect()
            }
        }
    }
    
    //RDE view
    var distanceSetting: Int = 84
    //RDE details view
    var totalTime: Double = 0
    var dynamics: Dynamics = Dynamics(durationTotal: 0, distanceTotal: 0)
    
    //profiles view
    let defaultProfile: Profile = Profile("default_profile", enabled: ["RPM", "SPEED"])
    let allEnabledProfile: Profile = Profile("all_supported", enabled: ProfileCommands.commands.map{$0.name})
    var profiles: [Profile]
    var selectedProfile: Profile
    var lastSelectedProfile: Profile
    
    //Monitoring view
    
    
    init() {
        obd = MyOBD()
        _isConnected = false
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
    
    //MARK: - monitor
}
