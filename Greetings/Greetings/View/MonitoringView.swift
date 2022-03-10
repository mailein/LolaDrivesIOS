import SwiftUI
//import LTSupportAutomotive

struct MonitoringView: View {
    @EnvironmentObject var viewModel: ViewModel
    
    var body: some View {
        let selectedProfile = viewModel.getSelectedProfile()
        List(selectedProfile.commands.filter({$0.enabled}), id: \.self) { command in
            HStack{
                Text(command.name)
                Spacer()
                VStack(alignment: .trailing){
                    Text("value_palceholder")
                    Text(command.unit)
                        .italic()
                        .fontWeight(.ultraLight)
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct MonitoringView_Previews: PreviewProvider {
    static var previews: some View {
        MonitoringView()
    }
}
