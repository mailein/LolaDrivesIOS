import SwiftUI

struct ContentView: View {
    @StateObject var viewModel = ViewModel()
    @StateObject var obd = MyOBD()
    
    var body: some View {
        NavigationView{
            InitialDisclaimerView()
        }
        .environmentObject(viewModel)
        .environmentObject(obd)
    }
}
