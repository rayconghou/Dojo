//
//  WebSocketManager.swift
//  FortuneCollective
//
//  Created by Hugh on 9/20/25.
//


import Foundation
import FirebaseAuth
import UIKit

enum WebSocketError: Error {
    case badResponse
    case badIdToken
    case forgotUID
    case unknownMessageType
    case badImageData
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
//        if (isConnected) {
//            
//        }
//        print("TEST: \(isConnected)")
        
        let message = URLSessionWebSocketTask.Message.string(message)
        self.webSocketTask?.send(message) { error in
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
//                    print("Received text: \(text)")
                    
                    // Process the received message
                    Task {
                        let decoder = JSONDecoder()
                        decoder.dateDecodingStrategy = .secondsSince1970
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
                        
                        struct idAble: Decodable {
                            let id: String
                        }
                        
                        struct ResponseMessageProperties: Decodable {
                            let message_type: String
                        }
                        
                        struct UserProperties: Decodable {
                            let email: String
                            let username: String
                            let followers_count: Int
                            let followed_count: Int
                        }
                        struct ObjectProperties: Decodable {
                            let data_base_64_encoded_string: String
                        }
                        
                        struct ErrorResponse: Decodable {
                            let message: String
                            let error: String
                        }
                        
                        do {
                            let responseMessageProperties = try decoder.decode(ResponseMessageProperties.self, from: jsonData)
                            let messageType = responseMessageProperties.message_type
                            print("messageType: \(messageType)")
                            
                            switch messageType {
                            case "getUserProfile":
                                let userProperties = try decoder.decode(UserProperties.self, from: jsonData)
                                if let unwrapped_firebase_uid = self!.firebase_uid {
                                    AuthManager.shared.userProfile = UserProfileViewModel(firebase_uid: unwrapped_firebase_uid, email: userProperties.email, username: userProperties.username, followed_count: userProperties.followed_count, followers_count: userProperties.followers_count)
                                } else {
                                    throw WebSocketError.forgotUID
                                }
                            case "getUserProfilePic":
                                let objectProperties = try decoder.decode(ObjectProperties.self, from: jsonData)
                                if objectProperties.data_base_64_encoded_string != "File not found" {
                                    if let data = Data(base64Encoded: objectProperties.data_base_64_encoded_string) {
                                        if let userProfile = AuthManager.shared.userProfile {
                                            userProfile.profilePic = UIImage(data: data)
                                        } else {
                                            AuthManager.shared.profilePic = UIImage(data: data)
                                        }
                                    } else {
                                        throw WebSocketError.badImageData
                                    }
                                }
                                //                            case "getPost":
                                //                                let postProperties = try decoder.decode(Post.self, from:jsonData)
                                //                                // TEMP
                                //                                PostsViewModel.shared.posts.append(postProperties);
                                //
                                //                                if (postProperties.poster_uid != self!.firebase_uid && !PostsViewModel.hasOtherUser(otherUsers: PostsViewModel.shared.otherUsers, firebase_uid: postProperties.poster_uid)) {
                                //                                    self!.send(message: "{\"action\": \"getUserProfile\", \"message_type\": \"getOtherUserProfile\", \"firebase_uid\": \"" + postProperties.poster_uid + "\"}")
                                //                                }
                                
                            case "refreshFollowersView", "addFollowersView", "refreshFollowedView", "addFollowedView", "refreshSearchedProfilesView", "addSearchedProfilesView":
                                struct ResponseWrapper: Decodable {
                                    let rows: [User_UID]
                                    let N: Int
                                    let feed_key: String
                                }
                                let usersProperties = try decoder.decode(ResponseWrapper.self, from: jsonData)
                                
                                var feeds: [String: any ProfilesViewProtocol]
                                switch messageType {
                                case "refreshFollowersView", "addFollowersView":
                                    feeds = FollowersModel.feeds
                                case "refreshFollowedView", "addFollowedView":
                                    feeds = FollowedModel.feeds
                                case "refreshSearchedProfilesView", "addSearchedProfilesView":
                                    feeds = SearchedProfilesModel.feeds
                                default:
                                    throw WebSocketError.unknownMessageType
                                }
                                
                                if let feed = feeds[usersProperties.feed_key] {
                                    switch messageType {
                                    case "refreshFollowersView", "refreshFollowedView", "refreshSearchedProfilesView":
                                        // TEMP: Only able to refresh from start (if post array becomes disjointed, then I cut off the old stuff)
                                        
                                        var newUserIDs = usersProperties.rows
                                        // For now, if posts become disjoint discard old stuff
                                        if (usersProperties.rows.count < usersProperties.N) {
                                            newUserIDs.append(contentsOf: feed.user_uids)
                                        }
                                        feed.user_uids = newUserIDs
                                    case "addFollowersView", "addFollowedView", "addSearchedProfilesView":
                                        
                                        if (usersProperties.rows.count < usersProperties.N) {
                                            feed.noMoreUsers = true
                                        }
                                        feed.user_uids.append(contentsOf: usersProperties.rows)
                                        feed.user_uids = feed.user_uids
                                    default:
                                        throw WebSocketError.unknownMessageType
                                    }
                                    
                                    for usersProperties in usersProperties.rows {
                                        if (usersProperties.firebase_uid != self!.firebase_uid && !FeedModel.hasOtherUser(firebase_uid: usersProperties.firebase_uid)) {
                                            self!.send(message: "{\"action\": \"getUserProfile\", \"message_type\": \"getOtherUserProfile\", \"firebase_uid\": \"" + AuthManager.shared.userProfile!.firebase_uid + "\", \"user_uid\": \"" + usersProperties.firebase_uid + "\"}")
                                        }
                                    }
                                }
                            case "refreshFeedPosts", "addFeedPosts", "refreshProfileFeedPosts", "addProfileFeedPosts", "refreshRepliesFeedPosts", "addRepliesFeedPosts":
                                struct ResponseWrapper: Decodable {
                                    let rows: [Post]
                                    let N: Int
                                    let feed_key: String
                                }
                                let postsProperties = try decoder.decode(ResponseWrapper.self, from: jsonData)
                                
                                var feeds: [String: any PostsViewProtocol]
                                switch messageType {
                                case "refreshFeedPosts", "addFeedPosts":
                                    feeds = FeedModel.feeds
                                case "refreshProfileFeedPosts", "addProfileFeedPosts":
                                    feeds = ProfileFeedModel.feeds
                                case "refreshRepliesFeedPosts", "addRepliesFeedPosts":
                                    feeds = RepliesFeedModel.feeds
                                default:
                                    throw WebSocketError.unknownMessageType
                                }
                                
                                if let feed = feeds[postsProperties.feed_key] {
                                    switch messageType {
                                    case "refreshFeedPosts", "refreshProfileFeedPosts", "refreshRepliesFeedPosts":
                                        // TEMP: Only able to refresh from start (if post array becomes disjointed, then I cut off the old stuff)
                                        // TEMP: Assumes posts are sorted chronologically
                                        
                                        var newFeedPosts = postsProperties.rows
                                        // For now, if posts become disjoint discard old stuff
                                        if (postsProperties.rows.count < postsProperties.N) {
                                            newFeedPosts.append(contentsOf: feed.posts)
                                        }
                                        feed.posts = newFeedPosts
                                    case "addFeedPosts", "addProfileFeedPosts", "addRepliesFeedPosts":
                                        
                                        if (postsProperties.rows.count < postsProperties.N) {
                                            feed.noMorePosts = true
                                        }
                                        feed.posts.append(contentsOf: postsProperties.rows)
                                        feed.posts = feed.posts
                                    default:
                                        throw WebSocketError.unknownMessageType
                                    }
                                    
                                    for postProperties in postsProperties.rows {
                                        if (postProperties.poster_uid != self!.firebase_uid && !FeedModel.hasOtherUser(firebase_uid: postProperties.poster_uid)) {
                                            self!.send(message: "{\"action\": \"getUserProfile\", \"message_type\": \"getOtherUserProfile\", \"firebase_uid\": \"" + AuthManager.shared.userProfile!.firebase_uid + "\", \"user_uid\": \"" + postProperties.poster_uid + "\"}")
                                        }
                                    }
                                }
                            case "getOtherUserProfile":
                                let userProperties = try decoder.decode(OtherUser.self, from: jsonData)
                                let new_other_users = FeedModel.otherUserHavingFeed!.otherUsers + [userProperties]
                                FeedModel.otherUserHavingFeed!.otherUsers = new_other_users
                                
                                self!.send(message: "{\"action\": \"getObjectDojoS3\", \"message_type\": \"getOtherUserProfilePic\", \"id\":\"\(userProperties.firebase_uid)\", \"object_name\":\"\(userProperties.firebase_uid).jpeg\"}")
                            case "getOtherUserProfilePic":
                                let objectProperties = try decoder.decode(ObjectProperties.self, from: jsonData)
                                if objectProperties.data_base_64_encoded_string != "File not found" {
                                    if let data = Data(base64Encoded: objectProperties.data_base_64_encoded_string) {
                                        let idProperties = try decoder.decode(idAble.self, from: jsonData)
                                        
                                        if let otherUserIndex = FeedModel.otherUserHavingFeed!.otherUsers.firstIndex(where: { $0.firebase_uid == idProperties.id }) {
                                            FeedModel.otherUserHavingFeed!.otherUsers[otherUserIndex].profilePic = data
                                            
                                            // TEMP: to update
                                            FeedModel.otherUserHavingFeed!.otherUsers = FeedModel.otherUserHavingFeed!.otherUsers
                                        }
                                    } else {
                                        throw WebSocketError.badImageData
                                    }
                                }
                            default:
                                throw WebSocketError.unknownMessageType
                            }
                        } catch {
                            // If that fails, try to decode as error response
                            do {
                                let errorResponse = try decoder.decode(ErrorResponse.self, from: jsonData)
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
//        sendPing() // Continually ping to maintain connection
        
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
            send(message: "{\"action\": \"getUserProfile\", \"message_type\": \"getUserProfile\", \"firebase_uid\": \"" + unwrapped_firebase_uid + "\", \"user_uid\": \"" + unwrapped_firebase_uid + "\"}")
            send(message: "{\"action\": \"getObjectDojoS3\", \"message_type\": \"getUserProfilePic\", \"id\": null, \"object_name\":\"\(unwrapped_firebase_uid).jpeg\"}")
        } else {
            print("Error: \(WebSocketError.forgotUID)")
        }
    }
    
    func addUserProfileToDB(email: String, username: String) {
        if let unwrapped_firebase_uid = firebase_uid {
            send(message: "{\"action\": \"addUserProfile\", \"firebase_uid\":\"\(unwrapped_firebase_uid)\",\"username\":\"\(username)\",\"email\":\"\(email)\"}")
//            Task {
//                if let fileURL = Bundle.main.url(forResource: "test", withExtension: ".rtf") {
//                    let data = try Data(contentsOf: fileURL)
//                    print("TEMP sending .txt instead of image")
//                    send(message: "{\"action\": \"addObjectDojoS3\", \"data_base_64_encoded_string\":\"\(data.base64EncodedString())\", \"firebase_uid\":\"\(unwrapped_firebase_uid)\", \"file_extension\":\".txt\"}")
//                }
//            }
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
