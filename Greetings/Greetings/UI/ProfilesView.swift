import SwiftUI

enum ProfileCommands{
    static let commands: [String] = [
        "ENGINE COOLANT TEMPERATURE",
        "RPM",
        "SPEED",
        "INTAKE AIR TEMPERATURE",
        "MAF AIR FLOW RATE",
        "MAF AIR FLOW RATE SENSOR",
        "OXYGEN SENSOR 1",
        "COMMANDED EGR",
        "FUEL TANK LEVEL INPUT",
        "CATALYST TEMPERATURE 1 1",
        "CATALYST TEMPERATURE 1 2",
        "CATALYST TEMPERATURE 2 1",
        "CATALYST TEMPERATURE 2 2",
        "FUEL AIR EQUIVALENCE RATIO",
        "AMBIENT AIR TEMPERATURE",
        "MAX VALUES",
        "MAXIMUM AIR FLOW RATE",
        "FUEL TYPE",
        "ENGINE OIL TEMPERATURE",
        "INTAKE AIR TEMPERATURE SENSOR",
        "NOX SENSOR",
        "NOX SENSOR CORRECTED",
        "NOX SENSOR ALTERNATIVE",
        "NOX SENSOR CORRECTED ALTERNATIVE",
        "PARTICULAR MATTER SENSOR",
        "ENGINE FUEL RATE",
        "ENGINE FUEL RATE MULTI",
        "ENGINE EXHAUST FLOW RATE",
        "EGR ERROR"
    ]
}

struct IndexedCollection<Base: RandomAccessCollection>: RandomAccessCollection {
    typealias Index = Base.Index
    typealias Element = (index: Index, element: Base.Element)

    let base: Base

    var startIndex: Index { base.startIndex }

    var endIndex: Index { base.endIndex }

    func index(after i: Index) -> Index {
        base.index(after: i)
    }

    func index(before i: Index) -> Index {
        base.index(before: i)
    }

    func index(_ i: Index, offsetBy distance: Int) -> Index {
        base.index(i, offsetBy: distance)
    }

    subscript(position: Index) -> Element {
        (index: position, element: base[position])
    }
}

extension RandomAccessCollection {
    func indexed() -> IndexedCollection<Self> {
        IndexedCollection(base: self)
    }
}

struct ProfilesView: View {
    let defaultProfile: Profile
    let allEnabledProfile: Profile
    var profiles: [Profile]
    var profilesNames: [String]
    @State var selectedProfileName: String = "all_supported"
    
    init(){
        defaultProfile = Profile("default_profile", enabled: ["RPM", "SPEED"])
        allEnabledProfile = Profile("all_supported", enabled: ProfileCommands.commands)
        
        profiles = [defaultProfile, allEnabledProfile]
        profilesNames = profiles.map{$0.name}
    }
    
    var body: some View {
        VStack{
            Section(header: Text("Select your tracking profile from the list below")){
                Picker(selection: $selectedProfileName, label: Text("monitoring profiles")){
                    ForEach (profilesNames, id: \.self) {
                        Text($0)
                    }
                }
                .pickerStyle(.wheel)
                .labelStyle(.titleOnly)
                Text("you selected \(selectedProfileName)")
            }
            
            Spacer()
            
            HStack(){
                NavigationLink(destination: EditProfileView(profile: defaultProfile), label: {
                    Text("New")
                        .font(.body)
                        .frame(maxWidth: .infinity)
                        .foregroundColor(.blue)
                })
                NavigationLink(destination: EditProfileView(profile: profiles.first(where: {$0.name == selectedProfileName}) ?? defaultProfile), label: {
                    Text("Edit")
                        .font(.body)
                        .frame(maxWidth: .infinity)
                        .foregroundColor(.blue)
                })
            }
            .padding()
        }
    }
}

struct EditProfileView: View{
    @ObservedObject var profile: Profile
    
    init(profile: Profile){
        self.profile = profile
    }
    
    var body: some View{
        ScrollView{
            VStack{
                HStack{
                    Text("Name: ")
                    TextField("Profile Name", text: $profile.name)
                }
                Text("Select the commands that you want to be tracked")
                    .foregroundColor(.gray)
                    .font(.caption)

                ForEach(profile.commandsDict.indexed(), id: \.1.id) { index, commandItem in
                    VStack{
                        Toggle(isOn: $profile.commandsDict[index].enabled){
                            Text(commandItem.name)
                        }
                        Spacer()
                    }
                }
            }
            .padding()
        }
    }
}

struct CommandItem: Identifiable, Codable, Equatable{
    let id = UUID()
    let name: String
    var enabled: Bool
}

class Profile: ObservableObject{
    @Published var name: String
    @Published var commandsDict: [CommandItem] = []
    var enabledCommands: [String]
    
    init(_ name: String, enabled: [String]){
        self.name = name
        self.enabledCommands = enabled
        for command in ProfileCommands.commands {
            self.commandsDict.append(CommandItem(name: command, enabled: enabledCommands.contains(command)))
        }
    }
}
