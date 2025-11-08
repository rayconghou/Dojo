//
//  CreatePostView.swift
//  Dojo
//
//  Created by Hugh on 11/3/25.
//

import SwiftUI

struct CreatePostView: View {
    @Environment(\.dismiss) var dismiss
    
    @State private var post_text = ""
    @ObservedObject var userProfile: UserProfileViewModel
    
    var body: some View {
        VStack {
            Spacer()
                .frame(height: 30)
            HStack (spacing: 10) {
                Spacer()
                    .frame(width: 10)
                if let profilePic = userProfile.profilePic {
                    Image(uiImage: profilePic)
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
                TextField("Speak your mind", text: $post_text)
                    .keyboardType(.twitter)
            }
            Spacer()
            Button(action: {
                ContentView.webSocketManager.send(message: "{\"action\": \"addPost\", \"poster_uid\":\"\(userProfile.firebase_uid)\",\"preceding_post_id\": null,\"text\":\"\(post_text)\"}")
                dismiss()
            }) {
                Text("Post")
                    .font(.system(size: 40))
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
