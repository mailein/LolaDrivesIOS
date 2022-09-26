import SwiftUI

struct ProfilesView: View {
    @EnvironmentObject var model: Model
    @EnvironmentObject var obd: MyOBD
//    @Binding var profiles: [Profile]//model
    @State private var unableToSelect = false
    
    var body: some View {
        List {
            ForEach($model.profiles) { $profile in
                NavigationLink(destination: ProfileEditView(profile: $profile)){
                    Text(profile.name)
                    if profile.isSelected{
                        Text("(selected)")
                    }
                }
                .disabled(obd.isLiveMonitoringOngoing())//viewModel.isStartLiveMonitoring() doesn't change here, because viewmodel doesn't publish the property change, model does.
                .swipeActions(edge: .trailing, allowsFullSwipe: false){
                    Button(role: .destructive){
                        if model.startLiveMonitoring {
                            unableToSelect = false
                            model.deleteProfile(profile)
                        }else{
                            unableToSelect = true
                        }
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
                .swipeActions(edge: .leading, allowsFullSwipe: false){
                    Button{
                        if model.startLiveMonitoring {
                            unableToSelect = false
                            model.setSelectedProfile(to: profile)
                        }else{
                            unableToSelect = true
                        }
                    } label: {
                        //UI changes
                        if profile.isSelected {
                            Label("Deselect", systemImage: "pin.slash")
                        }else{
                            Label("Select", systemImage: "pin")
                        }
                    }
                }
            }
            .onDelete(perform: delete)//unable to check isStartLiveMonitoring here
            .onMove(perform: reorder)
            .alert("Unable to select / delete during live monitoring", isPresented: $unableToSelect) { Button("OK", role: .cancel, action: {})
            }
        }
        .onAppear{
            model.getSelectedProfile()
        }
        .toolbar{
            ToolbarItem(placement: .bottomBar){
                NewButton()
            }
            ToolbarItem(placement: .bottomBar){
                EditButton()
            }
        }
//        .buttonStyle(.borderedProminent)
        .navigationTitle("Profiles")
    }
    func NewButton()-> Button<Text> {
        Button("New"){
            let commands = ProfileCommands.commands
            model.addProfile(Profile("new profile", commands: commands))
        }
    }
    func delete(at offsets: IndexSet) {
        model.profiles.remove(atOffsets: offsets)
        if !model.profiles.isEmpty {
            let selected = model.getSelectedProfile()
            let index = model.profiles.firstIndex(of: selected!)
            if offsets.contains(index!) {
                model.setSelectedProfile(to: model.profiles[0])
            }
        }
    }
    func reorder(from source: IndexSet, to destination: Int){
        model.profiles.move(fromOffsets: source, toOffset: destination)
    }
    func indexOf(profile: Profile) -> Int {
        for index in 0..<model.profiles.count{//don't use ForEach(0..<viewModel.model.profiles.count, \.self){index in ...}
            if profile.id == model.profiles[index].id {
                return index
            }
        }
        return 0
    }
}

//MARK: -
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

//MARK: -

//struct ProfilesView_Previews: PreviewProvider {
//    static var previews: some View {
//        ProfilesView()
//    }
//}
