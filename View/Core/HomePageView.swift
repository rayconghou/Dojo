import Foundation
import SwiftUI

struct HomePageView: View {
    @State private var showSidebar = false
    @State private var hideHamburger = false
    @State private var showDegenMode = false
    @State private var showDegenExitConfirmation = false
    @State private var showDegenEntryWarning = false // New state for entry warning
    @State private var degenEntryTabTag = 98
    @State private var degenExitTabTag = 99
    @State private var showManekiButton = true
    @State private var hideSplashScreen = false
    @State private var isDegenSplashActive = false
    @State private var isExitingSplashActive = false
    @State private var showDojo = false
    @State private var showLogo = false
    @State private var showBottomElements = false
    @State private var search_text = ""
    @State private var showToolbar = true // New state for toolbar visibility
    @State private var userProfile: UserProfileViewModel
    @StateObject private var tradingWalletViewModel = TradingWalletViewModel()
    @State private var selectedTab: Int = 0
    
    // Enum to represent different app modes
    enum AppMode {
        case standard
        case degen
    }
    
    @State private var currentMode: AppMode = .standard
    
    // ISSUE WEHRE userProfile is reffed before init()
    
//    TEMP
    init () {
        userProfile = UserProfileViewModel()
    }
    
    init (userProfile: UserProfileViewModel) {
        self.userProfile = userProfile
    }
    
    var body: some View {
        NavigationStack{
            ZStack {
                TabView(selection: $selectedTab) {
                    if currentMode == .standard {
                        //                        SpotView(hideHamburger: $hideHamburger, hamburgerAction: {
                        //                            withAnimation(.interpolatingSpring(mass: 1.0, stiffness: 200, damping: 25, initialVelocity: 0)) {
                        //                                showSidebar.toggle()
                        //                            }
                        //                        })
                        ZStack {
                            if AuthManager.shared.hasUserProfile {
                                if let main_feed = FeedModel.feeds["main"] {
                                    ZStack {
                                        FeedView(
                                            hide_hamburger: $hideHamburger,
                                            hamburger_action: {
                                                withAnimation(.interpolatingSpring(mass: 1.0, stiffness: 200, damping: 25, initialVelocity: 0)) {
                                                    showSidebar.toggle()
                                                }
                                            },
                                            search_text: $search_text,
                                            show_search_bar: false,
                                            userProfile: userProfile,
                                            postsViewModel: main_feed
                                        )
                                        
                                        //                 Floating + (create post) button
                                        AddPostButton(
                                            preceding_post_id: nil,
                                            current_feed: main_feed,
                                            user_profile: userProfile
                                        )
                                    }
                                }
                            } else {
                                Text("LOADING")
                            }
                        }
                        .tag(0)
                        .tabItem {
                            Image(systemName: "house.fill")
//                                Image(systemName: "binoculars.fill")
                        }
                        .scaleEffect(showSidebar ? 0.95 : 1.0)
                        .offset(x: showSidebar ? UIScreen.main.bounds.width * 0.1 : 0)
                        .animation(.interpolatingSpring(mass: 1.0, stiffness: 200, damping: 25, initialVelocity: 0), value: showSidebar)
                        
                        IndexesView(hamburgerAction: {
                            withAnimation(.interpolatingSpring(mass: 1.0, stiffness: 200, damping: 25, initialVelocity: 0)) {
                                showSidebar.toggle()
                            }
                        })
                        .tag(1)
                        .tabItem {
                            Image(systemName: "chart.xyaxis.line")
                        }
                        .scaleEffect(showSidebar ? 0.95 : 1.0)
                        .offset(x: showSidebar ? UIScreen.main.bounds.width * 0.1 : 0)
                        .animation(.interpolatingSpring(mass: 1.0, stiffness: 200, damping: 25, initialVelocity: 0), value: showSidebar)
                        
                        ManekiView(hamburgerAction: {
                            withAnimation(.interpolatingSpring(mass: 1.0, stiffness: 200, damping: 25, initialVelocity: 0)) {
                                showSidebar.toggle()
                            }
                        })
                        .tag(2)
                        .tabItem {
                            Image(systemName: "cat.fill")
                        }
                        .scaleEffect(showSidebar ? 0.95 : 1.0)
                        .offset(x: showSidebar ? UIScreen.main.bounds.width * 0.1 : 0)
                        .animation(.interpolatingSpring(mass: 1.0, stiffness: 200, damping: 25, initialVelocity: 0), value: showSidebar)
                        
                        PortfolioView(hamburgerAction: {
                            withAnimation(.interpolatingSpring(mass: 1.0, stiffness: 200, damping: 25, initialVelocity: 0)) {
                                showSidebar.toggle()
                            }
                        })
                        .tag(3)
                        .tabItem {
                            Image(systemName: "chart.bar.fill")
                        }
                        .scaleEffect(showSidebar ? 0.95 : 1.0)
                        .offset(x: showSidebar ? UIScreen.main.bounds.width * 0.1 : 0)
                        .animation(.interpolatingSpring(mass: 1.0, stiffness: 200, damping: 25, initialVelocity: 0), value: showSidebar)
                        
                        ProfileListView(
                            hide_hamburger: $hideHamburger,
                            hamburger_action: {
                                withAnimation(.interpolatingSpring(mass: 1.0, stiffness: 200, damping: 25, initialVelocity: 0)) {
                                    showSidebar.toggle()
                                }
                            },
                            search_text: $search_text,
                            userProfile: userProfile,
                            profilesViewModel: SearchedProfilesModel(
                                user_profile: userProfile,
                                feed_key: userProfile.firebase_uid,
                                search_text: search_text
                            )
                        )
                        .tag(4)
                        .tabItem {
                            Image(systemName: "person.fill")
                        }
                        .scaleEffect(showSidebar ? 0.95 : 1.0)
                        .offset(x: showSidebar ? UIScreen.main.bounds.width * 0.1 : 0)
                        .animation(.interpolatingSpring(mass: 1.0, stiffness: 200, damping: 25, initialVelocity: 0), value: showSidebar)
                        
//                        Color.clear
//                            .tag(degenEntryTabTag)
//                            .tabItem {
//                                Image(systemName: "flame.fill")
//                            }
                    }
//                    } else {
//                        DegenTrendingView()
//                            .tag(0)
//                            .tabItem {
//                                Image(systemName: "flame")
//                            }
//                            .scaleEffect(showSidebar ? 0.95 : 1.0)
//                            .offset(x: showSidebar ? UIScreen.main.bounds.width * 0.1 : 0)
//                            .animation(.interpolatingSpring(mass: 1.0, stiffness: 200, damping: 25, initialVelocity: 0), value: showSidebar)
//
//                        WalletSocialMediaTrackerView()
//                            .tag(1)
//                            .tabItem {
//                                Image(systemName: "wallet.pass")
//                            }
//                            .environmentObject(tradingWalletViewModel)
//                            .scaleEffect(showSidebar ? 0.95 : 1.0)
//                            .offset(x: showSidebar ? UIScreen.main.bounds.width * 0.1 : 0)
//                            .animation(.interpolatingSpring(mass: 1.0, stiffness: 200, damping: 25, initialVelocity: 0), value: showSidebar)
//
//                        DegenTradeView()
//                            .tag(2)
//                            .tabItem {
//                                Image(systemName: "arrow.triangle.2.circlepath")
//                            }
//                            .scaleEffect(showSidebar ? 0.95 : 1.0)
//                            .offset(x: showSidebar ? UIScreen.main.bounds.width * 0.1 : 0)
//                            .animation(.interpolatingSpring(mass: 1.0, stiffness: 200, damping: 25, initialVelocity: 0), value: showSidebar)
//
//                        PortfolioView(hamburgerAction: {
//                            withAnimation(.interpolatingSpring(mass: 1.0, stiffness: 200, damping: 25, initialVelocity: 0)) {
//                                showSidebar.toggle()
//                            }
//                        })
//                            .tag(3)
//                            .tabItem {
//                                Image(systemName: "briefcase")
//                            }
//                            .scaleEffect(showSidebar ? 0.95 : 1.0)
//                            .offset(x: showSidebar ? UIScreen.main.bounds.width * 0.1 : 0)
//                            .animation(.interpolatingSpring(mass: 1.0, stiffness: 200, damping: 25, initialVelocity: 0), value: showSidebar)
//
//                        Color.clear
//                            .tag(degenExitTabTag)
//                            .tabItem {
//                                Image(systemName: "rectangle.portrait.and.arrow.right")
//                            }
//                    }
                }
                .scaleEffect(showSidebar ? 0.95 : 1.0)
                .offset(x: showSidebar ? UIScreen.main.bounds.width * 0.1 : 0)
                .animation(.interpolatingSpring(mass: 1.0, stiffness: 200, damping: 25, initialVelocity: 0), value: showSidebar)
                .toolbar {
                    if showToolbar && !showSidebar && !isDegenSplashActive && !isExitingSplashActive {
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button(action: { showSidebar.toggle() }) {
                                Image(systemName: "line.horizontal.3").foregroundColor(.white)
                            }
                        }
                        ToolbarItem(placement: .principal) {
                            Text(selectedTabTitle)
                        }
                        ToolbarItem(placement: .topBarTrailing) {
                            HStack(spacing: 16) {
                                Button(action: {}) {
                                    Image(systemName: "bell").foregroundColor(.white)
                                }
                                Button(action: {}) {
                                    Image(systemName: "info.circle").foregroundColor(.white)
                                }
                            }
                        }
                    }
                }
                .navigationBarTitleDisplayMode(.inline)
                .disabled(showSidebar || isDegenSplashActive || isExitingSplashActive || showDegenEntryWarning || showDegenExitConfirmation)
                .toolbarBackground(.hidden, for: .navigationBar)
                .edgesIgnoringSafeArea(.top)
                
                // Existing Sidebar View
                SidebarView(
                    hideHamburger: $hideHamburger,
                    showSidebar: $showSidebar,
                    showDegenMode: $showDegenMode,
                    selectedTab: $selectedTab,
                    search_text: $search_text,
                    userProfile: userProfile
                )
                .frame(width: UIScreen.main.bounds.width)
                .offset(x: showSidebar ? 0 : -UIScreen.main.bounds.width)
                .animation(.interpolatingSpring(mass: 1.0, stiffness: 200, damping: 25, initialVelocity: 0), value: showSidebar)
                .padding(.top, 8)
                
                // Overlay for Popups
                if showDegenExitConfirmation || showDegenEntryWarning {
                    Color.black.opacity(0.7)
                        .ignoresSafeArea()
                        .transition(.opacity)
                }
                
//                // Entry Warning Popup (New)
//                if showDegenEntryWarning {
//                    DegenEntryWarningView(
//                        isPresented: $showDegenEntryWarning,
//                        onAccept: {
//                            showDegenEntryWarning = false
//                            
//                            // Close sidebar silently in the background if open
//                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
//                                showSidebar = false
//                            }
//                            
//                            // Activate degen splash animation and mode change
//                            activateDegenSplash()
//                        }
//                    )
//                    .transition(.scale(scale: 0.9).combined(with: .opacity))
//                    .zIndex(999)
//                }
                
//                // Exit Confirmation Popup (Updated)
//                if showDegenExitConfirmation {
//                    DegenExitConfirmationView(
//                        isPresented: $showDegenExitConfirmation,
//                        onConfirm: {
//                            showDegenExitConfirmation = false
//                            
//                            // Prepare for exit before showing the splash
//                            selectedTab = 0
//                            
//                            // Activate exit splash first
//                            activateExitSplash()
//                            
//                            // Close sidebar silently in the background
//                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
//                                showSidebar = false
//                            }
//                            
//                            currentMode = .standard
//                            showDegenMode = false
//                        }
//                    )
//                    .transition(.scale(scale: 0.9).combined(with: .opacity))
//                    .zIndex(999)
//                }
//                
//                // Degen Mode Splash Screen
//                if isDegenSplashActive {
//                    DegenSplashScreen()
//                        .offset(y: hideSplashScreen ? -UIScreen.main.bounds.height : 0)
//                        .animation(.easeInOut(duration: 1.5).delay(0.75), value: hideSplashScreen)
//                        .ignoresSafeArea()
//                }
//                
//                // Exit Splash Screen (using original splash screen logic)
//                if isExitingSplashActive {
//                    exitSplashScreen
//                        .offset(y: hideSplashScreen ? -UIScreen.main.bounds.height : 0)
//                        .animation(.easeInOut(duration: 1.5).delay(0.75), value: hideSplashScreen)
//                        .ignoresSafeArea()
//                }
            }
            .preferredColorScheme(.dark)
            .onChange(of: showSidebar) { oldValue, newValue in
                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                    hideHamburger = newValue
                }
            }
//            .onChange(of: showDegenMode) { oldValue, newValue in
//                if newValue && currentMode == .standard {
//                    // Instead of immediately activating, show the warning first
//                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
//                        showDegenEntryWarning = true
//                    }
//                }
//            }
//            .onChange(of: selectedTab) { oldValue, newValue in
//                if currentMode == .degen && newValue == degenExitTabTag {
//                    selectedTab = oldValue
//                    requestExitDegenMode()
//                } else if currentMode == .standard && newValue == degenEntryTabTag {
//                    selectedTab = oldValue
//                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
//                        showDegenEntryWarning = true
//                    }
//                }
//            }
        }
    }
    
    // Exit Splash Screen View
    private var exitSplashScreen: some View {
        ZStack {
            // Gradient background instead of flat black
            LinearGradient(
                gradient: Gradient(colors: [Color(hex: "121212"), Color(hex: "000000")]),
                startPoint: .top,
                endPoint: .bottom
            )
            .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 30) {
                // Main title with better typography and animation
                Text("DOJO")
                    .foregroundColor(.white)
                    .font(.custom("Inter", size: 54))
                    .fontWeight(.bold)
                    .shadow(color: Color.white.opacity(0.4), radius: 10, x: 0, y: 0)
                    .opacity(showDojo ? 1 : 0)
                    .scaleEffect(showDojo ? 1 : 0.8)
                    .animation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.3), value: showDojo)
                
                // Bottom elements with improved animations and layout
                VStack(spacing: 24) {
                    Divider()
                        .frame(width: 120, height: 2)
                        .background(Color.white.opacity(0.8))
                    
                    Image("SplashScreenBranding")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 220, height: 230)
                }
                .opacity(showBottomElements ? 1 : 0)
                .offset(y: showBottomElements ? 0 : 30)
                .animation(.spring(response: 0.7, dampingFraction: 0.8).delay(0.7), value: showBottomElements)
            }
            .padding(.vertical, 50)
        }
        .onAppear {
            // Sequence the animations
            withAnimation {
                showDojo = true
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                withAnimation {
                    showBottomElements = true
                }
            }
        }
    }
    
    private var selectedTabTitle: String {
      if currentMode == .standard {
        switch selectedTab {
        case 0: return "Feed"
        case 1: return "Indexes"
        case 2: return "Maneki"
        case 3: return "Portfolio"
        default: return ""
        }
      } else {
        switch selectedTab {
        case 0: return "Trending"
        case 1: return "Wallet Tracker"
        case 2: return "Trade"
        case 3: return "Portfolio"
        default: return ""
        }
      }
    }
    
    private func requestExitDegenMode() {
        if !showDegenExitConfirmation {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                showDegenExitConfirmation = true
            }
        }
    }
    
    // Existing activation method for Degen Splash
    private func activateDegenSplash() {
        // Hide toolbar before showing splash
        withAnimation {
            showToolbar = false
        }
        
        isDegenSplashActive = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            showDegenMode = true
            currentMode = .degen
        }
        
        // Start the slide-up animation after a short delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation(.easeInOut(duration: 1.5)) {
                hideSplashScreen = true
            }
        }
        
        // Wait for the full animation to complete before showing toolbar and content
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) {
            isDegenSplashActive = false
            hideSplashScreen = false
            // Show toolbar after splash screen animation fully completes
            withAnimation {
                showToolbar = true
            }
        }
    }
    
    // Method for Exit Splash
    private func activateExitSplash() {
        // Hide toolbar before exit splash
        withAnimation {
            showToolbar = false
        }
        
        isExitingSplashActive = true
        
        // Replicate the original splash screen animation
        showDojo = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            showLogo = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            showBottomElements = true
        }
        
        // Start the slide-up animation after a short delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation(.easeInOut(duration: 1.5)) {
                hideSplashScreen = true
            }
        }
        
        // Wait for the full animation to complete before showing toolbar and content
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) {
            isExitingSplashActive = false
            hideSplashScreen = false
            showDojo = false
            showBottomElements = false
            // Show toolbar after splash screen animation fully completes
            withAnimation {
                showToolbar = true
            }
        }
    }
}

// New Entry Warning View
struct DegenEntryWarningView: View {
    @Binding var isPresented: Bool
    var onAccept: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            // Header with icon
            HStack {
                Image(systemName: "exclamationmark.triangle")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 24, height: 24)
                    .foregroundColor(Color.yellow)
                
                Text("DEGEN MODE")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(Color.yellow)
            }
            .padding(.top, 6)
            
            // Warning
            Text("You're entering high-risk trading territory")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
            
            // Risk information
            VStack(alignment: .leading, spacing: 12) {
                riskRow(icon: "chart.line.downtrend.xyaxis", text: "Higher market volatility")
                riskRow(icon: "bolt.fill", text: "Rapid price movements")
                riskRow(icon: "dollarsign.circle", text: "Potential for significant losses")
                riskRow(icon: "tornado", text: "Less regulated assets")
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color.black.opacity(0.3))
            .cornerRadius(12)
            
            // Risk acknowledgment text
            Text("By entering Degen Mode, you acknowledge that you understand these risks and are trading at your own discretion.")
                .font(.system(size: 14))
                .foregroundColor(Color.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 5)
            
            // Buttons
            HStack(spacing: 16) {
                Button(action: {
                    withAnimation(.spring()) {
                        isPresented = false
                    }
                }) {
                    Text("Cancel")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [Color(hex: "2D3042"), Color(hex: "1E2132")]),
                                startPoint: .top,
                                endPoint: .bottom
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
                            )
                        )
                        .cornerRadius(12)
                }
                
                Button(action: onAccept) {
                    Text("Accept Risk")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [Color.yellow, Color.orange]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(12)
                        .shadow(color: Color.orange.opacity(0.5), radius: 8, x: 0, y: 2)
                }
            }
            .padding(.horizontal, 5)
        }
        .padding(24)
        .background(
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [Color(hex: "171D2B"), Color(hex: "0D1018")]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                
                // Subtle grid pattern
                GeometryReader { geometry in
                    Path { path in
                        let width = geometry.size.width
                        let height = geometry.size.height
                        let gridSize: CGFloat = 20
                        
                        for i in stride(from: 0, through: width, by: gridSize) {
                            path.move(to: CGPoint(x: i, y: 0))
                            path.addLine(to: CGPoint(x: i, y: height))
                        }
                        
                        for i in stride(from: 0, through: height, by: gridSize) {
                            path.move(to: CGPoint(x: 0, y: i))
                            path.addLine(to: CGPoint(x: width, y: i))
                        }
                    }
                    .stroke(Color.white.opacity(0.05), lineWidth: 0.5)
                }
            }
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(
                    LinearGradient(
                        gradient: Gradient(colors: [Color.yellow.opacity(0.7), Color.orange.opacity(0.3), Color.clear]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
        .cornerRadius(20)
        .shadow(color: Color.yellow.opacity(0.2), radius: 20, x: 0, y: 0)
        .padding(.horizontal, 24)
    }
    
    private func riskRow(icon: String, text: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(Color.yellow)
                .frame(width: 24, height: 24)
            
            Text(text)
                .font(.system(size: 14))
                .foregroundColor(.white)
            
            Spacer()
        }
    }
}

// Updated Exit Confirmation View
struct DegenExitConfirmationView: View {
    @Binding var isPresented: Bool
    var onConfirm: () -> Void
    
    var body: some View {
        VStack(spacing: 24) {
            // Header with icon
            HStack {
                Image(systemName: "arrow.uturn.backward.circle")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 28, height: 28)
                    .foregroundColor(Color.blue.opacity(0.9))
                
                Text("Exit Degen Mode")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
            }
            .padding(.top, 8)
            
            Divider()
                .background(LinearGradient(
                    gradient: Gradient(colors: [Color.clear, Color.white.opacity(0.5), Color.clear]),
                    startPoint: .leading,
                    endPoint: .trailing
                ))
            
            // Message
            Text("You're about to exit Degen Mode and return to the standard interface.")
                .font(.system(size: 16))
                .foregroundColor(.white.opacity(0.9))
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
            
            // Additional info
            VStack(alignment: .leading, spacing: 8) {
                infoRow(icon: "checkmark.shield.fill", text: "Your portfolio data will remain intact")
                infoRow(icon: "arrow.2.squarepath", text: "You can return to Degen Mode anytime")
            }
            .padding(12)
            .background(Color.white.opacity(0.05))
            .cornerRadius(8)
            
            // Buttons
            HStack(spacing: 16) {
                Button(action: {
                    withAnimation(.spring()) {
                        isPresented = false
                    }
                }) {
                    Text("Stay")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [Color(hex: "2D3042"), Color(hex: "1E2132")]),
                                startPoint: .top,
                                endPoint: .bottom
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
                            )
                        )
                        .cornerRadius(12)
                }
                
                Button(action: onConfirm) {
                    Text("Confirm Exit")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [Color(hex: "3B82F6"), Color(hex: "2563EB")]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(12)
                        .shadow(color: Color.blue.opacity(0.3), radius: 8, x: 0, y: 2)
                }
            }
        }
        .padding(24)
        .background(
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [Color(hex: "171D2B"), Color(hex: "0D1018")]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                
                // Subtle pattern
                GeometryReader { geometry in
                    Path { path in
                        let width = geometry.size.width
                        let height = geometry.size.height
                        let gridSize: CGFloat = 20
                        
                        for i in stride(from: 0, through: width, by: gridSize) {
                            path.move(to: CGPoint(x: i, y: 0))
                            path.addLine(to: CGPoint(x: i, y: height))
                        }
                        
                        for i in stride(from: 0, through: height, by: gridSize) {
                            path.move(to: CGPoint(x: 0, y: i))
                            path.addLine(to: CGPoint(x: width, y: i))
                        }
                    }
                    .stroke(Color.white.opacity(0.05), lineWidth: 0.5)
                }
            }
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(
                    LinearGradient(
                        gradient: Gradient(colors: [Color.blue.opacity(0.6), Color.blue.opacity(0.2), Color.clear]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
        .cornerRadius(20)
        .shadow(color: Color.blue.opacity(0.15), radius: 20, x: 0, y: 0)
        .padding(.horizontal, 24)
    }
    
    private func infoRow(icon: String, text: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(Color.blue.opacity(0.9))
                .frame(width: 20, height: 20)
            
            Text(text)
                .font(.system(size: 14))
                .foregroundColor(.white.opacity(0.9))
            
            Spacer()
        }
    }
}

struct HomePageView_Previews: PreviewProvider {
    static var previews: some View {
        HomePageView()
    }
}
