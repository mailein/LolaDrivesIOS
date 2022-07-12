import SwiftUI

struct ContentView: View {
    @StateObject var viewModel = ViewModel()
    @StateObject var obd = MyOBD()
    let initialScreenDisplayed = UserDefaults.standard.bool(forKey: "initialScreenDisplayed")
    
    var body: some View {
        NavigationView{
            if initialScreenDisplayed{
                MenuView()
            }else {
                InitialDisclaimerView()
            }
        }
        .environmentObject(viewModel)
        .environmentObject(obd)
    }
}
