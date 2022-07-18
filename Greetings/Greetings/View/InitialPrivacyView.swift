import SwiftUI

struct InitialPrivacyView: View {
    @Binding var isDisclaimerPresenting: Bool
    @Binding var isPrivacyPresenting: Bool
    
    /*
     Q: How to use navLink together with an action?
     A: Use EmptyView and isActive binding inside navLink, then set the binding to true in button action
     */
    var body: some View {
        VStack{
            BaseWebView(title: "privacy")
            HStack{
                Button(action: {
                    notAllowed()
                }, label: {
                    Text("NO")
                })
                Spacer()
                Button(action: {
                    allowed()
                }, label: {
                    Text("ENABLE DATA DONATIONS")
                })
            }
            .padding()
            .background(Color.black)
            .foregroundColor(.white)
        }
        .navigationBarBackButtonHidden(true)
        .onDisappear {
            UserDefaults.standard.set(true, forKey: "initialScreenDisplayed")
        }
    }
    
    func notAllowed() {
        UserDefaults.standard.set(0, forKey: "PrivacyPolicyVersionAllowed")
        isDisclaimerPresenting = false
        isPrivacyPresenting = false
    }
    
    func allowed() {
        let privacyPolicyVersion = Int(Bundle.main.infoDictionary?["PRIVACY_POLICY_VERSION"] as! String) ?? 0
        UserDefaults.standard.set(privacyPolicyVersion, forKey: "PrivacyPolicyVersionAllowed")
        isDisclaimerPresenting = false
        isPrivacyPresenting = false
    }
}
