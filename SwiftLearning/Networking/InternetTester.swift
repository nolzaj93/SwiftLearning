import Foundation

final class InternetTester {
    
    static func verifyInternetConnection(timeout: TimeInterval = 1, completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: "https://www.apple.com/library/test/success.html") else {
            completion(false)
            return
        }
        
        var request = URLRequest(url: url)
        request.timeoutInterval = timeout
        
        URLSession.shared.dataTask(with: request) { _, response, _ in
            DispatchQueue.main.async {
                if let response = response as? HTTPURLResponse, response.statusCode == 200 {
                    print("200")
                    completion(true)
                } else {
                    completion(false)
                }
            }
        }.resume()
    }
    
    //modernized function with async/await
    
    static func verifyInternetConnection(timeout: TimeInterval = 1) async -> Bool {
        guard let url = URL(string: "https://www.apple.com/library/test/success.html") else {
            return false
        }

        var request = URLRequest(url: url)
        request.timeoutInterval = timeout

        do {
            let (_, response) = try await URLSession.shared.data(for: request)
            if let httpResponse = response as? HTTPURLResponse {
                return httpResponse.statusCode == 200
            }
        } catch {
            return false
        }

        return false
    }


}
