//
//  FeedView.swift
//  Dojo
//
//  Created by Hugh on 10/30/25.
//

import SwiftUI

struct FeedView<T: PostsViewAbstractModel & PostsViewProtocol>: View {
    
    @Binding var hide_hamburger: Bool
    var hamburger_action: () -> Void
    @Binding var search_text: String
    @State private var scrollOffset: CGFloat = 0
    @State private var showCreatePostModal = false
    @State private var searchText = ""
    @State private var show_add_post_button = true
    @State var show_search_bar: Bool = false
    @ObservedObject var userProfile: UserProfileViewModel
    @ObservedObject var postsViewModel: T
    
    // Sorted and filtered coins based on selected option and search text
    var posts: [Post] {
        return postsViewModel.posts
        
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
            if show_search_bar {
                // TEMP: need to incorporate search_text
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    
                    TextField("Search posts", text: $searchText)
                        .foregroundColor(.white)
                    
                    if !searchText.isEmpty {
                        Button(action: {
                            searchText = ""
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
            }
            
            // List of posts in a scrollable view
            ScrollView {
                LazyVStack(spacing: 16) {
                    ForEach(posts) { post in
                        //                            CryptoTrendCard(
                        //                                rank: coin.market_cap_rank ?? 0,
                        //                                name: coin.name,
                        //                                symbol: coin.symbol,
                        //                                imageUrl: coin.image,
                        //                                price: coin.current_price,
                        //                                change: coin.price_change_percentage_24h ?? 0,
                        //                                sparkline: coin.sparkline_in_7d?.price.last24Hours ?? coin.sparkline_in_7d?.price ?? []
                        //                            )
                        if userProfile.firebase_uid == post.poster_uid {
                            PostCard(
                                post: post,
                                userProfile: userProfile,
                                other_user: nil,
                                search_text: $search_text,
                                likes_count: post.likes_count,
                                we_liked_it: false,
                                can_navigate_to_profile: !(postsViewModel is ProfileFeedModel),
                                hide_hamburger: $hide_hamburger,
                                hamburger_action: hamburger_action
                            )
                        } else if let other_user_having_feed = FeedModel.otherUserHavingFeed, let other_user = other_user_having_feed.otherUsers.first(where: { $0.firebase_uid == post.poster_uid }) {
                            PostCard(
                                post: post,
                                userProfile: userProfile,
                                other_user: other_user,
                                search_text: $search_text,
                                likes_count: post.likes_count,
                                we_liked_it: post.we_liked_it,
                                can_navigate_to_profile: !(postsViewModel is ProfileFeedModel),
                                hide_hamburger: $hide_hamburger,
                                hamburger_action: hamburger_action
                            )
                        } else {
                            Text("LOADING")
                        }
                    }
                    if (!postsViewModel.noMorePosts && posts.count >= postsViewModel.N) {
                        LoadingView().onAppear(perform: {
                            print("Fetching new posts...")
                            postsViewModel.fetchNewPosts()
                        })
                    }
                }
                .padding()
            }
            .refreshable {
                postsViewModel.refreshPosts()
            }
        }
        .background(Color.black.edgesIgnoringSafeArea(.all))
    }
}

//// Helper extension to extract the last 24 hours worth of sparkline data.
//// Assumes the sparkline contains at least 24 points; otherwise returns the full array.
//extension Array where Element == Double {
//    var last24Hours: [Double] {
//        if self.count >= 24 {
//            return Array(self.suffix(24))
//        } else {
//            return self
//        }
//    }
//}
//
//struct OffsetPreferenceKey: PreferenceKey {
//    static var defaultValue: CGFloat = 0
//    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
//        value = nextValue()
//    }
//}

// Preview (make sure to bind hideHamburger to a constant for previewing)
struct FeedView_Previews: PreviewProvider {
    @State static var hide_hamburger = false
    @State static var user_profile = UserProfileViewModel(firebase_uid: "test_uid", email: "test@gmail.com", username: "test")
    @State static var posts_view_model = Dojo.FeedModel(
        user_profile: user_profile,
        feed_key: "main"
     )
    @State static var search_text = ""
    
    static var previews: some View {
        NavigationStack {
            FeedView(hide_hamburger: $hide_hamburger,
                     hamburger_action: {},
                     search_text: $search_text,
                     userProfile: user_profile,
                     postsViewModel: posts_view_model
            )
            .preferredColorScheme(.dark)
        }
        .onAppear(perform: {
            FeedModel.otherUserHavingFeed = posts_view_model
        })
    }
}
