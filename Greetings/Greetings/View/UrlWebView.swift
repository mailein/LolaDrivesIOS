import SwiftUI
import WebKit

struct UrlWebView: UIViewRepresentable {
    typealias UIViewType = WKWebView
    
    let url: URL
    let urlString: String?
    
    init(url: URL) {
        self.url = url
        self.urlString = try? String(contentsOf: url, encoding: String.Encoding.utf8)
    }
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        
        webView.loadHTMLString(urlString!, baseURL: url)
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        
    }
}
