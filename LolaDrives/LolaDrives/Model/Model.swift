import Foundation

class Model: ObservableObject{
    //RDE view
    @Published var started: Bool = false
    @Published var isRDEMonitoring: Bool = false
    @Published var distanceSetting: Float = 83
    
    //Monitoring view
    @Published var startLiveMonitoring: Bool = true
    
    //profiles view
    @Published var profiles: [Profile]
    @Published var selectedProfile: Profile?
    let profilesDataKey: String = "ProfilesData"
    
    //privacy view
    @Published var dataDonationEnabled: Bool = false
    
    init() {
        let profilesData: [Data] = UserDefaults.standard.array(forKey: profilesDataKey) as? [Data] ?? []
        if profilesData.isEmpty {
            let defaultProfile = Profile("default_profile", commands: ProfileCommands.commands)
            defaultProfile.commands.first(where: {$0.pid == "0D"})?.enabled.toggle()//speed
            defaultProfile.commands.first(where: {$0.pid == "0C"})?.enabled.toggle()//RPM
            
            let allEnabledProfile = Profile("all_supported", commands: ProfileCommands.commands)
            allEnabledProfile.commands.forEach{$0.enabled.toggle()}
            
            profiles = [defaultProfile, allEnabledProfile]
            selectedProfile = defaultProfile
            defaultProfile.isSelected = true
            
            //save profiles information to UserDefaults
            let defaultProfileData = ProfileData(profile: defaultProfile).toData()
            let allEnabledProfileData = ProfileData(profile: allEnabledProfile).toData()
            
            UserDefaults.standard.set([defaultProfileData, allEnabledProfileData], forKey: profilesDataKey)
        } else {
            let decoder = JSONDecoder()
            profiles = profilesData.map{
                do{
                    let profileData = try decoder.decode(ProfileData.self, from: $0)
                    return profileData.restoreProfile()
                } catch {
                    print(error.localizedDescription)
                    return Profile("error decoding ProfileData", commands: ProfileCommands.commands)
                }
            }
            selectedProfile = nil
        }
    }
    
    //func to update the properties
    //MARK: - RDE
    func setDistanceSetting (to newDistanceSetting: Float) {
        self.distanceSetting = newDistanceSetting
    }
    
    func startRDE() {
        isRDEMonitoring = true
        started = true
    }
    
    func exitRDE() {
        isRDEMonitoring = false
        started = false
    }
    
    //MARK: - Profiles
    func getSelectedProfile() -> Profile? {
        if selectedProfile != nil {
            return selectedProfile
        }else if !profiles.isEmpty {
            selectedProfile = profiles.filter{ $0.isSelected }.first!//because selectedProfile can't be set with self in init, so workaround here
            return selectedProfile
        }else{
            return nil
        }
    }
    
    func setSelectedProfile (to newProfile: Profile) {
        print("select profile \(newProfile.name)")
//        if self.selectedProfile!.id == newProfile.id {
//            print("you can't deselect without selecting any profile first")
//            return
//        }
        //deselect the old one
        if self.selectedProfile != nil {
            let lastIndex = self.profiles.firstIndex(of: self.selectedProfile!)
            if lastIndex != nil {
                let p = profiles[lastIndex!]
                p.isSelected.toggle()
                
                selectToggleProfileData(p)
            }
        }
        //select the new one
        self.selectedProfile = newProfile
        let index = self.profiles.firstIndex(of: newProfile)
        if index != nil {
            let p = profiles[index!]
            p.isSelected.toggle()
            
            selectToggleProfileData(p)
        }
    }
    
    func addProfile (_ newProfile: Profile) {
        self.profiles.append(newProfile)
        
        addProfileData(newProfile)
        
        //if this is the first profile, also set it to selectedProfile
        if profiles.count == 1 {        
            setSelectedProfile(to: newProfile)
        }
    }
    
    func deleteProfile (_ profile: Profile) {
        let index = self.profiles.firstIndex(of: profile)
        if index != nil {
            self.profiles.remove(at: index!)
            
            deleteProfileData(profile)
        }
        
        //deleting the selected profile shall set new selected profile
        if profiles.isEmpty {
            selectedProfile = nil
        }
        if !profiles.isEmpty && profile.id == self.selectedProfile!.id {//this selectedProfile is the old selected one
            setSelectedProfile(to: profiles[0])
        }
    }
    
    //MARK: - Profiles in UserDefaults
    func selectToggleProfileData(_ profile: Profile) {
        let decoder = JSONDecoder()
        var profilesData: [Data] = UserDefaults.standard.array(forKey: profilesDataKey) as? [Data] ?? []
        for (i, data) in profilesData.enumerated() {
            do {
                var profileData = try decoder.decode(ProfileData.self, from: data)
                if profileData.id == profile.id {
                    profileData.isSelected.toggle()
                    //don't forget to replace the data!!!
                    profilesData[i] = profileData.toData()!
                }
            } catch {
                print(error.localizedDescription)
            }
        }
        
        UserDefaults.standard.set(profilesData, forKey: profilesDataKey)
    }
    
    func addProfileData(_ profile: Profile) {
        let profileData = ProfileData(profile: profile)
        var profilesData: [Data] = UserDefaults.standard.array(forKey: profilesDataKey) as? [Data] ?? []
        if let data = profileData.toData() {
            profilesData.append(data)
        }
        UserDefaults.standard.set(profilesData, forKey: profilesDataKey)
    }
    
    func deleteProfileData(_ profile: Profile) {
        let decoder = JSONDecoder()
        var profilesData: [Data] = UserDefaults.standard.array(forKey: profilesDataKey) as? [Data] ?? []
        for (i, data) in profilesData.enumerated() {
            do {
                let profileData = try decoder.decode(ProfileData.self, from: data)
                if profileData.id == profile.id {
                    profilesData.remove(at: i)
                    break
                }
            } catch {
                print(error.localizedDescription)
            }
        }
        UserDefaults.standard.set(profilesData, forKey: profilesDataKey)
    }
    
    func editProfileData(to editedProfile: Profile) {
        let decoder = JSONDecoder()
        var profilesData: [Data] = UserDefaults.standard.array(forKey: profilesDataKey) as? [Data] ?? []
        for (i, data) in profilesData.enumerated() {
            do {
                let profileData = try decoder.decode(ProfileData.self, from: data)
                if profileData.id == editedProfile.id, let newData = ProfileData(profile: editedProfile).toData() {
                    profilesData[i] = newData
                    break
                }
            } catch {
                print(error.localizedDescription)
            }
        }
        UserDefaults.standard.set(profilesData, forKey: profilesDataKey)
    }
}
