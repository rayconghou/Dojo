//
//  WebSocketManager.swift
//  FortuneCollective
//
//  Created by Hugh on 9/20/25.
//


import Foundation
import FirebaseAuth

enum WebSocketError: Error {
    case badResponse
    case badIdToken
    case forgotUID
}

class WebSocketManager: NSObject, URLSessionWebSocketDelegate {
    var webSocketTask: URLSessionWebSocketTask?
    var urlSession: URLSession?

    var isConnected: Bool = false
    
    private var firebase_uid: String? = nil
    
    func connect(url: URL, user: User) {
        firebase_uid = user.uid
        
        user.getIDTokenForcingRefresh(true) { idToken, error in
            if let error = error {
                print("Error: \(error)")
                return
            }
            
            if let unwrappedIdToken = idToken {
                self.urlSession = URLSession(configuration: .default, delegate: self, delegateQueue: OperationQueue())
                var request = URLRequest(url: url)
                request.setValue(unwrappedIdToken, forHTTPHeaderField: "authorizationToken")
                self.webSocketTask = self.urlSession?.webSocketTask(with: request)
                self.webSocketTask?.resume()
                print("Attempting to connect to WebSocket...")
            } else {
                print("Error: \(WebSocketError.badIdToken)")
            }
        }
    }

    func send(message: String) {
        let message = URLSessionWebSocketTask.Message.string(message)
        webSocketTask?.send(message) { error in
            if let error = error {
                print("Error sending message: \(error)")
            }
        }
    }

    func receiveMessage() {
        webSocketTask?.receive { [weak self] result in
            switch result {
            case .failure(let error):
                print("Error receiving message: \(error)")
            case .success(let message):
                switch message {
                case .string(let text):
                    print("Received text: \(text)")
                    
                    // Process the received message
                    Task {
                        let decoder = JSONDecoder()
                        guard let jsonData = text.data(using: .utf8) else {
                            print("Error:", WebSocketError.badResponse)
                            throw WebSocketError.badResponse
                        }
                        
                        // Handle different message types
                        if text.contains("error") || text.contains("Failed") {
                            print("Backend error received: \(text)")
                            // Don't try to decode error messages as user profile
                            return
                        }
                        
                        struct userProperties: Decodable {
                            let email: String
                            let username: String
                        }
                        
                        struct errorResponse: Decodable {
                            let message: String
                            let error: String
                        }
                        
                        do {
                            let userProfileProperties = try decoder.decode(userProperties.self, from: jsonData)
                            AuthManager.shared.userProfile = UserProfileViewModel(email: userProfileProperties.email, username: userProfileProperties.username)
                        } catch {
                            // If that fails, try to decode as error response
                            do {
                                let errorResponse = try decoder.decode(errorResponse.self, from: jsonData)
                                print("Backend error: \(errorResponse.message) - \(errorResponse.error)")
                            } catch {
                                print("Error decoding JSON: \(error.localizedDescription)")
                                print("Raw message: \(text)")
                            }
                            AuthManager.shared.signOut()
                        }
                    }
                    
                case .data(let data):
                    print("Received data: \(data)")
                    // Process the received data
                @unknown default:
                    break
                }
                self?.receiveMessage() // Continue receiving
            }
        }
    }

    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
        print("WebSocket connection opened.")
        receiveMessage() // Start receiving messages once connected
        
        isConnected = true
        
//        If we have a userProfile, send it to DB. Else, get the profile from the DB
        if let uP = AuthManager.shared.userProfile {
            addUserProfileToDB(email: uP.email, username: uP.username)
        } else {
            getUserProfile()
        }
    }

    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        print("WebSocket connection closed with code: \(closeCode)")
        // Handle disconnection, potentially attempt to reconnect
        
        isConnected = false
    }
    
    func getUserProfile() {
        if let unwrapped_firebase_uid = firebase_uid {
            send(message: "{\"action\": \"getUserProfile\", \"firebase_uid\": \"" + unwrapped_firebase_uid + "\"}")
        } else {
            print("Error: \(WebSocketError.forgotUID)")
        }
    }
    
    func addUserProfileToDB(email: String, username: String) {
        if let unwrapped_firebase_uid = firebase_uid {
            ContentView.webSocketManager.send(message: "{\"action\": \"addUserProfile\", \"firebase_uid\":\"\(unwrapped_firebase_uid)\",\"username\":\"\(username)\",\"email\":\"\(email)\"}")
        } else {
            print("Error: \(WebSocketError.forgotUID)")
        }

//        do {
//                let config = try await SQSClient.SQSClientConfiguration(region: AuthManager.aws_region)
//                let sqsClient = SQSClient(config: config)
//                _ = try await sqsClient.sendMessage(
//                    input: SendMessageInput(
//                        messageBody: "{\"firebase_uid\":\"\(firebase_uid)\",\"username\":\"\(username)\",\"email\":\"\(email)\"}",
//                        queueUrl: "https://sqs.\(AuthManager.aws_region).amazonaws.com/497197924608/LambdaRDSQueue"
//                    )
//                )
//            
//            completion(.success(()))
//        } catch {
//            print("Error: \(error)")
//            completion(.failure(error))
//        }
    }
}
