import Foundation

//https://developer.apple.com/documentation/foundation/url_loading_system/uploading_data_to_a_website
class Uploader {
    var url: URL
    var request: URLRequest
    
    init() {
        self.url = URL(string: Bundle.main.infoDictionary?["DEST_URL"] as! String)!
        let apiToken = Bundle.main.infoDictionary?["SECRET_TOKEN"] as! String
        let appVersion = Bundle.main.infoDictionary?["APP_VERSION"] as! String
        let privacyPolicyVersion = Int(Bundle.main.infoDictionary?["PRIVACY_POLICY_VERSION"] as! String) ?? 0
        self.request = URLRequest(url: self.url)
        
        request.httpMethod = "POST"
        request.setValue("application/ppcdf", forHTTPHeaderField: "Content-Type")
        request.setValue(apiToken, forHTTPHeaderField: "x-api-token")
        request.setValue(appVersion, forHTTPHeaderField: "x-app-version")
        request.setValue("\(privacyPolicyVersion)", forHTTPHeaderField: "x-privacy-policy")
    }
    
    func uploadAll() {
        DispatchQueue.main.async {
            do {
                let notUploaded = try EventStore.fileURL(fileName: "NotUploaded")
                let notUploadedExists = FileManager.default.fileExists(atPath: notUploaded.path)
                if notUploadedExists {
                    let fileRead = try? FileHandle(forReadingFrom: notUploaded)
                    guard let dataRead = try fileRead?.readToEnd() else {
                        return
                    }
                    let contentStr = String(decoding: dataRead, as: UTF8.self)
                    try fileRead?.close()
                    let fileNames = contentStr.components(separatedBy: "\n").filter{ !$0.isEmpty }
                    for fileName in fileNames {
                        let file = try EventStore.fileURL(fileName: fileName)
                        let fileExists = FileManager.default.fileExists(atPath: file.path)
                        if fileExists {
                            self.upload(file: file)//Escaping closure captures mutating 'self' parameter, solution: change from struct to class
                        }
                    }
                }
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    func upload(file: URL) {
        request.setValue(file.deletingPathExtension().lastPathComponent, forHTTPHeaderField: "x-donation-file-name")
        let task = URLSession.shared.uploadTask(with: self.request, fromFile: file) { data, response, error in
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
        }
        task.resume()
        print("\(file.path) should be uploaded")
    }
}
