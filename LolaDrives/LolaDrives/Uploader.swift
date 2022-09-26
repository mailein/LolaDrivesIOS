import Foundation

//https://developer.apple.com/documentation/foundation/url_loading_system/uploading_data_to_a_website
struct Uploader {
    func uploadAll() {
        DispatchQueue.main.async {
            let url = URL(string: Bundle.main.infoDictionary?["DEST_URL"] as! String)!
            let apiToken = Bundle.main.infoDictionary?["SECRET_TOKEN"] as! String
            let appVersion = Bundle.main.infoDictionary?["APP_VERSION"] as! String
            let privacyPolicyVersion = Int(Bundle.main.infoDictionary?["PRIVACY_POLICY_VERSION"] as! String) ?? 0
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/ppcdf", forHTTPHeaderField: "Content-Type")
            request.setValue(apiToken, forHTTPHeaderField: "x-api-token")
            request.setValue(appVersion, forHTTPHeaderField: "x-app-version")
            request.setValue("\(privacyPolicyVersion)", forHTTPHeaderField: "x-privacy-policy")
            
            let notUploadedkey = "NotUploaded"
            let notUploaded: [String] = UserDefaults.standard.array(forKey: notUploadedkey) as? [String] ?? []
            do {
                for fileName in notUploaded {
                    let file = try EventStore.fileURL(fileName: fileName)
                    let fileExists = FileManager.default.fileExists(atPath: file.path)
                    if fileExists {
                        self.upload(file: file, request: &request)//Escaping closure captures mutating 'self' parameter, solution: change from struct to class
                    }
                }
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    func upload(file: URL, request: inout URLRequest) {
        request.setValue(file.deletingPathExtension().lastPathComponent, forHTTPHeaderField: "x-donation-file-name")
        let task = URLSession.shared.uploadTask(with: request, fromFile: file) { data, response, error in
            if let error = error {
                print("error: \(error)")
                return
            }
            guard let response = response as? HTTPURLResponse,
                  (200...299).contains(response.statusCode) else {
                print("\(response) server error")
                return
            }
            if let mimeType = response.mimeType{
                print("response mime type: \(mimeType)")
            }
            EventStore.removeFromNotUploaded(fileName: file.lastPathComponent)
        }
        task.resume()
        print("\(file.path) should be uploaded")
    }
}
