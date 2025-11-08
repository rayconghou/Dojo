//
//  FeedView.swift
//  Dojo
//
//  Created by Hugh on 10/30/25.
//

import SwiftUI

struct FeedView<T: PostsViewAbstractModel & PostsViewProtocol>: View {
    
    @Binding var hideHamburger: Bool
    var hamburgerAction: () -> Void
    @State private var selectedPost: Post? = nil
    @State private var scrollOffset: CGFloat = 0
    @State private var showCreatePostModal = false
    @State private var searchText = ""
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
            
            // List of posts in a scrollable view
            ZStack {
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
                            if let userProfile = AuthManager.shared.userProfile, userProfile.firebase_uid == post.poster_uid {
                                PostCard(post: post, username: userProfile.username, profilePic: userProfile.profilePic, likes_count: post.likes_count, we_liked_it: false, selectedPost: $selectedPost
                                    )
                            } else if let otherUser = FeedModel.otherUserHavingFeed.otherUsers.first(where: { $0.firebase_uid == post.poster_uid }) {
                                if let profilePicData = otherUser.profilePic {
                                    PostCard(post: post, username: otherUser.username, profilePic: UIImage(data: profilePicData), likes_count: post.likes_count, we_liked_it: post.we_liked_it, selectedPost: $selectedPost)
                                } else {
                                    PostCard(post: post, username: otherUser.username, profilePic: nil, likes_count: post.likes_count, we_liked_it: post.we_liked_it, selectedPost: $selectedPost)
                                }
                            } else {
                                Text("LOADING")
                            }
                            
                            // MAKE PostCard IN PostsFetcher?
                        }
                        if (!postsViewModel.noMorePosts) {
                            LoadingView().onAppear(perform: {
                                postsViewModel.fetchNewPosts()
                            })
                        }
                    }
                    .padding()
                }
                .refreshable {
                    postsViewModel.refreshPosts()
                }
                
//                TEMP: Make this into a "+" post button
//                 Floating + (create post) button
                VStack() {
                    Spacer()
                    
                    HStack() {
                        Spacer()
                        
                        Button(action: { showCreatePostModal = true }) {
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
                    .sheet(isPresented: $showCreatePostModal) {
                        CreatePostView(userProfile: userProfile)
                    }
                }
            }
            .background(Color.black.edgesIgnoringSafeArea(/*@START_MENU_TOKEN@*/.all/*@END_MENU_TOKEN@*/))
        }
        .background(Color.black.edgesIgnoringSafeArea(.all))
        .sheet(item: $selectedPost) { post in
//            TEMP: Add post view
//            CoinDetailModalView(coin: coin, marketVM: marketVM)
        }
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
    @State static var hideHamburger = false
    static var previews: some View {
        FeedView(hideHamburger: $hideHamburger,
                 hamburgerAction: {},
                 userProfile: UserProfileViewModel(firebase_uid: "test_uid", email: "test@gmail.com", username: "test"),
                 postsViewModel: FeedModel.otherUserHavingFeed
        )
        .preferredColorScheme(.dark)
    }
}
