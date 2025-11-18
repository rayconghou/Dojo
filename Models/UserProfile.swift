//
//  UserProfile.swift
//  Dojo
//
//  Created by Raymond Hou on 3/13/25.
//

import Foundation
import SwiftUI
import PhotosUI

struct User_UID: Codable, Identifiable {
    let id = UUID().uuidString
    let firebase_uid: String
    
    enum CodingKeys: String, CodingKey {
        case firebase_uid
    }
}

struct ProfileCard: View {
    let user_profile: UserProfileViewModel
    
    @Binding var search_text: String
    
    private var firebase_uid: String {
        if let unwrapped_other_user = other_user {
            return unwrapped_other_user.firebase_uid
        }
        return user_profile.firebase_uid
    }
    private var username: String {
        if let unwrapped_other_user = other_user {
            return unwrapped_other_user.username
        }
        return user_profile.username
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
        return user_profile.profilePic
    }
    
    // Set if this is another user's profile
    @State var other_user: OtherUser?
    @State var can_navigate_to_profile: Bool = true
    
    @Binding var hide_hamburger: Bool
    var hamburger_action: () -> Void
    
    var body: some View {
        ZStack {
            NavigationLink {
                ProfileView(
                    hide_hamburger: $hide_hamburger,
                    hamburger_action: hamburger_action,
                    search_text: $search_text,
                    userProfile: user_profile,
                    feed: ProfileFeedModel(
                        user_profile: user_profile,
                        feed_key: firebase_uid,
                        other_user: other_user),
                    other_user: other_user
                )
            } label: {
                HStack {
                    VStack {
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
                        Spacer()
                    }
                    
                    Spacer()
                        .frame(width: 20)
                    
                    VStack {
                        HStack {
                            Text(username)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .bold()
                            
                            if let unwrapped_other_user = other_user, !unwrapped_other_user.is_admin {
                                Button(action: {
                                    if let other_user_having_feed = FeedModel.otherUserHavingFeed, let other_user_index = other_user_having_feed.otherUsers.firstIndex(where: { $0.firebase_uid == unwrapped_other_user.firebase_uid }) {
                                        
                                        var new_users = other_user_having_feed.otherUsers
                                        var new_user = new_users[other_user_index]
                                        new_user.we_follow_them = !unwrapped_other_user.we_follow_them
                                        new_users[other_user_index] = new_user
                                        other_user = new_user
                                        other_user_having_feed.otherUsers = new_users
                                        
                                        if new_user.we_follow_them  {
                                            ContentView.webSocketManager.send(message: "{\"action\": \"AddFollow\", \"firebase_uid\": \"\(user_profile.firebase_uid)\", \"followed_uid\":\"\(unwrapped_other_user.firebase_uid)\"}")
                                        } else {
                                            ContentView.webSocketManager.send(message: "{\"action\": \"DeleteFollow\", \"firebase_uid\": \"\(user_profile.firebase_uid)\", \"followed_uid\":\"\(unwrapped_other_user.firebase_uid)\"}")
                                        }
                                    }
                                }) {
                                    if (unwrapped_other_user.we_follow_them) {
                                        Text("Unfollow")
                                    } else {
                                        Text("Follow")
                                    }
                                }
                            }
                        }
                        // TEMP: Add bios here
                        Spacer()
                            .frame(height: 10)
                    }
                    .frame(maxWidth: .infinity)
                    
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.gray.opacity(0.15))
                .cornerRadius(12)
                .contentShape(Rectangle())
                .allowsHitTesting(can_navigate_to_profile)
            }
            .buttonStyle(.plain)
        }
        // Make less greedy
        .layoutPriority(-1)
    }
}

// MARK: - Profile Modal

class UserProfileViewModel: ObservableObject {
    var firebase_uid: String
    @Published var username: String
    @Published var email: String
    @Published var profilePic: UIImage?
    @Published var followed_count: Int
    @Published var followers_count: Int
    
    static let pixelLimit: Double = 1000
    
    init(firebase_uid: String = "0", email: String = "james@example.com", username: String = "James Wang", followed_count: Int = 0, followers_count: Int = 0) {
        self.firebase_uid = firebase_uid
        self.username = username
        self.email = email
        self.followed_count = followed_count
        self.followers_count = followers_count
        
        if profilePic == nil {
            if let profilePic = AuthManager.shared.profilePic {
                self.profilePic = profilePic
            }
        }
    }
}

struct ProfileView: View {
    @Environment(\.dismiss) var dismiss
    
    @Binding var hide_hamburger: Bool
    var hamburger_action: () -> Void
    
    @Binding var search_text: String
    
    // For setting your profile pic
    @ObservedObject var userProfile: UserProfileViewModel
    @StateObject var feed: ProfileFeedModel
    
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
    
    // Set if this is another user's profile
    @State var other_user: OtherUser?
    
    @State private var selectedPickerItem: PhotosPickerItem?
    
    private let DIST_FROM_TOP_TO_DIVIDER = 100.0
    private let IMAGE_DIAMETER = 100.0
    
    var body: some View {
        ZStack {
            // Background
            VStack {
                Color.gray
                    .frame(height: DIST_FROM_TOP_TO_DIVIDER)
                Color.black
            }
            
            // Foreground
            VStack() {
                Spacer()
                    .frame(height:DIST_FROM_TOP_TO_DIVIDER - (IMAGE_DIAMETER / 2.0))
                if let unwrapped_other_user = other_user {
                    if let ui_image = profile_pic
                    {
                        Image(uiImage: ui_image)
                            .resizable()
                            .frame(width: IMAGE_DIAMETER, height: IMAGE_DIAMETER)
                            .foregroundColor(.white)
                            .clipShape(Circle())
                    } else {
                        Image(systemName: "person.crop.circle.fill")
                            .resizable()
                            .frame(width: IMAGE_DIAMETER, height: IMAGE_DIAMETER)
                            .foregroundColor(.white)
                    }
                } else {
                    PhotosPicker(selection: $selectedPickerItem, matching: .images) {
                        if let ui_image = profile_pic {
                            Image(uiImage: ui_image)
                                .resizable()
                                .frame(width: IMAGE_DIAMETER, height: IMAGE_DIAMETER)
                                .foregroundColor(.white)
                                .clipShape(Circle())
                        } else {
                            Image(systemName: "person.crop.circle.fill")
                                .resizable()
                                .frame(width: IMAGE_DIAMETER, height: IMAGE_DIAMETER)
                                .foregroundColor(.white)
                        }
                    }
                    .onChange(of: selectedPickerItem) { oldItem, newItem in
                        Task {
                            if let data = try? await newItem?.loadTransferable(type: Data.self) {
                                if var uiImage = UIImage(data: data) {
                                    if uiImage.size.width * uiImage.size.height > UserProfileViewModel.pixelLimit {
                                        let ratioTooLargeBy = (uiImage.size.width * uiImage.size.height) / UserProfileViewModel.pixelLimit
                                        let sideMultiplier = 1 / (ratioTooLargeBy.squareRoot())
                                        let targetSize = CGSize(width: floor(uiImage.size.width * sideMultiplier), height: floor(uiImage.size.height * sideMultiplier))
                                        let renderer = UIGraphicsImageRenderer(size: targetSize)
                                        uiImage = renderer.image {context in
                                            uiImage.draw(in: CGRect(origin: .zero, size: targetSize))
                                        }
                                    }
                                    
                                    print(data.base64EncodedString().count)
                                    if let jpegData = uiImage.jpegData(compressionQuality: 0) {
                                        userProfile.profilePic = uiImage
                                        
                                        //                              Send to DB
                                        print(jpegData.base64EncodedString().count)
                                        ContentView.webSocketManager.send(message: "{\"action\": \"addObjectDojoS3\", \"data_base_64_encoded_string\":\"\(jpegData.base64EncodedString())\", \"firebase_uid\":\"\(userProfile.firebase_uid)\", \"file_extension\":\".jpeg\"}")
                                    }
                                }
                            }
                        }
                    }
                }
                HStack {
                    Text(username)
//                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Spacer()
                    
                    if let unwrapped_other_user = other_user, !unwrapped_other_user.is_admin {
                        Button(action: {
                            if let other_user_having_feed = FeedModel.otherUserHavingFeed, let other_user_index = other_user_having_feed.otherUsers.firstIndex(where: { $0.firebase_uid == unwrapped_other_user.firebase_uid }) {
                                
                                var new_users = other_user_having_feed.otherUsers
                                var new_user = new_users[other_user_index]
                                new_user.we_follow_them = !unwrapped_other_user.we_follow_them
                                new_users[other_user_index] = new_user
                                other_user = new_user
                                other_user_having_feed.otherUsers = new_users
                                
                                if new_user.we_follow_them  {
                                    ContentView.webSocketManager.send(message: "{\"action\": \"AddFollow\", \"firebase_uid\": \"\(userProfile.firebase_uid)\", \"followed_uid\":\"\(unwrapped_other_user.firebase_uid)\"}")
                                } else {
                                    ContentView.webSocketManager.send(message: "{\"action\": \"DeleteFollow\", \"firebase_uid\": \"\(userProfile.firebase_uid)\", \"followed_uid\":\"\(unwrapped_other_user.firebase_uid)\"}")
                                }
                            }
                        }) {
                            if (unwrapped_other_user.we_follow_them) {
                                Text("Unfollow")
                            } else {
                                Text("Follow")
                            }
                        }
                    }
                }.padding()
                HStack {
                    if (other_user != nil && !other_user!.is_admin) || other_user == nil {
                        NavigationLink {
                            if let unwrapped_other_user = other_user {
                                ProfileListView(
                                    hide_hamburger: $hide_hamburger,
                                    hamburger_action: hamburger_action,
                                    search_text: $search_text,
                                    userProfile: userProfile,
                                    profilesViewModel: FollowersModel(
                                        user_profile: userProfile,
                                        feed_key: unwrapped_other_user.firebase_uid,
                                        followed_uid: unwrapped_other_user.firebase_uid,
                                        search_text: search_text
                                    )
                                )
                            } else {
                                ProfileListView(
                                    hide_hamburger: $hide_hamburger,
                                    hamburger_action: hamburger_action,
                                    search_text: $search_text,
                                    userProfile: userProfile,
                                    profilesViewModel: FollowersModel(
                                        user_profile: userProfile,
                                        feed_key: userProfile.firebase_uid,
                                        followed_uid: userProfile.firebase_uid,
                                        search_text: search_text
                                    )
                                )
                            }
                        } label: {
                            if let unwrapped_other_user = other_user {
                                Text("\(unwrapped_other_user.followers_count) followers")
                            } else {
                                Text("\(userProfile.followers_count) followers")
                            }
                        }
                        .buttonStyle(.plain)
                        NavigationLink {
                            if let unwrapped_other_user = other_user {
                                ProfileListView(
                                    hide_hamburger: $hide_hamburger,
                                    hamburger_action: hamburger_action,
                                    search_text: $search_text,
                                    userProfile: userProfile,
                                    profilesViewModel: FollowedModel(
                                        user_profile: userProfile,
                                        feed_key: unwrapped_other_user.firebase_uid,
                                        follower_uid: unwrapped_other_user.firebase_uid,
                                        search_text: search_text
                                    )
                                )
                            } else {
                                ProfileListView(
                                    hide_hamburger: $hide_hamburger,
                                    hamburger_action: hamburger_action,
                                    search_text: $search_text,
                                    userProfile: userProfile,
                                    profilesViewModel: FollowedModel(
                                        user_profile: userProfile,
                                        feed_key: userProfile.firebase_uid,
                                        follower_uid: userProfile.firebase_uid,
                                        search_text: search_text
                                    )
                                )
                            }
                        } label: {
                            if let unwrapped_other_user = other_user {
                                Text("\(unwrapped_other_user.followed_count) following")
                            } else {
                                Text("\(userProfile.followed_count) following")
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
                Divider()
                FeedView(
                    hide_hamburger: $hide_hamburger,
                    hamburger_action: hamburger_action,
                    search_text: $search_text,
                    userProfile: userProfile,
                    postsViewModel: feed)
                Spacer()
            }
            
            //                 Floating + (create post) button
            AddPostButton(
                preceding_post_id: nil,
                current_feed: feed,
                user_profile: userProfile
            )
        }
    }
}

struct ProfileSettingsView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var userProfile: UserProfileViewModel
    
    @State private var selectedPickerItem: PhotosPickerItem?
    
    var body: some View {
        NavigationView {
            VStack(spacing: 40) {
                Text("Profile Settings")
                    .font(.largeTitle)
                    .foregroundColor(.white)
                    .padding(.top, 20)
                
                // Profile Pic
                PhotosPicker(selection: $selectedPickerItem, matching: .images) {
                    if let profilePic = userProfile.profilePic {
                        Image(uiImage: profilePic)
                            .resizable()
                            .frame(width: 100, height: 100)
                            .foregroundColor(.white)
                            .clipShape(Circle())
                    } else {
                        Image(systemName: "person.crop.circle.fill")
                            .resizable()
                            .frame(width: 100, height: 100)
                            .foregroundColor(.white)
                    }
                }
                .onChange(of: selectedPickerItem) { oldItem, newItem in
                    Task {
                        if let data = try? await newItem?.loadTransferable(type: Data.self) {
                            if var uiImage = UIImage(data: data) {
                                if uiImage.size.width * uiImage.size.height > UserProfileViewModel.pixelLimit {
                                    let ratioTooLargeBy = (uiImage.size.width * uiImage.size.height) / UserProfileViewModel.pixelLimit
                                    let sideMultiplier = 1 / (ratioTooLargeBy.squareRoot())
                                    let targetSize = CGSize(width: floor(uiImage.size.width * sideMultiplier), height: floor(uiImage.size.height * sideMultiplier))
                                    let renderer = UIGraphicsImageRenderer(size: targetSize)
                                    uiImage = renderer.image {context in
                                        uiImage.draw(in: CGRect(origin: .zero, size: targetSize))
                                    }
                                }
                                
                                print(data.base64EncodedString().count)
                                if let jpegData = uiImage.jpegData(compressionQuality: 0) {
                                    userProfile.profilePic = uiImage
                                    
    //                              Send to DB
                                    print(jpegData.base64EncodedString().count)
                                    ContentView.webSocketManager.send(message: "{\"action\": \"addObjectDojoS3\", \"data_base_64_encoded_string\":\"\(jpegData.base64EncodedString())\", \"firebase_uid\":\"\(userProfile.firebase_uid)\", \"file_extension\":\".jpeg\"}")
                                }
                            }
                        }
                    }
                }
                
                // Name & Email
                VStack(alignment: .leading, spacing: 10) {
                    Text("Name").foregroundColor(.gray)
                    Text(userProfile.username)
//                    TextField("Name", text: $userProfile.username)
//                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    Text("Email").foregroundColor(.gray)
                    Text(userProfile.email)
//                    TextField("Email", text: $userProfile.email)
//                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                .frame(maxWidth: .infinity)
//                .padding(.horizontal)
                
                // The mock Apple Pay button:
                MockApplePayButton()
                    .frame(width: 200, height: 44) // approximate size
                
                Spacer()
                
                // Dismiss button
                Button("Done") {
                    presentationMode.wrappedValue.dismiss()
                }
                .foregroundColor(.blue)
                .padding(.bottom, 50)
                
            }
            .padding()
            .background(Color.black)
            .navigationBarHidden(true)
        }
        .preferredColorScheme(.dark)
    }
}

// MARK: - ProfilesViewModel

// DO NOT INSTANTIATE
class ProfilesViewAbstractModel: ObservableObject {
    @Published var noMoreUsers = false

    // Data
    @Published var user_uids: [User_UID] = []
    
    let user_profile: UserProfileViewModel
    
    init(user_profile: UserProfileViewModel) {
        self.user_profile = user_profile
    }
}
protocol ProfilesViewProtocol: ProfilesViewAbstractModel {
    associatedtype T: ProfilesViewProtocol
    
    var feed_key: String { get set }
    var search_text: String { get set }
    static var feeds: [String: T] { get set }
    
    var N: Int { get }
    
    func refreshUsers()
    func fetchNewUsers()
}
extension ProfilesViewProtocol {
    // Num posts to get at time
    var N: Int { return 20 }
}

class FollowersModel: ProfilesViewAbstractModel, ProfilesViewProtocol {
    var feed_key: String
    var followed_uid: String
    var search_text: String
    
    typealias T = FollowersModel
    
    static var feeds: [String: T] = [:]
    
    init(user_profile: UserProfileViewModel, feed_key: String, followed_uid: String, @State search_text: String) {
        self.feed_key = feed_key
        self.followed_uid = followed_uid
        self.search_text = search_text
        super.init(user_profile: user_profile)
        
        if let feed = T.feeds[feed_key], feed.search_text == search_text {
            self.user_uids = feed.user_uids
        } else {
            fetchNewUsers()
        }
        T.feeds[feed_key] = self
    }
    
    func refreshUsers() {
        ContentView.webSocketManager.send(message: "{\"action\": \"getNConsecutiveUserIDs\", \"message_type\":\"refreshFollowersView\", \"feed_key\": \"\(feed_key)\", \"N\":\(N), \"start\":\(0), \"where_clause\": \"WHERE EXISTS(SELECT 1 FROM follows WHERE follows.follower_uid = u.firebase_uid AND follows.followed_uid = '\(followed_uid)') AND u.username ILIKE '%\(search_text)%'\"}")
    }
    func fetchNewUsers() {
        ContentView.webSocketManager.send(message: "{\"action\": \"getNConsecutiveUserIDs\", \"message_type\":\"addFollowersView\", \"feed_key\": \"\(feed_key)\", \"N\":\(N), \"start\":\(user_uids.count), \"where_clause\": \"WHERE EXISTS(SELECT 1 FROM follows WHERE follows.follower_uid = u.firebase_uid AND follows.followed_uid = '\(followed_uid)') AND u.username ILIKE '%\(search_text)%'\"}")
    }
}
class FollowedModel: ProfilesViewAbstractModel, ProfilesViewProtocol {
    var feed_key: String
    var follower_uid: String
    var search_text: String
    
    typealias T = FollowedModel
    
    static var feeds: [String: T] = [:]
    
    init(user_profile: UserProfileViewModel, feed_key: String, follower_uid: String, @State search_text: String) {
        self.feed_key = feed_key
        self.follower_uid = follower_uid
        self.search_text = search_text
        super.init(user_profile: user_profile)
        
        if let feed = T.feeds[feed_key], feed.search_text == search_text {
            self.user_uids = feed.user_uids
        } else {
            fetchNewUsers()
        }
        T.feeds[feed_key] = self
    }
    
    func refreshUsers() {
        ContentView.webSocketManager.send(message: "{\"action\": \"getNConsecutiveUserIDs\", \"message_type\":\"refreshFollowedView\", \"feed_key\": \"\(feed_key)\", \"N\":\(N), \"start\":\(0), \"where_clause\": \"WHERE EXISTS(SELECT 1 FROM follows WHERE follows.followed_uid = u.firebase_uid AND follows.follower_uid = '\(follower_uid)') AND u.username ILIKE '%\(search_text)%'\"}")
    }
    func fetchNewUsers() {
        ContentView.webSocketManager.send(message: "{\"action\": \"getNConsecutiveUserIDs\", \"message_type\":\"addFollowedView\", \"feed_key\": \"\(feed_key)\", \"N\":\(N), \"start\":\(user_uids.count), \"where_clause\": \"WHERE EXISTS(SELECT 1 FROM follows WHERE follows.followed_uid = u.firebase_uid AND follows.follower_uid = '\(follower_uid)') AND u.username ILIKE '%\(search_text)%'\"}")
    }
}
class SearchedProfilesModel: ProfilesViewAbstractModel, ProfilesViewProtocol {
    var feed_key: String
    var search_text: String
    
    typealias T = SearchedProfilesModel
    
    static var feeds: [String: T] = [:]
    
    init(user_profile: UserProfileViewModel, feed_key: String, @State search_text: String) {
        self.feed_key = feed_key
        self.search_text = search_text
        super.init(user_profile: user_profile)
        
        if let feed = T.feeds[feed_key], feed.search_text == search_text {
            self.user_uids = feed.user_uids
        } else {
            fetchNewUsers()
        }
        T.feeds[feed_key] = self
    }
    
    func refreshUsers() {
        if search_text != "" {
            ContentView.webSocketManager.send(message: "{\"action\": \"getNConsecutiveUserIDs\", \"message_type\":\"refreshSearchedProfilesView\", \"feed_key\": \"\(feed_key)\", \"N\":\(N), \"start\":\(0), \"where_clause\": \"WHERE u.username ILIKE '%\(search_text)%'\"}")
        }
    }
    func fetchNewUsers() {
        if search_text != "" {
            ContentView.webSocketManager.send(message: "{\"action\": \"getNConsecutiveUserIDs\", \"message_type\":\"addSearchedProfilesView\", \"feed_key\": \"\(feed_key)\", \"N\":\(N), \"start\":\(user_uids.count), \"where_clause\": \"WHERE u.username ILIKE '%\(search_text)%'\"}")
        }
    }
}
