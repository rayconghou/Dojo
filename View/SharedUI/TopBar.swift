//
//  TopBar.swift
//  Dojo
//
//  Created by Raymond Hou on 3/11/25.
//  Top navigation bar with profile, search, notifications, and menu
//

import SwiftUI

struct TopBar: View {
    @Binding var searchText: String
    let onHamburgerTap: () -> Void
    let onNotificationTap: () -> Void
    let onProfileTap: () -> Void
    
    @State private var showSearch = false
    @State private var showEditProfile = false
    
    var body: some View {
        HStack(spacing: 12) {
            // Profile Picture
            Button(action: {
                showEditProfile = true
            }) {
                Image("Profile")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 40, height: 40)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                    )
            }
            
            // Search Bar
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color(red: 0.2, green: 0.5, blue: 1.0),      // Bright blue
                                Color(red: 0.1, green: 0.3, blue: 0.8)       // Darker blue
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .font(.system(size: 16, weight: .medium))
                
                TextField("Search", text: $searchText)
                    .font(.custom("Satoshi-Black", size: 16))
                    .foregroundColor(.white)
                    .onTapGesture {
                        showSearch = true
                    }
                
                if !searchText.isEmpty {
                    Button(action: {
                        searchText = ""
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                            .font(.system(size: 16))
                    }
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(hex: "1F212F"))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                    )
            )
            .onTapGesture {
                showSearch = true
            }
            
            // Notification Bell
            Button(action: onNotificationTap) {
                ZStack {
                    Image(systemName: "bell")
                        .foregroundColor(.white)
                        .font(.system(size: 20, weight: .medium))
                    
                    // Notification badge
                    Circle()
                        .fill(Color.red)
                        .frame(width: 8, height: 8)
                        .offset(x: 6, y: -6)
                }
            }
            
            // Hamburger Menu
            Button(action: onHamburgerTap) {
                VStack(spacing: 3) {
                    Rectangle()
                        .fill(Color.white)
                        .frame(width: 18, height: 2)
                    Rectangle()
                        .fill(Color.white)
                        .frame(width: 18, height: 2)
                    Rectangle()
                        .fill(Color.white)
                        .frame(width: 18, height: 2)
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(Color(hex: "050715"))
        .sheet(isPresented: $showEditProfile) {
            EditProfileView(isPresented: $showEditProfile)
        }
    }
}

// Preview
struct TopBar_Previews: PreviewProvider {
    @State static var searchText = ""
    
    static var previews: some View {
        VStack {
            TopBar(
                searchText: $searchText,
                onHamburgerTap: { print("Hamburger tapped") },
                onNotificationTap: { print("Notification tapped") },
                onProfileTap: { print("Profile tapped") }
            )
            Spacer()
        }
        .background(Color.black)
        .preferredColorScheme(.dark)
    }
}
