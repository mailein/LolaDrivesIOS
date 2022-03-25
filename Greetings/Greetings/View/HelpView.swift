import SwiftUI

struct HelpView: View{
    let url = Bundle.main.url(forResource: "help", withExtension: "html")
    
    var body: some View{
        UrlWebView(urlToDisplay: url!)
    }
}

struct HelpView_Previews: PreviewProvider {
    static var previews: some View {
        HelpView()
    }
}
