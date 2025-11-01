//
//  UserProfile.swift
//  Dojo
//
//  Created by Raymond Hou on 3/13/25.
//

import Foundation
import SwiftUI
import PhotosUI

// MARK: - Profile Modal

class UserProfileViewModel: ObservableObject {
    var firebase_uid: String
    @Published var username: String
    @Published var email: String
    @Published var profilePic: UIImage?
    
    static let pixelLimit: Double = 1000
    
    init(firebase_uid: String = "0", email: String = "james@example.com", username: String = "James Wang") {
        self.firebase_uid = firebase_uid
        self.username = username
        self.email = email
        
        if profilePic == nil {
            if let profilePic = AuthManager.shared.profilePic {
                self.profilePic = profilePic
            }
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
