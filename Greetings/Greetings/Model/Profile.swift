import Foundation

class Profile: Identifiable, Hashable, ObservableObject{
    var id = UUID()
    @Published var name: String
    @Published var commands: [CommandItem] = []
    @Published var isSelected: Bool = false
    
    init(_ name: String = "", commands: [CommandItem]){
        self.name = name
        self.commands = commands
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
