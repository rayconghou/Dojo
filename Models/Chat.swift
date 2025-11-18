//
//  ChatMessage.swift
//  Dojo
//
//  Created by Raymond Hou on 3/11/25.
//

import Foundation
import SwiftUI


struct ChatUser: Identifiable, Equatable {
    let id = UUID()
    let username: String
    let profileImage: String
    var isOnline: Bool = false
    var isFriend: Bool = false
}

struct ChatMessage: Identifiable {
    let id = UUID()
    let sender: ChatUser
    let content: String
    let timestamp: Date
    var isFromCurrentUser: Bool = false
}

struct ChatRoom: Identifiable {
    let id = UUID()
    let name: String
    let description: String
    let type: ChatRoomType
    var participants: [ChatUser]
    var messages: [ChatMessage] = []
    var icon: String {
        switch type {
        case .global: return "globe"
        case .help: return "questionmark.circle"
        case .group: return "person.3"
        case .direct: return "message"
        }
    }
}

enum ChatRoomType {
    case global
    case help
    case group
    case direct
}

class ChatViewModel: ObservableObject {
    @Published var currentUser = ChatUser(username: "YourUsername", profileImage: "person.circle.fill")
    @Published var selectedChatRoom: ChatRoom?
    @Published var chatRooms: [ChatRoom] = []
    @Published var searchText: String = ""
    @Published var friends: [ChatUser] = []
    @Published var pendingFriendRequests: [ChatUser] = []
    @Published var messageText: String = ""
    @Published var showCreateGroupSheet: Bool = false
    @Published var showFriendRequestSheet: Bool = false
    @Published var showProfileSheet: Bool = false
    
    init() {
        // Sample data
        let user1 = ChatUser(username: "Alex", profileImage: "person.circle.fill", isOnline: true)
        let user2 = ChatUser(username: "Jamie", profileImage: "person.circle.fill", isOnline: false)
        let user3 = ChatUser(username: "Taylor", profileImage: "person.circle.fill", isOnline: true, isFriend: true)
        
        self.friends = [user3]
        
        let globalChat = ChatRoom(
//            id: UUID(),
            name: "Global Chat",
            description: "Chat with everyone on the platform",
            type: .global,
            participants: [currentUser, user1, user2, user3],
            messages: [
                ChatMessage(sender: user1, content: "Hey everyone!", timestamp: Date().addingTimeInterval(-3600)),
                ChatMessage(sender: user3, content: "Hello! Anyone want to chat?", timestamp: Date().addingTimeInterval(-1800)),
                ChatMessage(sender: currentUser, content: "I'm new here, nice to meet you all!", timestamp: Date().addingTimeInterval(-900), isFromCurrentUser: true)
            ]
        )
        
        let helpChat = ChatRoom(
//            id: UUID(),
            name: "Help & Support",
            description: "Get assistance from the community",
            type: .help,
            participants: [currentUser, user1, user2, user3],
            messages: [
                ChatMessage(sender: user2, content: "How do I create a group chat?", timestamp: Date().addingTimeInterval(-7200)),
                ChatMessage(sender: user1, content: "Tap on the + button in the top right corner!", timestamp: Date().addingTimeInterval(-7100))
            ]
        )
        
        let groupChat = ChatRoom(
//            id: UUID(),
            name: "Weekend Plans",
            description: "Planning our weekend activities",
            type: .group,
            participants: [currentUser, user3],
            messages: [
                ChatMessage(sender: user3, content: "What are we doing this weekend?", timestamp: Date().addingTimeInterval(-5400)),
                ChatMessage(sender: currentUser, content: "Maybe we could go hiking?", timestamp: Date().addingTimeInterval(-5300), isFromCurrentUser: true)
            ]
        )
        
        self.chatRooms = [globalChat, helpChat, groupChat]
        self.selectedChatRoom = globalChat
    }
    
    func sendMessage() {
        guard !messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              var chatRoom = selectedChatRoom else { return }
        
        let newMessage = ChatMessage(
            sender: currentUser,
            content: messageText,
            timestamp: Date(),
            isFromCurrentUser: true
        )
        
        // Find and update the chat room
        if let index = chatRooms.firstIndex(where: { $0.id == chatRoom.id }) {
            chatRooms[index].messages.append(newMessage)
            selectedChatRoom = chatRooms[index]
        }
        
        messageText = ""
    }
    
    func createGroupChat(name: String, participants: [ChatUser]) {
        let newGroup = ChatRoom(
//            id: UUID(),
            name: name,
            description: "Group chat",
            type: .group,
            participants: participants + [currentUser]
        )
        chatRooms.append(newGroup)
        selectedChatRoom = newGroup
    }
    
    func addFriend(user: ChatUser) {
        var updatedUser = user
        updatedUser.isFriend = true
        friends.append(updatedUser)
        if let index = pendingFriendRequests.firstIndex(where: { $0.id == user.id }) {
            pendingFriendRequests.remove(at: index)
        }
    }
    
    func filteredChatRooms() -> [ChatRoom] {
        if searchText.isEmpty {
            return chatRooms
        } else {
            return chatRooms.filter {
                $0.name.lowercased().contains(searchText.lowercased()) ||
                $0.description.lowercased().contains(searchText.lowercased())
            }
        }
    }
}

struct ManekiChatMessage: Identifiable {
    let id: Int
    let content: String
    let isFromUser: Bool
}

struct ManekiChatBubble: View {
    let message: ManekiChatMessage
    var body: some View {
        HStack {
            if message.isFromUser { Spacer() }
            Text(message.content)
                .padding()
                .background(message.isFromUser ? Color(hex: "282A45") : Color(hex: "141628"))
                .foregroundColor(.white)
                .cornerRadius(18)
                .frame(maxWidth: 280, alignment: message.isFromUser ? .trailing : .leading)
            if !message.isFromUser { Spacer() }
        }
    }
}
