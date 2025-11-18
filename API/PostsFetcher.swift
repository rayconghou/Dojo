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
    let is_admin: Bool
    var we_follow_them: Bool
    let followers_count: Int
    let followed_count: Int
    var profilePic: Data?
    
    enum CodingKeys: String, CodingKey {
        case firebase_uid
        case username
        case is_admin
        case we_follow_them
        case followers_count
        case followed_count
        case profilePic
    }
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

struct AddPostButton<T: PostsViewAbstractModel & PostsViewProtocol>: View {
    let preceding_post_id: Int?
    let current_feed: T
    
    @ObservedObject var user_profile: UserProfileViewModel
    
    @State var show_create_post_modal = false
    
    var body: some View {
        VStack {
            Spacer()
            
            HStack() {
                Spacer()
                
                Button(action: { show_create_post_modal = true }) {
                    Text("+")
                        .fontWeight(.semibold)
                        .font(.system(size: 50))
                        .foregroundColor(.white)
                        .frame(width: 80, height: 80)
                        .background(
                            RoundedRectangle(cornerRadius: 30)
                                .fill(Color(hex: "0C0C0C")) // dark opaque
                                .shadow(color: Color.white.opacity(0.08), radius: 10, x: 0, y: 6)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 30)
                                .stroke(Color.white.opacity(0.08), lineWidth: 1)
                        )
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
            .sheet(isPresented: $show_create_post_modal) {
                CreatePostView(preceding_post_id: preceding_post_id, current_feed: current_feed, user_profile: user_profile)
            }
        }
    }
}

struct PostCard: View {
    let post: Post
    let userProfile: UserProfileViewModel
    let other_user: OtherUser?
    
    @Binding var search_text: String
    
    private var firebase_uid: String {
        if let unwrapped_other_user = other_user {
            return unwrapped_other_user.firebase_uid
        }
        return userProfile.firebase_uid
    }
    private var username: String {
        if let unwrapped_other_user = other_user {
            return unwrapped_other_user.username
        }
        return userProfile.username
    }
    private var profile_pic: UIImage? {
        if let unwrapped_other_user = other_user {
            if let unwrapped_profile_pic_data = unwrapped_other_user.profilePic {
                if let ui_image = UIImage(data: unwrapped_profile_pic_data) {
                    return ui_image
                } else {
                    print("Bad image data snuck into UserProfile.")
                    return nil
                }
            } else {
                return nil
            }
        }
        return userProfile.profilePic
    }
    
    @State var likes_count: Int
    @State var we_liked_it: Bool
    
    @State var can_navigate_to_profile: Bool = true
    @State var can_navigate_to_post: Bool = true
    
    @Binding var hide_hamburger: Bool
    var hamburger_action: () -> Void
    
    var body: some View {
        ZStack {
            HStack {
                VStack {
                    NavigationLink {
                        ProfileView(
                            hide_hamburger: $hide_hamburger,
                            hamburger_action: {},
                            search_text: $search_text,
                            userProfile: userProfile,
                            feed: ProfileFeedModel(
                                user_profile: userProfile,
                                feed_key: firebase_uid,
                                other_user: other_user),
                            other_user: other_user
                        )
                    } label: {
                        if let unwrappedProfilePic = profile_pic {
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
                    }
                    .disabled(!can_navigate_to_profile)
                    Spacer()
                }
                
                Spacer()
                    .frame(width: 20)
                
                NavigationLink {
                    PostView(
                        hide_hamburger: $hide_hamburger,
                        hamburger_action: hamburger_action,
                        search_text: $search_text,
                        post: post,
                        user_profile: userProfile,
                        other_user: other_user,
                        feed: RepliesFeedModel(
                            user_profile: userProfile,
                            feed_key: String(post.id),
                            preceding_post_id: post.id
                        )
                    )
                } label: {
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
                    .contentShape(Rectangle())
                    .allowsHitTesting(can_navigate_to_post)
                }
//                .disabled(!can_navigate_to_post)
//                // To counter dimming from disabling
//                .buttonStyle(PlainButtonStyle())
                .buttonStyle(.plain)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.gray.opacity(0.15))
            .cornerRadius(12)
        }
        // Make less greedy
        .layoutPriority(-1)
    }
}

struct PostView: View {
    
    @Binding var hide_hamburger: Bool
    var hamburger_action: () -> Void
    
    @Binding var search_text: String
    
    let post: Post
    let user_profile: UserProfileViewModel
    let other_user: OtherUser?
    
    @StateObject var feed: RepliesFeedModel
    
    var body: some View {
        ZStack {
            VStack {
                if user_profile.firebase_uid == post.poster_uid {
                    PostCard(
                        post: post,
                        userProfile: user_profile,
                        other_user: nil,
                        search_text: $search_text,
                        likes_count: post.likes_count,
                        we_liked_it: false,
                        can_navigate_to_post: false,
                        hide_hamburger: $hide_hamburger,
                        hamburger_action: hamburger_action,
                        )
                } else if let other_user_having_feed = FeedModel.otherUserHavingFeed, let other_user = other_user_having_feed.otherUsers.first(where: { $0.firebase_uid == post.poster_uid }) {
                    PostCard(
                        post: post,
                        userProfile: user_profile,
                        other_user: other_user,
                        search_text: $search_text,
                        likes_count: post.likes_count,
                        we_liked_it: post.we_liked_it,
                        can_navigate_to_post: false,
                        hide_hamburger: $hide_hamburger,
                        hamburger_action: hamburger_action
                    )
                }
                Divider()
                FeedView(
                    hide_hamburger: $hide_hamburger,
                    hamburger_action: hamburger_action,
                    search_text: $search_text,
                    userProfile: user_profile,
                    postsViewModel: feed)
                Spacer()
            }
            
            AddPostButton(preceding_post_id: post.id, current_feed: feed, user_profile: user_profile)
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
    
    let user_profile: UserProfileViewModel
    
    static func hasOtherUser(firebase_uid: String) -> Bool {
        if let other_user_having_feed = FeedModel.otherUserHavingFeed {
            for otherUser in other_user_having_feed.otherUsers {
               if otherUser.firebase_uid == firebase_uid {
                   return true
               }
           }
        }
        return false
    }
    
    init(user_profile: UserProfileViewModel) {
        self.user_profile = user_profile
    }
}
protocol PostsViewProtocol: PostsViewAbstractModel {
    associatedtype T: PostsViewProtocol
    
    var feed_key: String { get set }
    static var feeds: [String: T] { get set }
    
    var N: Int { get }
    
    func refreshPosts()
    func fetchNewPosts()
}
extension PostsViewProtocol {
    // Num posts to get at time
    var N: Int { return 20 }
}

class FeedModel: PostsViewAbstractModel, PostsViewProtocol {
    var feed_key: String
    
    typealias T = FeedModel
    
    static var feeds: [String: T] = [:]
    static var otherUserHavingFeed: FeedModel?
    
    init(user_profile: UserProfileViewModel, feed_key: String) {
        self.feed_key = feed_key
        super.init(user_profile: user_profile)
        
        // TEMP: Able to move to parent?
        if let feed = T.feeds[feed_key] {
            self.posts = feed.posts
        } else {
            fetchNewPosts()
        }
        T.feeds[feed_key] = self

    }
    
    func refreshPosts() {
        //        TEMP, assuming this is the main feed by feed_key choice
        ContentView.webSocketManager.send(message: "{\"action\": \"getNConsecutivePosts\", \"message_type\":\"refreshFeedPosts\", \"feed_key\": \"main\", \"firebase_uid\": \"\(user_profile.firebase_uid)\", \"N\":\(N), \"start\":\(0), \"where_clause\": \"WHERE preceding_post_id IS NULL AND EXTRACT(EPOCH FROM created_at) > \(posts[0].created_at.timeIntervalSince1970.encoded()) AND (EXISTS(SELECT 1 FROM follows WHERE follows.follower_uid = '\(user_profile.firebase_uid)' AND follows.followed_uid = p.poster_uid) OR p.poster_uid = '\(user_profile.firebase_uid)' OR EXISTS(SELECT 1 FROM users WHERE users.firebase_uid = p.poster_uid AND users.is_admin = true)\"}")
    }
    func fetchNewPosts() {
        //        TEMP, assuming this is the main feed by feed_key choice
        ContentView.webSocketManager.send(message: "{\"action\": \"getNConsecutivePosts\", \"message_type\":\"addFeedPosts\", \"feed_key\": \"main\", \"firebase_uid\": \"\(user_profile.firebase_uid)\", \"N\":\(N), \"start\":\(posts.count), \"where_clause\": \"WHERE preceding_post_id IS NULL AND (EXISTS(SELECT 1 FROM follows WHERE follows.follower_uid = '\(user_profile.firebase_uid)' AND follows.followed_uid = p.poster_uid) OR p.poster_uid = '\(user_profile.firebase_uid)' OR EXISTS(SELECT 1 FROM users WHERE users.firebase_uid = p.poster_uid AND users.is_admin = true))\"}")
    }
}
class ProfileFeedModel: PostsViewAbstractModel, PostsViewProtocol {
    var feed_key: String
    
    typealias T = ProfileFeedModel
    
    static var feeds: [String: T] = [:]
    
    private let other_user_if_other_user: OtherUser?
    
    init(user_profile: UserProfileViewModel, feed_key: String, other_user: OtherUser? = nil) {
        self.feed_key = feed_key
        other_user_if_other_user = other_user
        super.init(user_profile: user_profile)
        
        if let feed = T.feeds[feed_key] {
            self.posts = feed.posts
        } else {
            fetchNewPosts()
        }
        T.feeds[feed_key] = self
    }
    
    func refreshPosts() {
        var poster_uid: String
        if let other_user = other_user_if_other_user {
            poster_uid = other_user.firebase_uid
        } else {
            poster_uid = user_profile.firebase_uid
        }
        ContentView.webSocketManager.send(message: "{\"action\": \"getNConsecutivePosts\", \"message_type\":\"refreshProfileFeedPosts\", \"feed_key\": \"\(feed_key)\", \"firebase_uid\": \"\(user_profile.firebase_uid)\", \"N\":\(N), \"start\":\(0), \"where_clause\": \"WHERE preceding_post_id IS NULL AND EXTRACT(EPOCH FROM created_at) > \(posts[0].created_at.timeIntervalSince1970.encoded()) AND poster_uid = '\(poster_uid)'\"}")
    }
    func fetchNewPosts() {
        var poster_uid: String
        if let other_user = other_user_if_other_user {
            poster_uid = other_user.firebase_uid
        } else {
            poster_uid = user_profile.firebase_uid
        }
        
        ContentView.webSocketManager.send(message: "{\"action\": \"getNConsecutivePosts\", \"message_type\":\"addProfileFeedPosts\", \"feed_key\": \"\(feed_key)\", \"firebase_uid\": \"\(user_profile.firebase_uid)\", \"N\":\(N), \"start\":\(posts.count), \"where_clause\": \"WHERE preceding_post_id IS NULL AND poster_uid = '\(poster_uid)'\"}")
    }
}
class RepliesFeedModel: PostsViewAbstractModel, PostsViewProtocol {
    var feed_key: String
    
    typealias T = RepliesFeedModel
    
    static var feeds: [String: T] = [:]
    
    private let preceding_post_id: Int
    
    init(user_profile: UserProfileViewModel, feed_key: String, preceding_post_id: Int) {
        self.feed_key = feed_key
        self.preceding_post_id = preceding_post_id
        super.init(user_profile: user_profile)
        
        if let feed = T.feeds[feed_key] {
            self.posts = feed.posts
        } else {
            fetchNewPosts()
        }
        T.feeds[feed_key] = self
    }
    
    func refreshPosts() {
        ContentView.webSocketManager.send(message: "{\"action\": \"getNConsecutivePosts\", \"message_type\":\"refreshRepliesFeedPosts\", \"feed_key\": \"\(feed_key)\", \"firebase_uid\": \"\(user_profile.firebase_uid)\", \"N\":\(N), \"start\":\(0), \"where_clause\": \"WHERE preceding_post_id = \(preceding_post_id) AND EXTRACT(EPOCH FROM created_at) > \(posts[0].created_at.timeIntervalSince1970.encoded())\"}")
    }
    
    func fetchNewPosts() {
        ContentView.webSocketManager.send(message: "{\"action\": \"getNConsecutivePosts\", \"message_type\":\"addRepliesFeedPosts\", \"feed_key\": \"\(feed_key)\", \"firebase_uid\": \"\(user_profile.firebase_uid)\", \"N\":\(N), \"start\":\(posts.count), \"where_clause\": \"WHERE preceding_post_id = \(preceding_post_id)\"}")
    }
}
