import Foundation

//https://developer.apple.com/documentation/foundation/url_loading_system/uploading_data_to_a_website
struct Uploader {
    let file: URL
    var url: URL
    var request: URLRequest
    var privacyPolicyVersion: Int
    
    let destDebug = "https://api.loladrives.app/debug/donations"
    let destRelease = "https://api.loladrives.app/deploy/donations"
    
    init(file: URL, isReleaseVersion: Bool = false, debugToken: String, releaseToken: String, appVersion: String, privacyPolicyVersion: Int) {
        self.file = file
        self.url = isReleaseVersion ? URL(string: destRelease)! : URL(string: destDebug)!
        let apiToken = isReleaseVersion ? releaseToken : debugToken
        self.request = URLRequest(url: self.url)
        self.privacyPolicyVersion = privacyPolicyVersion
        
        request.httpMethod = "POST"
        request.setValue("application/ppcdf", forHTTPHeaderField: "Content-Type")
        request.setValue(apiToken, forHTTPHeaderField: "x-api-token")
        request.setValue(appVersion, forHTTPHeaderField: "x-app-version")
        request.setValue(file.deletingPathExtension().lastPathComponent, forHTTPHeaderField: "x-donation-file-name")
        request.setValue("\(privacyPolicyVersion)", forHTTPHeaderField: "x-privacy-policy")
    }
    
    func upload() {
        let task = URLSession.shared.uploadTask(with: self.request, fromFile: self.file) { data, response, error in
            if let error = error {
                print("error: \(error)")
                return
            }
            guard let response = response as? HTTPURLResponse,
                  (200...299).contains(response.statusCode) else {
                print("server error")
                return
            }
            if let mimeType = response.mimeType{
                print("response mime type: \(mimeType)")
            }
        }
        task.resume()
    }
}
