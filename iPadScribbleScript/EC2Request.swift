//
//  EC2Request.swift
//  iPadScribbleScript
//
//  Created by Kelvin J on 1/11/25.
//

import UIKit

struct APIResponse: Codable {
    let status: String
    let message: String
}

class EC2ViewModel: ObservableObject {
    @Published var response: APIResponse?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    func imageProcess(base64String: String) {
        let address = "http://server.scribblescript.tech/process"
        guard let url = URL(string: address) else {
            errorMessage = "Invalid URL"
            return
        }
        
        print("url address is valid")

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.timeoutInterval = 30
        
        let parameters: [String: Any] = [
            "image": base64String
        ]

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: [])
        } catch {
            errorMessage = "Failed to encode parameters: \(error)"
            return
        }

        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        isLoading = true
        URLSession.shared.dataTask(with: request) { data, response, error in
            
            DispatchQueue.main.async {
                self.isLoading = false
            }

            if let error = error {
                DispatchQueue.main.async {
                    self.errorMessage = "Error: \(error)"
                    print(self.errorMessage)
                }
                return
            }

            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
                DispatchQueue.main.async {
                    self.errorMessage = "HTTP Status Code: \(httpResponse.statusCode)"
                    print(self.errorMessage)
                }
                return
            }

            if let data = data {
                do {
                    let collection = try JSONDecoder().decode(APIResponse.self, from: data)
                    DispatchQueue.main.async {
                        self.response = collection
                        print("Response!!! ", self.response)
                    }
                } catch {
                    DispatchQueue.main.async {
                        self.errorMessage = "Failed to decode JSON: \(error)"
                        print(self.errorMessage)
                    }
                }
            }
        }.resume()
    }
}

