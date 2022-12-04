import SwiftUI
import pcdfcore

struct RdeLogView: View{
    @EnvironmentObject var model: Model
    @EnvironmentObject var obd: MyOBD
    
    var body: some View{
        RdeTabView(fileName: obd.getFileName())
            .toolbar{
//                ToolbarItem(placement: .navigationBarLeading){
//                    Button(action: {
//                        model.exitRDE()
//                    }) {
//                        HStack(spacing: 0) {
//                            Image(systemName: "chevron.backward")
//                                .aspectRatio(contentMode: .fill)
//                            Text("Configuration")
//                        }
//                    }
//                }
                ToolbarItem(placement: .navigationBarTrailing){
                    ConnectedDisconnectedView(connected: obd.isConnected())
                }
            }
//            .navigationBarBackButtonHidden(true)
            .onDisappear{
                model.exitRDE()
            }
    }
}
