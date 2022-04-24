import Foundation
import LTSupportAutomotive

class CommandItem: Identifiable{
    let mode: Int
    let pid: String // in hex
    let id: Int // in decimal
    let name: String
    let unit: String
    let obdCommands: [LTOBD2PID]
    var enabled: Bool
    
    init (mode: Int = 1, pid: String, name: String, unit: String, obdCommands: [LTOBD2PID], enabled: Bool = false) {
        self.mode = mode
        self.pid = pid
        self.id = Int(pid, radix: 16) ?? -1
        self.name = name
        self.unit = unit
        self.obdCommands = obdCommands
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
