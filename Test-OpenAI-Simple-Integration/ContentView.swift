//
//  ContentView.swift
//  Test-OpenAI-Simple-Integration
//
//  Created by Oleksandr Matrosov on 11/2/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject var chatBotObject = ChatBot()
    @State var text = ""
    @State var messages = [String]()

    var body: some View {
        VStack(alignment: .leading) {
            ScrollView {
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(messages, id: \.self) { string in
                        Text(string)
                            .padding()
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(10)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .padding()
            }

            Spacer()

            HStack {
                TextField("Ask anything...", text: $text)
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 10).stroke(Color.gray))
                
                Button("Send") {
                    send()
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            .padding()
        }
    }

    func send() {
        guard !text.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        let textToSend = self.text
        self.text = ""
        
        DispatchQueue.main.async {
            self.messages.append("Me: \(textToSend)")
        }

        chatBotObject.send(text: textToSend) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    self.messages.append("ChatGPT: \(response)")
                case .failure(let error):
                    self.messages.append("Error: \(error.localizedDescription)")
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
