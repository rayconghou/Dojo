//
//  CreatePostView.swift
//  Dojo
//
//  Created by Hugh on 11/3/25.
//

import SwiftUI

struct CreatePostView<T: PostsViewAbstractModel & PostsViewProtocol>: View {
    @Environment(\.dismiss) var dismiss
    
    let CHAR_LIMIT = 280
    
    let preceding_post_id: Int?
    let current_feed: T
    
    @State private var post_text = ""
    @ObservedObject var user_profile: UserProfileViewModel
    
    var body: some View {
        VStack {
            Spacer()
                .frame(height: 30)
            HStack (spacing: 10) {
                Spacer()
                    .frame(width: 10)
                VStack {
                    if let profile_pic = user_profile.profilePic {
                        Image(uiImage: profile_pic)
                            .resizable()
                            .frame(width: 40, height: 40)
                            .foregroundColor(.white)
                            .clipShape(Circle())
                    } else {
                        Image(systemName: "person.crop.circle.fill")
                            .resizable()
                            .frame(width: 40, height: 40)
                            .foregroundColor(.white)
                    }
                    Spacer()
                }
                // TEMP: Add placeholder text
                TextEditor(text: $post_text)
                    .keyboardType(.twitter)
                    .onChange(of: post_text) { old_text, new_text in
                        if new_text.count > CHAR_LIMIT {
                            post_text = old_text
                        }
                    }
            }
            Spacer()
            Button(action: {
                if let unwrapped_preceding_post_id = preceding_post_id {
                    ContentView.webSocketManager.send(message: "{\"action\": \"addPost\", \"poster_uid\":\"\(user_profile.firebase_uid)\",\"preceding_post_id\": \(unwrapped_preceding_post_id),\"text\":\"\(post_text)\"}")
                } else {
                    ContentView.webSocketManager.send(message: "{\"action\": \"addPost\", \"poster_uid\":\"\(user_profile.firebase_uid)\",\"preceding_post_id\": null,\"text\":\"\(post_text)\"}")
                }
                // Refresh after some time has passed
                // TEMP: temp? TO DO, make it where local pseudo-post is created (ANNOYING)
                DispatchQueue.main.asyncAfter(deadline: .now() + 5, execute: {
                    current_feed.refreshPosts()
                })
                dismiss()
            }) {
                if preceding_post_id != nil {
                    Text("Reply")
                        .font(.system(size: 40))
                } else {
                    Text("Post")
                        .font(.system(size: 40))
                }
            }
            Spacer()
                .frame(height: 60)
        }
//        TEMP: Figure out how to fix software keyboard view
//        .toolbar {
//            ToolbarItem(placement: .keyboard) {
//                
//            }
//        }
        .edgesIgnoringSafeArea(.all)
    }
}
