import Foundation

class Profile: Identifiable, Hashable, ObservableObject{
    var id = UUID()
    @Published var name: String
    @Published var commands: [CommandItem] = []
    @Published var isSelected: Bool = false
    
    init(_ name: String = "", commands: [CommandItem]){
        self.name = name
        for command in commands {
            //self.commands = ProfileCommands.commands or self.commands.append(command) won't work, must use deep copy
            self.commands.append(CommandItem(pid: command.pid, name: command.name, unit: command.unit, obdCommand: command.obdCommand))
        }
        let enabled = commands.filter{ $0.enabled }
        for enabledElem in enabled {
            self.commands.first(where: {$0.id == enabledElem.id})?.enabled.toggle()
        }
    }
    
    static func == (lhs: Profile, rhs: Profile) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(name)
    }
}

//because Profile is not easily Codable, use a new struct,
//so that it can be transformed to Data and saved in UserDefaults
struct ProfileData: Codable {
    let id: UUID
    let name: String
    let commandNames: [String: Bool]
    var isSelected: Bool
    
    init(profile: Profile){
        self.id = profile.id
        self.name = profile.name
        self.commandNames = profile.commands.reduce(into: [String: Bool]()) { (dict, commandItem) in
            dict[commandItem.name] = commandItem.enabled
        }
        self.isSelected = profile.isSelected
    }
    
    func toData() -> Data? {
        do {
            let encoder = JSONEncoder()
            return try encoder.encode(self)
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }
    
    func restoreProfile() -> Profile {
        let profile = Profile("new", commands: ProfileCommands.commands)
        profile.id = self.id
        profile.name = self.name
        for command in profile.commands {
            command.enabled = self.commandNames[command.name]!
        }
        profile.isSelected = isSelected
        return profile
    }
}
