import SwiftUI

struct PrivacyView: View {
    @EnvironmentObject var viewModel: ViewModel
    let url = Bundle.main.url(forResource: "privacy", withExtension: "html")
    
    var body: some View {
        UrlWebView(url: url!)
            .navigationTitle("Privacy")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar{
                ToolbarItem(placement: .bottomBar){
                    HStack{
                        Text("Enable data donations:")
                        Spacer()
                        Toggle(isOn: $viewModel.model.dataDonationEnabled){
                            if viewModel.model.dataDonationEnabled {
                                Image(systemName: "icloud.and.arrow.up")
                            }else{
                                Image(systemName: "exclamationmark.icloud")
                            }
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
