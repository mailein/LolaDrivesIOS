import SwiftUI

struct HistoryView: View {
    let directory: URL
    var files: [URL]
    var latestFile: URL? = nil
    
    init(){
        directory = URL(fileURLWithPath: "/")//TODO: use core data?
        do {
            files = try FileManager.default.contentsOfDirectory(at: directory, includingPropertiesForKeys: nil)
        }catch{
            files = []
            print(error)
        }
        //TODO: get the latest file
        if !files.isEmpty {
            latestFile = files[0]
        }
    }
    
    var body: some View {
        TabView{
            EventLogTabView(file: latestFile)
                .tabItem{
                    Text("Event log")
                }
            RdeProfileTabView()
                .tabItem{
                    Text("RDE profile")
                }
        }
    }
}

struct EventLogTabView: View{
    var file: URL?
    var content: String = ""
    var myStrings: [String] = []
    
    init(file: URL?){
        self.file = file
        if file != nil {
            do {
                content = try String(contentsOfFile: file!.path)
                myStrings = content.components(separatedBy: .newlines)
            } catch {
                print(error)
            }
        }
    }
    
    var body: some View{
        if file == nil {
            Text("Event log")
        }else{
            List{
                ForEach(myStrings.indices, id: \.self){ index in
                    Text(myStrings[index])
                }
            }
        }
    }
}

extension String: Identifiable {
    public typealias ID = Int
    public var id: Int {
        return hash
    }
}

struct RdeProfileTabView: View{
    var body: some View{
        Text("Speed profile")
    }
}

struct HistoryView_Previews: PreviewProvider {
    static var previews: some View {
        HistoryView()
    }
}
