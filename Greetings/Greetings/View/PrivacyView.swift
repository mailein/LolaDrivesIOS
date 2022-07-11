import SwiftUI

struct PrivacyView: View {
    @EnvironmentObject var viewModel: ViewModel
    var uploader = Uploader()
    let url = Bundle.main.url(forResource: "privacy", withExtension: "html")
    
    var body: some View {
        UrlWebView(url: url!)
            .navigationTitle("Privacy")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar{
                ToolbarItem(placement: .bottomBar){
                    Toggle(isOn: $viewModel.model.dataDonationEnabled){
                        Text("Enable data donations:")
                    }
                    .toggleStyle(.switch)
                    .onChange(of: viewModel.model.dataDonationEnabled) {enabled in
                        if enabled {
                            let privacyPolicyVersion = Int(Bundle.main.infoDictionary?["PRIVACY_POLICY_VERSION"] as! String) ?? 0
                            UserDefaults.standard.set(privacyPolicyVersion, forKey: "PrivacyPolicyVersionAllowed")
                            uploader.uploadAll()
                        }
                    }
                }
            }
            .onAppear{
                let privacyPolicyVersion = Int(Bundle.main.infoDictionary?["PRIVACY_POLICY_VERSION"] as! String) ?? 0
                let privacyPolicyVersionAllowed = UserDefaults.standard.integer(forKey: "PrivacyPolicyVersionAllowed")
                viewModel.model.dataDonationEnabled = privacyPolicyVersionAllowed >= privacyPolicyVersion
            }
    }
}

struct PrivacyView_Previews: PreviewProvider {
    static var previews: some View {
        PrivacyView()
    }
}
