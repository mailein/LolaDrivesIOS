import SwiftUI

struct HistoryDetailView: View {
    var file: URL
    var body: some View {
        TabView{
            EventLogTabView(file: file)
                .tabItem{
                    Text("Event log")
                }
            RdeProfileTabView()
                .tabItem{
                    Text("RDE profile")
                }
        }
        .navigationTitle(file.deletingPathExtension().lastPathComponent)
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

