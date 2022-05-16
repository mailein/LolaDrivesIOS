import Foundation
import pcdfcore

class EventStore: ObservableObject {
    @Published var events: [PCDFEvent] = []
    
    private static func fileURL(fileName: String) throws -> URL {
        try FileManager.default.url(for: .documentDirectory,
                                    in: .userDomainMask,
                                    appropriateFor: nil,
                                    create: false)
        .appendingPathComponent(fileName)
    }
    
    static func load(fileName: String, completion: @escaping (Result<[PCDFEvent], Error>)-> Void) {
        DispatchQueue.global(qos: .background).async {
            do {
                let fileURL = try fileURL(fileName: fileName)
//                let file = try? FileHandle(forReadingFrom: fileURL)
                let events = [PCDFEvent]()
                //TODO: turn each line to an event, then append to events
                let contentStr = try String(contentsOf: fileURL, encoding: String.Encoding.utf8)
                let texts = contentStr.split(separator: "\n")
                for text in texts {
                    
                }
                DispatchQueue.main.async {
                    completion(.success(events))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }
    
    static func save(to fileName: String, events: [PCDFEvent], completion: @escaping (Result<Int, Error>)->Void) {
        DispatchQueue.main.async {//global(qos: .background)
            let serializer = Serializer()
            do {
                let outfile = try fileURL(fileName: fileName)
                //TODO: create the file before write to it
                
                //TODO: app id
                var data = serializer.generateFromPattern(pattern: MetaEvent(source: "app id",
                                                                             timestamp: Int64(Date().timeIntervalSinceReferenceDate),//TODO
                                                                             pcdf_type: "PERSISTENT",
                                                                             ppcdf_version: "1.0.0",
                                                                             ipcdf_version: nil).getPattern()) + "\n"
                print("MetaEvent: \(data)")
                try data.write(to: outfile, atomically: true, encoding: .utf8)
                
                var file = try? FileHandle(forUpdating: outfile)
                
                for event in events {
                    if let event = event as? OBDEvent {
                        data = serializer.generateFromPattern(pattern: OBDEvent(source: event.source,
                                                                                timestamp: event.timestamp,
                                                                                bytes: event.bytes).getPattern()) + "\n"
                        print("data written to file: \(data)")
                    } else {
                        data = serializer.generateFromPattern(pattern: event.getPattern()) + "\n"
                    }
                    print("event: \(data)")
                    try file?.seekToEnd()
                    try file?.write(contentsOf: data.data(using: .utf8)!)
                }
                
                try file?.close()
                
                //debug
                file = try? FileHandle(forReadingFrom: outfile)
                let dataRead = try file?.readToEnd()
                print(String(decoding: dataRead!, as: UTF8.self))
                
                DispatchQueue.main.async {
                    completion(.success(events.count))
                }
            }catch{
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }
}
