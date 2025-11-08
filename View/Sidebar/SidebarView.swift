import SwiftUI

// MARK: - Sidebar with Extra Options

struct SidebarView: View {
    @Binding var showSidebar: Bool
    @Binding var showDegenMode: Bool
    @Binding var selectedTab: Int
    @State private var showManekiIntro = false
    @State private var showChatroom = false
    @State private var showMarketNews = false
    @State private var showSettings = false
    @State private var showNotifications = false
    @State private var showProfileSettings = false
    @State private var isDegenSplashActive = false
    @State private var hideSplashScreen = false
    @ObservedObject var userProfile: UserProfileViewModel
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                
                // Close Button
                HStack {
                    Button(action: { withAnimation { showSidebar.toggle() } }) {
                        Image(systemName: "xmark")
                            .resizable()
                            .frame(width: 20, height: 20)
                            .foregroundColor(.white)
                            .padding(.leading, 25)
                    }
                    Spacer()
                }
                
                // Profile Row
                Button(action: {
                    showProfileSettings = true
                }) {
                    HStack(spacing: 15) {
                        if let profilePic = userProfile.profilePic {
                            Image(uiImage: profilePic)
                                .resizable()
                                .frame(width: 50, height: 50)
                                .foregroundColor(.white)
                                .clipShape(Circle())
                        } else {
                            Image(systemName: "person.crop.circle.fill")
                                .resizable()
                                .frame(width: 50, height: 50)
                                .foregroundColor(.white)
                        }
                        VStack(alignment: .leading, spacing: 4) {
                            Text(userProfile.username)
                                .font(.custom("Inter", size: 20))
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            Text(userProfile.email)
                                .font(.custom("Inter", size: 14))
                                .foregroundColor(.gray)
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                            .padding(.trailing, 35)
                            .foregroundColor(.white)
                    }
                    .padding(.leading, 20)
                }
                .sheet(isPresented: $showProfileSettings) {
//                    ProfileSettingsView(userProfile: userProfile)
                    ProfileView(userProfile: userProfile)
                }
                
                Divider()
                    .frame(height: 1)
                    .background(Color.white)
                    .padding(.horizontal, 30)
                
                // Degen Mode Toggle
                HStack {
                    Image(systemName: "flame.fill")
                    Text("Degen Mode")
                        .font(.custom("Inter", size: 18))
                    Spacer()
                    Toggle("", isOn: Binding(
                        get: { showDegenMode },
                        set: { newValue in
                            if newValue {
                                activateDegenSplash()
                            } else {
                                // Existing logic for turning off Degen Mode
                                showDegenMode = false
                            }
                        }
                    ))
                    .toggleStyle(SwitchToggleStyle(tint: .orange))
                }
                .padding(.horizontal, 30)
                .foregroundColor(.white)

                // Maneki Guide Button
                Button(action: { showManekiIntro = true }) {
                    HStack {
                        Image(systemName: "cat.fill")
                        Text("Maneki Guide")
                            .font(.custom("Inter", size: 18))
                    }
                    .padding(.horizontal, 30)
                    .foregroundColor(.white)
                }
                .sheet(isPresented: $showManekiIntro) {
                    ManekiIntroView(selectedTab: $selectedTab, showSidebar: $showSidebar)
                }
                
                // Chatroom
                Button(action: { showChatroom = true }) {
                    HStack {
                        Image(systemName: "bubble.left.and.bubble.right.fill")
                        Text("Chatroom")
                            .font(.custom("Inter", size: 18))
                    }
                    .padding(.horizontal, 30)
                    .foregroundColor(.white)
                }
                .sheet(isPresented: $showChatroom) {
                    ChatroomView()
                }
                
                // Community Hub
                NavigationLink(destination: CommunityHubView()) {
                    HStack {
                        Image(systemName: "person.3.fill")
                        Text("Community Hub")
                            .font(.custom("Inter", size: 18))
                    }
                    .padding(.horizontal, 30)
                    .foregroundColor(.white)
                }
                
                // Market News (New Sidebar Module)
                Button(action: { showMarketNews = true }) {
                    HStack {
                        Image(systemName: "newspaper.fill")
                        Text("Market News")
                            .font(.custom("Inter", size: 18))
                    }
                    .padding(.horizontal, 30)
                    .foregroundColor(.white)
                }
                .sheet(isPresented: $showMarketNews) {
                    MarketNewsView()
                }
                
                Divider()
                    .frame(height: 1)
                    .background(Color.white)
                    .padding(.horizontal, 30)
                
                // Settings & Notifications
                Button(action: { print("Settings button pressed") }) {
                    HStack {
                        Image(systemName: "gear")
                        Text("Settings")
                            .font(.custom("Inter", size: 18))
                    }
                    .padding(.horizontal, 30)
                    .foregroundColor(.white)
                }
                
                Button(action: { print("Notifications button pressed") }) {
                    HStack {
                        Image(systemName: "bell")
                        Text("Notifications")
                            .font(.custom("Inter", size: 18))
                    }
                    .padding(.horizontal, 30)
                    .foregroundColor(.white)
                }
                
                // Logout
                Button(action: {
                    AuthManager.shared.signOut()
                }) {
                    HStack {
                        Image(systemName: "power")
                        Text("Logout")
                            .font(.custom("Inter", size: 18))
                    }
                    .padding(.horizontal, 30)
                    .foregroundColor(.red)
                }
                
                Spacer()
            }
        }
        .background(Color.black)
        // .edgesIgnoringSafeArea(.all)
        // .frame(maxWidth: .infinity, maxHeight: .infinity)
        // .offset(x: showSidebar ? 0 : -UIScreen.main.bounds.width)
        // .animation(.easeInOut(duration: 0.3), value: showSidebar)
        // .zIndex(1)
    }
    
    // Activation method for Degen Splash Screen
    private func activateDegenSplash() {
        // Close sidebar silently in the background
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            showSidebar = false
        }
        
        // Activate splash screen
        isDegenSplashActive = true
        
        // Ensure Degen Mode is activated after a short delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            showDegenMode = true
        }
        
        // Automatically dismiss splash screen after animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            isDegenSplashActive = false
        }
    }

}

// MARK: - Market News Modal

struct MarketNewsView: View {
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Market News")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.horizontal)
                    
                    // News Cards displaying crypto and memecoin news
                    NewsCard(title: "Bitcoin Reaches New All-Time High", time: "2 hours ago")
                    NewsCard(title: "SEC Approves New Crypto ETF", time: "5 hours ago")
                    NewsCard(title: "Major Bank Adopts Blockchain Technology", time: "1 day ago")
                    
                    // Additional memecoin news can be added here
                }
                .padding(.vertical)
            }
            .background(Color.black.edgesIgnoringSafeArea(.all))
            .navigationTitle("Crypto News")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { presentationMode.wrappedValue.dismiss() }) {
                        Image(systemName: "xmark")
                            .foregroundColor(.white)
                    }
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}

// MARK: - Additional Views & Support Components

struct ManekiIntroView: View {
    @Binding var selectedTab: Int
    @Binding var showSidebar: Bool
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        ScrollView {
            VStack(spacing: 25) {
                HStack {
                    Spacer()
                    // Close Modal Button
                    Button(action: { presentationMode.wrappedValue.dismiss() }) {
                        Image(systemName: "xmark")
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.gray.opacity(0.2))
                            .clipShape(Circle())
                    }
                }
                .padding(.horizontal)

                Image(systemName: "cat.fill")
                    .resizable()
                    .frame(width: 80, height: 80)
                    .foregroundColor(.white)

                Text("Welcome to Maneki!")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)

                Text("Maneki is here to guide you through using Dojo. Ask questions about market trends, portfolio tips, or get crypto insights.")
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                Button(action: {
                    presentationMode.wrappedValue.dismiss()  // Close modal
                    showSidebar = false  // Close sidebar
                    selectedTab = 2  // Go to Maneki tab
                }) {
                    HStack {
                        Image(systemName: "arrow.right.circle.fill")
                            .font(.title2)
                        Text("Go to Maneki")
                            .font(.title2)
                            .fontWeight(.bold)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
                .padding(.horizontal, 30)

            }
            .padding()
        }
        .background(Color.black)
    }
}


struct CommunityHubView: View {
    var body: some View {
        VStack {
            Text("Community Hub")
                .font(.largeTitle)
                .foregroundColor(.white)
                .padding()
            Text("Connect with other crypto enthusiasts!")
                .foregroundColor(.gray)
            Spacer()
        }
        .background(Color.black)
    }
}


// MARK: - Preview

struct SidebarView_Previews: PreviewProvider {
    static var previews: some View {
        SidebarView(showSidebar: .constant(true),
                    showDegenMode: .constant(false),
                    selectedTab: .constant(0),
                    userProfile: UserProfileViewModel(firebase_uid: "0", email: "jameswang@example.com", username: "James Wang"))
            .preferredColorScheme(.dark)
    }
}
