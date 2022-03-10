import Foundation

class Profile: Identifiable, Hashable, ObservableObject{
    var id = UUID()
    @Published var name: String
    @Published var commands: [CommandItem] = []
    var enabledCommandNames: [String]
    @Published var isSelected: Bool = false
    
    init(_ name: String = "", enabled: [String]){
        self.name = name
        self.enabledCommandNames = enabled
        for command in ProfileCommands.commands {
            //self.commands = ProfileCommands.commands or self.commands.append(command) won't work, must use deep copy
            self.commands.append(CommandItem(pid: command.pid, name: command.name, unit: command.unit))
        }
        for enabledElem in enabled {
            if self.commands.contains(where: {$0.name == enabledElem}) {
                self.commands.first(where: {$0.name == enabledElem})?.enabled.toggle()
            } else {
                print("Error: try to enable command \(enabledElem) not found.")
            }
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
