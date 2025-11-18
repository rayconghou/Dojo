//
//  ContentView.swift
//  Dojo
//
//  Created by Raymond Hou on 2/28/25.
//

import SwiftUI
import Combine
import FirebaseAuth
// import AWSSQS // Temporarily disabled

// MARK: - Font Utilities
extension Font {
    static func satoshiBlack(size: CGFloat) -> Font {
        return .custom("Satoshi-Black", size: size)
    }
    
    static func satoshiBold(size: CGFloat) -> Font {
        return .custom("Satoshi-Bold", size: size)
    }
    
    static func satoshiMedium(size: CGFloat) -> Font {
        return .custom("Satoshi-Medium", size: size)
    }
    
    static func satoshiRegular(size: CGFloat) -> Font {
        return .custom("Satoshi-Regular", size: size)
    }
    
    static func lastShuriken(size: CGFloat) -> Font {
        return .custom("The Last Shuriken", size: size)
    }
}

// MARK: - Main ContentView with Splash Screen

enum ContentError: Error {
    case liesAboutHavingUserProfile
}

struct ContentView: View {
    @ObservedObject var authManager: AuthManager
    
    init () {
        authManager = AuthManager.shared
    }
    
    @State private var hideSplash = false
    @State private var showDojo = false
    @State private var showLogo = false
    @State private var showBottomElements = false
    @State private var isSignedIn = false
    @StateObject static var securityViewModel = SecureSignInFlowViewModel()
    @State static var webSocketManager: WebSocketManager = WebSocketManager()
    
    var body: some View {
        ZStack {
            Group {
                if authManager.isLoggedIn {
                    if authManager.hasUserProfile {
                        if let userProfile = authManager.userProfile {
                            SecureSignInFlowView(userProfile: userProfile)
                                .environmentObject(ContentView.securityViewModel)
                        }
                    } else {
                        // Loading state - will be replaced by mock profile after splash
                        VStack(spacing: 20) {
                            ProgressView()
                                .scaleEffect(1.5)
                                .tint(.white)
                            Text("Loading...")
                                .foregroundColor(.white)
                                .padding(.top, 20)
                            
                            Text("Frontend Development Mode")
                                .font(.caption)
                                .foregroundColor(.gray)
                                .padding(.top, 5)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.black)
                    }
                } else {
                    // Fallback to AuthView with debug info
                    VStack {
                        // TEMP
//                        AuthView()
                        
                        // Debug info
                        VStack {
                            Text("Debug Info:")
                                .font(.caption)
                                .foregroundColor(.gray)
                            Text("isLoggedIn: \(authManager.isLoggedIn ? "true" : "false")")
                                .font(.caption)
                                .foregroundColor(.gray)
                            Text("hideSplash: \(hideSplash ? "true" : "false")")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        .padding()
                    }
                }
            }
            .zIndex(0)
            
            splashScreen
                .opacity(hideSplash ? 0 : 1)
        }
        .ignoresSafeArea()
        .onAppear {
            showDojo = true
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                showLogo = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                showBottomElements = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                withAnimation { hideSplash = true }
                
                // MOCK: Create user profile for frontend development
                if authViewModel.isLoggedIn && AuthManager.shared.userProfile == nil {
                    AuthManager.shared.userProfile = UserProfileViewModel(
                        email: Auth.auth().currentUser?.email ?? "demo@example.com",
                        username: "Demo User"
                    )
                }
            }
        }
    }
    
    
    var splashScreen: some View {
        ZStack {
            // Custom background color #050715
            Color(hex: "050715")
                .edgesIgnoringSafeArea(.all)
            
            // NormalSplashBackground asset overlay
            Image("NormalSplashBackground")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 40) {
                // DOJO Logo and Text from SplashScreenBranding asset
                Image("SplashScreenBranding")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 250, height: 250)
                
            }
            .padding(.vertical, 50)
        }
        .onAppear {
            // No animations - just show immediately
        }
    }
    
//    func checkAuthState() {
//        if let user = Auth.auth().currentUser {
//            print("User is signed in as: \(user.email ?? "")")
//            isSignedIn = true
//        } else {
//            print("User is not signed in.")
//            isSignedIn = false
//        }
//    }

}




// MARK: - Preview
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

// MARK: - DOJO Splash Preview
struct DojoSplashPreview: View {
    @State private var showDojo = false
    
    var body: some View {
        ZStack {
            Color(hex: "050715")
                .edgesIgnoringSafeArea(.all)
            
            // NormalSplashBackground asset overlay
            Image("NormalSplashBackground")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 40) {
                // DOJO Logo and Text from SplashScreenBranding asset
                Image("SplashScreenBranding")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 250, height: 250)
            }
        }
        .onAppear {
            // No animations - just show immediately
        }
    }
}

#Preview("DOJO Splash") {
    DojoSplashPreview()
}
