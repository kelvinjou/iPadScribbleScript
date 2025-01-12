//
//  EC2Request.swift
//  iPadScribbleScript
//
//  Created by Kelvin J on 1/11/25.
//

import UIKit

struct APIResponse: Codable {
    let res: String
    
}

class EC2ViewModel: ObservableObject {
//    @Published var imgResponse: APIResponse?
    @Published var isLoading = false
    @Published var processingImgError: String?
    
    @Published var codeResult: String?
    @Published var compileResult: String?
    
    func imageProcess(base64String: String) {
        let address = "https://server.scribblescript.tech/process"
        
        // STUB
        DispatchQueue.main.async {
            self.codeResult = "#include <iostream> \nint main() { \n cout << \"Hello World\" << endl;\n return 0\n }\n"
            return;
        }

        
        guard let url = URL(string: address) else {
            processingImgError = "Invalid URL"
            return
        }
        
        print("url address is valid")

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
//        request.timeoutInterval = 30
        
        let parameters: [String: Any] = [
            "image": base64String
        ]

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: [])
            
            // for no parameters
//            request.httpBody = nil
        } catch {
            processingImgError = "Failed to encode parameters: \(error)"
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
                    self.processingImgError = "Error: \(error)"
                    print(self.processingImgError)
                }
                return
            }

            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
                DispatchQueue.main.async {
                    self.processingImgError = "HTTP Status Code: \(httpResponse.statusCode)"
                    print(self.processingImgError)
                }
                return
            }

            if let data = data {
                do {
                    // Decode the JSON data using Codable
                    let response = try JSONDecoder().decode(APIResponse.self, from: data)
                    
                    print("78", response.res)
                    // Update the @Published variable
                    DispatchQueue.main.async {
                        self.codeResult = response.res
                    }
                    
                    print("Code Result: \(self.codeResult ?? "No result")")
                } catch {
                    DispatchQueue.main.async {
                        self.processingImgError = "Failed to decode JSON: \(error.localizedDescription)"
                    }
                    print("Failed to decode JSON: \(error)")
                }
            }
        }.resume()
    }
    
    @Published var compilingError: String?
    
    func compile(code: String, language: String) {
        let address = "https://server.scribblescript.tech/compile"
        guard let url = URL(string: address) else {
            compilingError = "Invalid URL"
            return
        }
        print("url address is valid")
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        let parameters: [String: Any] = [
            "code": code,
            "language": language
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: [])
        } catch {
            compilingError = "Failed to encode parameters: \(error)"
            return
        }
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    self.compilingError = "Error: \(error)"
                    print(self.compilingError as Any)
                }
                return
            }
            if let httpResponse = response as? HTTPURLResponse,
               httpResponse.statusCode != 200 {
                DispatchQueue.main.async {
                    self.compilingError = "HTTP Status Code: \(httpResponse.statusCode)"
                }
            }
            
            if let data = data {
                do {
                    let response = try JSONDecoder().decode(APIResponse.self, from: data)
                    print("145", response.res)
                    
                    DispatchQueue.main.async {
                        self.compileResult = response.res
                    }
                    
                    print("compilation response: \(self.compileResult ?? "No compilation res")")
                } catch {
                    DispatchQueue.main.async {
                        self.compilingError = "Failed to compile: \(error.localizedDescription)"
                    }
                    print("Failed to decode JSON: \(error)")
                }
            }
        }.resume()
    }
}

