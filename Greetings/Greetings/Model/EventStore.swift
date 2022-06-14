import Foundation
import pcdfcore

class EventStore: ObservableObject {
    @Published var events: [PCDFEvent] = []
    
    
    //MARK: - directory
    public static func dirURL() throws -> URL {
        try FileManager.default.url(for: .documentDirectory,
                                    in: .userDomainMask,
                                    appropriateFor: nil,
                                    create: false)
    }
    
    //MARK: - files
    public static func getAllFiles() -> [URL] {
        do {
            let dir = try dirURL()
            let dirContents = try FileManager.default.contentsOfDirectory(at: dir,
                                                                      includingPropertiesForKeys: nil)
            var ppcdfFiles = dirContents.filter{ $0.pathExtension == "ppcdf" }
//            ppcdfFiles.forEach{
//                print($0.path)
//            }
            ppcdfFiles.sort{ (a, b) in
                let dateFormatter = dateFormatter()

                let aLastPathComponent = a.deletingPathExtension().lastPathComponent
                let bLastPathComponent = b.deletingPathExtension().lastPathComponent
                let aDate = dateFormatter.date(from: aLastPathComponent)
                let bDate = dateFormatter.date(from: bLastPathComponent)
                
                guard let aDate = aDate, let bDate = bDate else {
                    return false
                }
                
                let compare = aDate.compare(bDate).rawValue
                return compare >= 0 //descending
            }
            return ppcdfFiles
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    
    public static func removeFile(_ file: URL) {
        do {
            try FileManager.default.removeItem(at: file)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    //FOR DEBUG ONLY: clean dir at the start of app run
    public static func clearAllFiles() {
        let files = getAllFiles()
        do {
            for file in files {
                try FileManager.default.removeItem(at: file)
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    //MARK: - file
    public static func fileURL(fileName: String) throws -> URL {
        try dirURL().appendingPathComponent(fileName)
    }
    
    static func load(fileURL: URL, completion: @escaping (Result<[PCDFEvent], Error>)-> Void) {
        do {
//            let fileURL = try fileURL(fileName: fileName)
//                let file = try? FileHandle(forReadingFrom: fileURL)
            var events = [PCDFEvent]()
            
            let fileRead = try? FileHandle(forReadingFrom: fileURL)
            let dataRead = try fileRead?.readToEnd()
            let contentStr = String(decoding: dataRead!, as: UTF8.self)
//            let contentStr = try String(contentsOf: fileURL, encoding: String.Encoding.utf8)
            try fileRead?.close()
            
            let texts = contentStr.components(separatedBy: "\n").filter{ !$0.isEmpty }
            for text in texts {
                let event = PCDFEvent.Companion().fromString(string: text)
                events.append(event)
            }
            
            completion(.success(events))
        } catch {
            completion(.failure(error))
        }
    }
    
    static func save(to fileName: String, event: PCDFEvent, createFile: Bool = false, completion: @escaping (Result<Int, Error>)->Void) {
        var str: String = ""
        //toIntermediate() will be used in HistoryView to show intermediateEvent.toString() message, so no need to transform to intermediate here
        if let event = event as? OBDEvent {
            str = Serializer().generateFromPattern(pattern: OBDEvent(source: event.source,
                                                                    timestamp: event.timestamp,
                                                                   bytes: event.bytes).getPattern()) + "\n"
        } else {//Meta, SupportPids, Error, GPS
            str = Serializer().generateFromPattern(pattern: event.getPattern()) + "\n"
        }
        DispatchQueue.main.async {//TODO: bakcground thread causes data race, some lines are not complete
            do {
                let outfile = try fileURL(fileName: fileName)

                if createFile {
                    try str.write(to: outfile, atomically: true, encoding: .utf8)
                }else{
                    let file = try? FileHandle(forUpdating: outfile)
                    try file?.seekToEnd()
                    try file?.write(contentsOf: str.data(using: .utf8)!)
                    try file?.close()
                }

                DispatchQueue.main.async {
                    completion(.success(1))
                }
            }catch{
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }
    
    //MARK: - helper methods
    public static func dateFormatter() -> DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "de_DE_POSIX")
        dateFormatter.dateFormat = "yyyy.MM.dd, HH:mm:ss"
        return dateFormatter
    }
    
}
