import Foundation

class CommandItem: Identifiable, Codable, Equatable, Hashable{
    let mode: Int
    let pid: String
    let id: Int
    let name: String
    let unit: String
    var enabled: Bool
    
    init (mode: Int = 1, pid: String, name: String, unit: String, enabled: Bool = false) {
        self.mode = mode
        self.pid = pid
        self.id = Int(pid, radix: 16) ?? -1
        self.name = name
        self.unit = unit
        self.enabled = enabled
    }
    
    //conform to Hashable
    func hash(into hasher: inout Hasher){
        hasher.combine(mode)
        hasher.combine(pid)
        hasher.combine(name)
    }
}

//conform to Equatable
func ==(lhs: CommandItem, rhs: CommandItem) -> Bool {
    return ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
}
