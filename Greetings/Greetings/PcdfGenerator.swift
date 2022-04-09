import Foundation
import pcdfcore

struct PcdfGenerator{
    let jsonEncoder: JSONEncoder
    
    init(){
        jsonEncoder = JSONEncoder()
        jsonEncoder.outputFormatting = [.sortedKeys, .prettyPrinted]//maintain codingKeys order is unavailable, see https://bugs.swift.org/browse/SR-7992
    }
    
    func serialize(event: pcdfcore.PCDFEvent) -> Data? {
        return try? jsonEncoder.encode(event.getPattern())
    }
    
    func serialize(events: [pcdfcore.PCDFEvent]) -> Data? {
        let eventsPatterns = events.map{ $0.getPattern() }
        let ret = try? jsonEncoder.encode(eventsPatterns)
        
        //debug print
        let json = try? JSONSerialization.jsonObject(with: ret!, options: [])
        print("json of events: \(json!)")
        
        return ret
    }
    
    func save(data: Data, toFilename filename: String) {
        let fileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("\(filename).txt")
        do {
            try data.write(to: fileURL, options: [.atomicWrite])
        } catch let error as NSError {
            print("*********** can't save to a pcdf file, error: \(error.code), \(error)")
        }
        //now that the file is in a sandbox for the ios app, just print the content to see if it's correct
        do {
            let contents = try String(contentsOfFile: fileURL.path)
            print("blablaGenPcdf.ppcdf file content: \(contents)")
        }catch{
            print("can't print ppcdf file content")
        }
    }
}

//https://developer.apple.com/documentation/foundation/archives_and_serialization/encoding_and_decoding_custom_types
extension pcdfcore.PCDFDataPattern: Encodable{
    enum CodingKeys: String, CodingKey {
        case pcdf_type
        case ppcdf_version
        case longitude
        case latitude
        case altitude
        case gps_speed
        case bytes
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(pcdf_type, forKey: .pcdf_type)
        try container.encodeIfPresent(ppcdf_version, forKey: .ppcdf_version)
        try container.encodeIfPresent(longitude?.doubleValue, forKey: .longitude)//because longitude is of type KotlinDouble?
        try container.encodeIfPresent(latitude?.doubleValue, forKey: .latitude)
        try container.encodeIfPresent(altitude?.doubleValue, forKey: .altitude)
        try container.encodeIfPresent(gps_speed?.doubleValue, forKey: .gps_speed)
        try container.encodeIfPresent(bytes, forKey: .bytes)
    }
}

extension pcdfcore.PCDFPattern: Encodable{
    enum CodingKeys: String, CodingKey {
        case source
        case type
        case timestamp
        case data
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(source, forKey: .source)
        try container.encode(type, forKey: .type)
        try container.encode(timestamp, forKey: .timestamp)
        try container.encode(data, forKey: .data)
    }
}
