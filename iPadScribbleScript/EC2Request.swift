//
//  EC2Request.swift
//  iPadScribbleScript
//
//  Created by Kelvin J on 1/11/25.
//

import UIKit
import SwiftAnthropic

struct APIResponse: Decodable {
    let res: String

    enum CodingKeys: String, CodingKey {
        case res = "result" // Map "result" key in JSON to "res" property
    }
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
            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                self.codeResult = "#include <iostream> \n using namespace std;\n int main() { \n cout << \"Hello World\" << endl;\n return 0\n }\n"
            }
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
                    if let jsonString = String(data: data, encoding: .utf8) {
                        print("Raw JSON Response: \(jsonString)")
                    }
                    
                    let response = try JSONDecoder().decode(APIResponse.self, from: data)
                    
                    DispatchQueue.main.async {
                        self.codeResult = response.res // Extract the result
                    }
                    print("Decoded Result: \(response.res)")
                    
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
//                    let response = try JSONDecoder().decode(APIResponse.self, from: data)
//                    print("145", response.res)
                    
//                    DispatchQueue.main.async {
//                        self.compileResult = response.res
//                    }
                    
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
    
    func callAnthropic() async {
//        if let apiKey = Bundle.main.object(forInfoDictionaryKey: "ANTHROPIC_KEY") as? String {
//            print("API Key: \(apiKey)")
//        }
        if let path = Bundle.main.path(forResource: "Keys", ofType: "plist"),
           let keys = NSDictionary(contentsOfFile: path),
           let apiKey = keys["ANTHROPIC_KEY"] as? String {
            
            let service = AnthropicServiceFactory.service(apiKey: apiKey, betaHeaders: [])
            let claudeModel: Model = .claude35Sonnet
            let maxTokensToSample = 1024
            let messageParameter = MessageParameter.Message(role: MessageParameter.Message.Role(rawValue: "user")!, content: MessageParameter.Message.Content.text("Hello Claude"))
            let parameters = MessageParameter(model: claudeModel, messages: [messageParameter], maxTokens: maxTokensToSample)
            
            do {
                let messageRequest = try await service.streamMessage(parameters)
                var messageTextResponse = ""
                for try await result in messageRequest {
                    // Safely unwrap delta?.text and accumulate it
                    if let content = result.delta?.text {
                        messageTextResponse += content
                        print("chunked output: \(messageTextResponse)")
                    }
                }
                print("The final output is \(messageTextResponse)")
            } catch {
                print("Cannot create message")
            }
        }
    }
}

