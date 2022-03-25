import SwiftUI

struct PrivacyView: View {
    let url = Bundle.main.url(forResource: "privacy", withExtension: "html")
    
    var body: some View {
        UrlWebView(url: url!)
            .navigationTitle("Privacy")
            .navigationBarTitleDisplayMode(.inline)
    }
}

struct PrivacyView_Previews: PreviewProvider {
    static var previews: some View {
        PrivacyView()
    }
}
