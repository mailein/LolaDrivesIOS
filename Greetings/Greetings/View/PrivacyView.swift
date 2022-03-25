import SwiftUI

struct PrivacyView: View {
    let url = URL(string: "https://www.loladrives.app/privacy/")
    
    var body: some View {
        UrlWebView(urlToDisplay: url!)
    }
}

struct PrivacyView_Previews: PreviewProvider {
    static var previews: some View {
        PrivacyView()
    }
}
