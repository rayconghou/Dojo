//
//  ManekiView.swift
//  Dojo
//
//  Created by Raymond Hou on 3/11/25.
//

import Foundation
import SwiftUI

struct ManekiView: View {
    var hamburgerAction: () -> Void
    @State private var userMessage = ""
    @State private var messages: [ManekiChatMessage] = [
        ManekiChatMessage(id: 1, content: "Hi there! I'm **Maneki**, your crypto guide. How can I help you today?", isFromUser: false)
    ]
    @State private var isLoading = false
    @State private var searchText = ""

    private let exampleQuestions = [
        "How do I start trading crypto?",
        "What's the safest exchange?",
        "Is now a good time to buy BTC?",
        "Can you explain NFTs?",
        "What are good long-term coins?"
    ]

    @Namespace private var scrollAnchor

    var body: some View {
        ZStack(alignment: .top) {
            VStack(spacing: 0) {
                // TopBar with profile, search, notifications, and hamburger menu
                TopBar(
                    searchText: $searchText,
                    onHamburgerTap: hamburgerAction,
                    onNotificationTap: {
                        // TODO: Implement notification action
                        print("Notification tapped")
                    },
                    onProfileTap: {
                        // TODO: Implement profile action
                        print("Profile tapped")
                    }
                )
                
                VStack {
                ScrollViewReader { scrollProxy in
                    ScrollView {
                        LazyVStack(spacing: 15) {
                            ForEach(messages) { message in
                                if message.isFromUser {
                                    ManekiChatBubble(message: message)
                                } else {
                                    ManekiResponseView(content: message.content)
                                }
                            }

                            if isLoading {
                                HStack {
                                    Text("...")
                                        .font(.custom("Satoshi-Bold", size: 24))
                                        .foregroundColor(.white)
                                        .padding()
                                        .background(Color(hex: "1F212F"))
                                        .cornerRadius(18)
                                        .frame(maxWidth: 280, alignment: .leading)
                                    Spacer()
                                }
                            }

                            Color.clear
                                .frame(height: 1)
                                .id(scrollAnchor)
                        }
                        .padding()
                        .onChange(of: messages.count) { _ in
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                withAnimation {
                                    scrollProxy.scrollTo(scrollAnchor, anchor: .bottom)
                                }
                            }
                        }
                    }
                    .padding(.vertical, 6)
                    .background(Color(hex: "050715"))
                    .cornerRadius(16)
                    .padding(.horizontal, 10)
                }

                // Compact rectangular container matching design specs
                VStack(spacing: 8) {
                    // Suggested Questions Row with horizontal scrolling
                    ZStack(alignment: .trailing) {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(exampleQuestions, id: \.self) { question in
                                    Button(action: {
                                        userMessage = question
                                    }) {
                                        Text(question)
                                            .font(.custom("Satoshi-Medium", size: 14))
                                            .foregroundColor(.white)
                                            .padding(.horizontal, 16)
                                            .padding(.vertical, 8)
                                            .background(Color(hex: "282A45"))
                                            .cornerRadius(20)
                                    }
                                }
                            }
                            .padding(.horizontal, 4)
                        }
                        
                        // Shadow indicator on the right
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.clear,
                                Color(hex: "141628").opacity(0.8)
                            ]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                        .frame(width: 20)
                        .allowsHitTesting(false)
                    }
                    
                    // Input Field and Action Buttons Row
                    HStack(spacing: 12) {
                        TextField("Ask Maneki anything...", text: $userMessage)
                            .font(.custom("Satoshi-Regular", size: 16))
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(Color(hex: "282A45"))
                            .cornerRadius(25)
                            .foregroundColor(.white)
                        
                        Button(action: sendMessage) {
                            Image(systemName: "arrow.up")
                                .foregroundColor(.black)
                                .font(.custom("Satoshi-Bold", size: 16))
                                .frame(width: 40, height: 40)
                                .background(Color.white)
                                .cornerRadius(12)
                        }
                        .disabled(userMessage.isEmpty)
                        
                        Button(action: {
                            userMessage = ""
                        }) {
                            Image(systemName: "repeat")
                                .foregroundColor(.white)
                                .font(.custom("Satoshi-Medium", size: 16))
                                .frame(width: 40, height: 40)
                                .background(Color(hex: "282A45"))
                                .cornerRadius(12)
                        }
                    }
                }
                .padding(.horizontal, 15)
                .padding(.vertical, 10)
                .background(Color(hex: "141628"))
                .cornerRadius(20)
                .padding(.horizontal, 16)
                .padding(.bottom, 8)
                }
            }
            .background(Color(hex: "050715"))
        }
    }

    func sendMessage() {
        guard !userMessage.isEmpty else { return }
        isLoading = true

        let userMsg = ManekiChatMessage(id: messages.count + 1, content: userMessage, isFromUser: true)
        messages.append(userMsg)
        userMessage = ""

        let userMessageCount = messages.filter { $0.isFromUser }.count
        var history: [String]

        if userMessageCount == 1 {
            history = [userMsg.content]
        } else {
            let prunedMessages = messages.drop(while: { !$0.isFromUser })
            var cleaned: [String] = []
            var lastSenderWasUser: Bool? = nil

            for msg in prunedMessages {
                if lastSenderWasUser == nil || msg.isFromUser != lastSenderWasUser {
                    cleaned.append(msg.content)
                    lastSenderWasUser = msg.isFromUser
                }
            }

            if lastSenderWasUser == false {
                cleaned.removeLast()
            }

            if cleaned.count % 2 == 0 {
                cleaned.removeLast()
            }

            history = cleaned
        }

        guard let url = URL(string: "http://localhost:3001/api/maneki-chat") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: ["messages": history])

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                isLoading = false
            }

            if let error = error {
                DispatchQueue.main.async {
                    let errorMsg = ManekiChatMessage(id: messages.count + 1, content: "⚠️ Network error: \(error.localizedDescription)", isFromUser: false)
                    messages.append(errorMsg)
                }
                return
            }

            guard let data = data else { return }

            if let raw = String(data: data, encoding: .utf8) {
                print("🧾 Raw response from API:", raw)
            }

            if let result = try? JSONDecoder().decode(ChatResponse.self, from: data) {
                DispatchQueue.main.async {
                    let clean = result.response
                        .replacingOccurrences(of: "\\n", with: "\n")
                        .replacingOccurrences(of: "\\\"", with: "\"")
                        .trimmingCharacters(in: CharacterSet(charactersIn: "\""))

                    let aiMessage = ManekiChatMessage(id: messages.count + 1, content: clean, isFromUser: false)
                    withAnimation(.easeInOut(duration: 0.3)) {
                        messages.append(aiMessage)
                    }
                }
            } else if let errorDict = try? JSONDecoder().decode([String: String].self, from: data),
                      let errorMessage = errorDict["error"] {
                DispatchQueue.main.async {
                    let errorMsg = ManekiChatMessage(id: messages.count + 1, content: "⚠️ \(errorMessage)", isFromUser: false)
                    withAnimation(.easeInOut(duration: 0.3)) {
                        messages.append(errorMsg)
                    }
                }
            }
        }.resume()
    }
}

struct ChatResponse: Decodable {
    let response: String
}


struct ManekiResponseView: View {
    let content: String

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                ForEach(parseIntoBlocks(from: content), id: \.self) { block in
                    VStack(alignment: .leading, spacing: 6) {
                        if let header = block.header {
                            Text(header)
                                .font(.custom("Satoshi-Bold", size: 20))
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .multilineTextAlignment(.leading)
                        }
                        Text(parseMarkdownText(block.body))
                            .font(.custom("Satoshi-Regular", size: 16))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.leading)
                    }
                }
            }
            .padding()
            .background(Color(hex: "1F212F"))
            .cornerRadius(18)
            .frame(maxWidth: 280, alignment: .leading)
            Spacer()
        }
    }

    struct Block: Hashable {
        let header: String?
        let body: String
    }

    func parseMarkdownText(_ text: String) -> AttributedString {
        var attributedString = AttributedString(text)
        
        // Find and bold the word "Maneki" by replacing **Maneki** with Maneki and applying bold
        if let range = attributedString.range(of: "**Maneki**") {
            attributedString.replaceSubrange(range, with: AttributedString("Maneki"))
            if let newRange = attributedString.range(of: "Maneki") {
                attributedString[newRange].font = .custom("Satoshi-Bold", size: 16)
            }
        }
        
        return attributedString
    }
    
    func parseIntoBlocks(from input: String) -> [Block] {
        var blocks: [Block] = []

        let cleaned = input
            .replacingOccurrences(of: "\\n", with: "\n")
            .replacingOccurrences(of: "\\\"", with: "\"")
            .trimmingCharacters(in: CharacterSet(charactersIn: "\""))

        let lines = cleaned
            .components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }

        var currentHeader: String? = nil
        var currentBody: String = ""

        for i in 0..<lines.count {
            let line = lines[i]

            if line.hasPrefix("###") {
                if !currentBody.isEmpty || currentHeader != nil {
                    blocks.append(Block(header: currentHeader, body: currentBody.trimmingCharacters(in: .whitespaces)))
                    currentBody = ""
                }
                currentHeader = line.replacingOccurrences(of: "###", with: "").trimmingCharacters(in: .whitespaces)
            } else if let range = line.range(of: #"^\d+\.\s+\*\*(.*?)\*\*"#, options: .regularExpression) {
                if !currentBody.isEmpty {
                    blocks.append(Block(header: currentHeader, body: currentBody.trimmingCharacters(in: .whitespaces)))
                    currentBody = ""
                }
                let matched = String(line[range])
                let title = matched
                    .replacingOccurrences(of: #"^\d+\.\s+"#, with: "", options: .regularExpression)
                    .replacingOccurrences(of: "**", with: "")
                currentHeader = title
                currentBody = line.replacingOccurrences(of: matched, with: "").trimmingCharacters(in: .whitespaces)
            } else if line.hasPrefix("**") && line.hasSuffix("**") {
                if !currentBody.isEmpty {
                    blocks.append(Block(header: currentHeader, body: currentBody.trimmingCharacters(in: .whitespaces)))
                    currentBody = ""
                }
                currentHeader = line.replacingOccurrences(of: "**", with: "")
            } else if line.hasPrefix("- ") {
                currentBody += (currentBody.isEmpty ? "" : "\n") + "• " + line.dropFirst(2)
            } else if line == ":" || line.hasPrefix(": ") {
                // Colon line — append to header if available
                currentHeader = (currentHeader ?? "") + line.replacingOccurrences(of: ":", with: "")
            } else {
                currentBody += (currentBody.isEmpty ? "" : "\n") + line
            }
        }

        if !currentBody.isEmpty || currentHeader != nil {
            blocks.append(Block(header: currentHeader, body: currentBody.trimmingCharacters(in: .whitespaces)))
        }

        return blocks
    }

}
