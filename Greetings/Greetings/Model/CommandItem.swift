import Foundation
import LTSupportAutomotive

class CommandItem: Identifiable{
    let mode: Int
    let pid: String // in hex
    let id: Int // in decimal
    let name: String
    let unit: String
    let obdCommand: LTOBD2PID
    var enabled: Bool
    
    init (mode: Int = 1, pid: String, name: String, unit: String, obdCommand: LTOBD2PID, enabled: Bool = false) {
        self.mode = mode
        self.pid = pid
        //hashValue differs after each app restart, so use name in ProfileData, as it's unique among [CommandItem] within the same profile
        //document: Hash values are not guaranteed to be equal across different executions of your program.
        self.id = Int(pid, radix: 16)! + unit.hashValue
        self.name = name
        self.unit = unit
        self.obdCommand = obdCommand
        self.enabled = enabled
    }
}

extension Array where Element: CommandItem {
    func getByPid(pid: String) -> Element? {
        let ret = self.filter { $0.pid == pid}
        if ret.isEmpty {
            return nil
        } else {
            return ret[0]
        }
    }
}
