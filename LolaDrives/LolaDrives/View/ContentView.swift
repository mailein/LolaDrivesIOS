import SwiftUI

struct ContentView: View {
    @StateObject var model = Model()
    @StateObject var obd = MyOBD()
    
    @State private var isDisclaimerPresenting = true
    @State private var isPrivacyPresenting = false
    
    var body: some View {
        NavigationView{
            MenuView()
                .fullScreenCover(isPresented: $isDisclaimerPresenting) {
                    InitialDisclaimerView(isDisclaimerPresenting: $isDisclaimerPresenting, isPrivacyPresenting: $isPrivacyPresenting)
                }
        }
        .environmentObject(model)
        .environmentObject(obd)
        .onAppear{
            isDisclaimerPresenting = !UserDefaults.standard.bool(forKey: "initialScreenDisplayed")
        }
    }
}
