import Foundation

//https://developer.apple.com/documentation/foundation/url_loading_system/uploading_data_to_a_website
struct Uploader {
//    let file: URL
    var url: URL
    var request: URLRequest
    
    init() {
//        self.file = file
        let dict = Bundle.main.infoDictionary
        self.url = URL(string: Bundle.main.infoDictionary?["DEST_URL"] as! String)!
        let apiToken = Bundle.main.infoDictionary?["SECRET_TOKEN"] as! String
        let appVersion = Bundle.main.infoDictionary?["APP_VERSION"] as! String
        let privacyPolicyVersion = Int(Bundle.main.infoDictionary?["PRIVACY_POLICY_VERSION"] as! String) ?? 0
        self.request = URLRequest(url: self.url)
        
        request.httpMethod = "POST"
        request.setValue("application/ppcdf", forHTTPHeaderField: "Content-Type")
        request.setValue(apiToken, forHTTPHeaderField: "x-api-token")
        request.setValue(appVersion, forHTTPHeaderField: "x-app-version")
//        request.setValue(file.deletingPathExtension().lastPathComponent, forHTTPHeaderField: "x-donation-file-name")
        request.setValue("\(privacyPolicyVersion)", forHTTPHeaderField: "x-privacy-policy")
    }
    
//    func upload() {
//        let task = URLSession.shared.uploadTask(with: self.request, fromFile: self.file) { data, response, error in
//            if let error = error {
//                print("error: \(error)")
//                return
//            }
//            guard let response = response as? HTTPURLResponse,
//                  (200...299).contains(response.statusCode) else {
//                print("server error")
//                return
//            }
//            if let mimeType = response.mimeType{
//                print("response mime type: \(mimeType)")
//            }
//        }
//        task.resume()
//    }
}
