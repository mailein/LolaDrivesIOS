import SwiftUI

struct InitialPrivacyView: View {
    @State private var display = false
    
    /*
     Q: How to use navLink together with an action?
     A: Use EmptyView and isActive binding inside navLink, then set the binding to true in button action
     */
    var body: some View {
        VStack{
            BaseWebView(title: "privacy")
            NavigationLink(destination: MenuView(), isActive: $display) { EmptyView() }
            HStack{
                Button(action: {
                    UserDefaults.standard.set(0, forKey: "PrivacyPolicyVersionAllowed")
                    display = true
                }, label: {
                    Text("NO")
                })
                Spacer()
                Button(action: {
                    let privacyPolicyVersion = Int(Bundle.main.infoDictionary?["PRIVACY_POLICY_VERSION"] as! String) ?? 0
                    UserDefaults.standard.set(privacyPolicyVersion, forKey: "PrivacyPolicyVersionAllowed")
                    display = true
                }, label: {
                    Text("ENABLE DATA DONATIONS")
                })
            }
            .padding()
            .background(Color.black)
            .foregroundColor(.white)
        }
        .navigationBarBackButtonHidden(true)
    }
}
