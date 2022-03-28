import SwiftUI

struct BaseWebView: View{
    var title: String
    
    let url: URL?
    
    init(title: String){
        self.title = title
        self.url = Bundle.main.url(forResource: title.lowercased(), withExtension: "html")
    }
    
    var body: some View{
        UrlWebView(url: url!)
            .navigationTitle(title.capitalizingFirstLetter())
            .navigationBarTitleDisplayMode(.inline)
    }
}

extension String {
    func capitalizingFirstLetter() -> String {
        return prefix(1).capitalized + dropFirst()
    }

    mutating func capitalizeFirstLetter() {
        self = self.capitalizingFirstLetter()
    }
}
