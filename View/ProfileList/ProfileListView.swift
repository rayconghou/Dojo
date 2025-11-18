//
//  ProfileListView.swift
//  Dojo
//
//  Created by Hugh on 11/10/25.
//

import SwiftUI

struct ProfileListView<T: ProfilesViewAbstractModel & ProfilesViewProtocol>: View {
    
    @Binding var hide_hamburger: Bool
    var hamburger_action: () -> Void
    @State var last_time_text_changed: Date = Date.now
    @State var search_text_now: String = ""
    @State private var scrollOffset: CGFloat = 0
    @Binding var search_text: String
    @ObservedObject var userProfile: UserProfileViewModel
    @ObservedObject var profilesViewModel: T
    
    var user_uids: [User_UID] {
        return profilesViewModel.user_uids
        
//        let sorted = PostsViewModel.feed.posts.sorted() { $0.created_at > $1.created_at
//        }
//
//        return sorted
        
//        TEMP: Will be useful for user posts
//        if searchText.isEmpty {
//            return sorted
//        } else {
//            return sorted.filter {
//                $0.name.localizedCaseInsensitiveContains(searchText) ||
//                $0.symbol.localizedCaseInsensitiveContains(searchText)
//            }
//        }
    }
    
    struct LoadingView: UIViewRepresentable {
        func makeUIView(context: Context) -> UIActivityIndicatorView {
            let spinner = UIActivityIndicatorView()
            spinner.startAnimating()
            return spinner
        }
        
        func updateUIView(_ uiView: UIActivityIndicatorView, context: Context) { }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Search Bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                
                TextField("Search posts", text: $search_text_now)
                    .foregroundColor(.white)
                    .onChange(of: search_text_now) { old_search_text_now, new_search_text_now in
                        DispatchQueue.main.asyncAfter(deadline: .now() + Constants.typing_wait_time) {
                            if Date.now.timeIntervalSinceReferenceDate - last_time_text_changed.timeIntervalSinceReferenceDate > TimeInterval(Constants.typing_wait_time) {
                                search_text = new_search_text_now
                            }
                        }
                        last_time_text_changed = Date.now
                    }
                
                if !search_text_now.isEmpty {
                    Button(action: {
                        search_text_now = ""
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                    }
                }
            }
            .padding(.vertical, 10)
            .padding(.horizontal)
            .background(Color.clear)
            .cornerRadius(10)
            .onAppear(perform: {
                search_text = ""
            })
            
            // List of posts in a scrollable view
            ScrollView {
                LazyVStack(spacing: 16) {
                    ForEach(user_uids) { user_uid in
                        if userProfile.firebase_uid == user_uid.firebase_uid {
                            ProfileCard(
                                user_profile: userProfile,
                                search_text: $search_text,
                                other_user: nil,
                                hide_hamburger: $hide_hamburger,
                                hamburger_action: hamburger_action
                            )
                        } else if let other_user_having_feed = FeedModel.otherUserHavingFeed, let other_user = other_user_having_feed.otherUsers.first(where: { $0.firebase_uid == user_uid.firebase_uid }) {
                            ProfileCard(
                                user_profile: userProfile,
                                search_text: $search_text,
                                other_user: other_user,
                                hide_hamburger: $hide_hamburger,
                                hamburger_action: hamburger_action
                            )
                        } else {
                            Text("LOADING")
                        }
                    }
                    if (!profilesViewModel.noMoreUsers && user_uids.count >= profilesViewModel.N) {
                        LoadingView().onAppear(perform: {
                            print("Fetching new users...")
                            profilesViewModel.fetchNewUsers()
                        })
                    }
                }
                .padding()
            }
            .refreshable {
                profilesViewModel.refreshUsers()
            }
        }
        .background(Color.black.edgesIgnoringSafeArea(.all))
    }
}

