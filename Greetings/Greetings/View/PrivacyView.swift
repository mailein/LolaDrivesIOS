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
                            print("enabled -> upload")
                            uploader.uploadAll()
                        }
                    }
                }
            }
    }
}

struct PrivacyView_Previews: PreviewProvider {
    static var previews: some View {
        PrivacyView()
    }
}
