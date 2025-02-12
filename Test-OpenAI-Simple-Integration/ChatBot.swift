//
//  ChatModel.swift
//  Test-OpenAI-Simple-Integration
//
//  Created by Oleksandr Matrosov on 11/2/25.
//

import Foundation

final class ChatBot: ObservableObject {
    private let apiKey = "YOUR_OPEN_AI_API_KEY"
    private var chatHistory: [[String: String]] = [
        ["role": "system", "content": "You are an expert in development"]
    ]

    func send(text: String, completion: @escaping (Result<String, Error>) -> Void) {
        let url = URL(string: "https://api.openai.com/v1/chat/completions")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        chatHistory.append(["role": "user", "content": text])

        let parameters: [String: Any] = [
            "model": "gpt-4o-mini",
            "messages": chatHistory,
            "max_tokens": 500
        ]

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: [])
        } catch {
            completion(.failure(error))
            return
        }

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(NSError(domain: "ChatBot", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                return
            }

            do {
                let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                print("🔍 API Response: \(jsonResponse ?? [:])")

                if let choices = jsonResponse?["choices"] as? [[String: Any]],
                   let firstChoice = choices.first,
                   let message = firstChoice["message"] as? [String: Any],
                   let content = message["content"] as? String {

                    self.chatHistory.append(["role": "assistant", "content": content])

                    completion(.success(content))
                } else {
                    completion(.failure(NSError(domain: "ChatBot", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid response format"])))
                }
            } catch {
                completion(.failure(error))
            }
        }
        task.resume()
    }
}
