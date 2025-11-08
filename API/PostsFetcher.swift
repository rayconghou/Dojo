//
//  PostsFetcher.swift
//  Dojo
//
//  Created by Hugh on 10/31/25.
//

import Foundation
import Combine
import PhotosUI
import SwiftUI

struct OtherUser: Codable {
    let firebase_uid: String
    let username: String
    var profilePic: Data?
    
    enum CodingKeys: String, CodingKey {
        case firebase_uid
        case username
        case profilePic
    }
    
//    mutating func setProfilePicData(profilePicData: Data) {
//        profilePic = profilePicData
//    }
}

struct Post: Codable, Identifiable {
    let id: Int
    let poster_uid: String
    let preceding_post_id: Int?
    let text: String
    let created_at: Date
    let likes_count: Int
    let we_liked_it: Bool
    
    enum CodingKeys: String, CodingKey {
        case id = "post_id"
        case poster_uid
        case preceding_post_id
        case text
        case created_at
        case likes_count
        case we_liked_it
    }
}

struct PostCard: View {
    let post: Post
    let username: String
    let profilePic: UIImage?
    
    @State var likes_count: Int
    @State var we_liked_it: Bool
    
    @Binding var selectedPost: Post?
    
    var body: some View {
        HStack {
            VStack {
                if let unwrappedProfilePic = profilePic {
                    Image(uiImage: unwrappedProfilePic)
                        .resizable()
                        .frame(width: 30, height: 30)
                        .foregroundColor(.white)
                } else {
                    Image(systemName: "person.crop.circle.fill")
                        .resizable()
                        .frame(width: 30, height: 30)
                        .foregroundColor(.white)
                }
                Spacer()
            }
            Spacer()
                .frame(width: 20)
            VStack {
                Text(username)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .bold()
                Text(post.text)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Spacer()
                    .frame(height: 10)
                HStack {
                    Spacer()
                    Text(String(likes_count))
                    Button(action: {
                        if let unwrappedUserProfile = AuthManager.shared.userProfile {
                            // Cannnot like own posts
                            if unwrappedUserProfile.firebase_uid != post.poster_uid {
                                we_liked_it = !we_liked_it
                                if we_liked_it {
                                    likes_count += 1;
                                    ContentView.webSocketManager.send(message: "{\"action\": \"AddLike\", \"firebase_uid\": \"\(unwrappedUserProfile.firebase_uid)\", \"liked_id\":\(post.id)}")
                                } else {
                                    likes_count -= 1;
                                    ContentView.webSocketManager.send(message: "{\"action\": \"DeleteLike\", \"firebase_uid\": \"\(unwrappedUserProfile.firebase_uid)\", \"liked_id\":\(post.id)}")
                                }
                            }
                        }
                    }) {
                        if we_liked_it {
                            Image(systemName: "heart.fill")
                        } else {
                            Image(systemName: "heart")
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.gray.opacity(0.15))
        .cornerRadius(12)
        .onTapGesture {
            selectedPost = post
        }
    }
}
        
// MARK: - PostsViewModel

// DO NOT INSTANTIATE
class PostsViewAbstractModel: ObservableObject {
    @Published var noMorePosts = false

    // Data
    @Published var posts: [Post] = []
    // Treated as proto-static by just using the one attached to main feed
    @Published var otherUsers: [OtherUser] = []
    
    static func hasOtherUser(firebase_uid: String) -> Bool {
        for otherUser in FeedModel.otherUserHavingFeed.otherUsers {
           if otherUser.firebase_uid == firebase_uid {
               return true
           }
       }
       return false
    }
}
protocol PostsViewProtocol: PostsViewAbstractModel {
    associatedtype T: PostsViewProtocol
    
    static var feeds: [String: T] { get }
    
    var N: Int { get }
    
    func refreshPosts()
    func fetchNewPosts()
}
extension PostsViewProtocol {
    // Num posts to get at time
    var N: Int { return 20 }
}

class FeedModel: PostsViewAbstractModel, PostsViewProtocol {
    typealias T = FeedModel
    
    static let otherUserHavingFeed = FeedModel()
    static var feeds = ["main": otherUserHavingFeed]
    
    override init() {
    }
    
    func refreshPosts() {
        if let unwrappedUserProfile = AuthManager.shared.userProfile {
            //        TEMP, assuming this is the main feed by feed_key choice
            ContentView.webSocketManager.send(message: "{\"action\": \"getNConsecutivePosts\", \"message_type\":\"refreshFeedPosts\", \"feed_key\": \"main\", \"firebase_uid\": \"\(unwrappedUserProfile.firebase_uid)\", \"N\":\(N), \"start\":\(0), \"where_clause\": \"WHERE preceding_post_id IS NULL AND EXTRACT(EPOCH FROM created_at) > \(posts[0].created_at.timeIntervalSince1970.encoded())\"}")
        }
    }
    func fetchNewPosts() {
        if let unwrappedUserProfile = AuthManager.shared.userProfile {
            //        TEMP, assuming this is the main feed by feed_key choice
            ContentView.webSocketManager.send(message: "{\"action\": \"getNConsecutivePosts\", \"message_type\":\"addFeedPosts\", \"feed_key\": \"main\", \"firebase_uid\": \"\(unwrappedUserProfile.firebase_uid)\", \"N\":\(N), \"start\":\(posts.count), \"where_clause\": \"WHERE preceding_post_id IS NULL\"}")
        }
    }
}
class ProfileFeedModel: PostsViewAbstractModel, PostsViewProtocol {
    typealias T = ProfileFeedModel
    
    static var feeds: [String: T] = [:]
    
    private let other_user_if_other_user: OtherUser?
    
    override init() {
        other_user_if_other_user = nil
        super.init()
        
        fetchNewPosts()
    }
    init(otherUser: OtherUser) {
        other_user_if_other_user = otherUser
        super.init()
        
        fetchNewPosts()
    }
    
    func refreshPosts() {
        if let unwrappedUserProfile = AuthManager.shared.userProfile {
//            TEMP:TO DO
            
            //        TEMP, assuming this is the feed by message_type choice
            ContentView.webSocketManager.send(message: "{\"action\": \"getNConsecutivePosts\", \"message_type\":\"refreshFeedPosts\", \"feed_key\": \"main\", \"firebase_uid\": \"\(unwrappedUserProfile.firebase_uid)\", \"N\":\(N), \"start\":\(0), \"where_clause\": \"WHERE preceding_post_id IS NULL AND EXTRACT(EPOCH FROM created_at) > \(posts[0].created_at.timeIntervalSince1970.encoded())\"}")
        }
    }
    func fetchNewPosts() {
        if let unwrappedUserProfile = AuthManager.shared.userProfile {
//            TEMP: TO DO
            
            //        TEMP, assuming this is the main feed by message_type choice
            ContentView.webSocketManager.send(message: "{\"action\": \"getNConsecutivePosts\", \"message_type\":\"addFeedPosts\", \"feed_key\": \"main\", \"firebase_uid\": \"\(unwrappedUserProfile.firebase_uid)\", \"N\":\(N), \"start\":\(posts.count), \"where_clause\": \"WHERE preceding_post_id IS NULL\"}")
        }
    }
}
