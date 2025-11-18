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
    @State private var degenSplashOpacity = 0.0
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
                            VStack {
                                Image(selectedTab == 0 ? "DarkTappedHome" : "DarkUntappedHome")
                                    .foregroundColor(selectedTab == 0 ? .white : .gray)
                                Text("Home")
                                    .font(.caption)
                                    .foregroundColor(selectedTab == 0 ? .white : .gray)
                            }
                        }
                        .accentColor(.white)
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
                            VStack {
                                Image(selectedTab == 1 ? "DarkTappedIndexes" : "DarkUntappedIndexes")
                                    .foregroundColor(selectedTab == 1 ? .white : .gray)
                                Text("Indexes")
                                    .font(.caption)
                                    .foregroundColor(selectedTab == 1 ? .white : .gray)
                            }
                        }
                        .accentColor(.white)
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
                            VStack {
                                Image(selectedTab == 2 ? "DarkTappedManeki" : "DarkUntappedManeki")
                                    .foregroundColor(selectedTab == 2 ? .white : .gray)
                                Text("Maneki")
                                    .font(.caption)
                                    .foregroundColor(selectedTab == 2 ? .white : .gray)
                            }
                        }
                        .accentColor(.white)
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
                            VStack {
                                Image(selectedTab == 3 ? "DarkTappedPortfolio" : "DarkUntappedPortfolio")
                                    .foregroundColor(selectedTab == 3 ? .white : .gray)
                                Text("Portfolio")
                                    .font(.caption)
                                    .foregroundColor(selectedTab == 3 ? .white : .gray)
                            }
                        }
                        .accentColor(.white)
                        .scaleEffect(showSidebar ? 0.95 : 1.0)
                        .offset(x: showSidebar ? UIScreen.main.bounds.width * 0.1 : 0)
                        .animation(.interpolatingSpring(mass: 1.0, stiffness: 200, damping: 25, initialVelocity: 0), value: showSidebar)

                        Color.clear
                            .tag(degenEntryTabTag)
                            .tabItem {
                            VStack {
                                Image("DarkDegenMode")
                                    .foregroundColor(selectedTab == degenEntryTabTag ? .white : .gray)
                                Text("Degen")
                                    .font(.caption)
                                    .foregroundColor(selectedTab == degenEntryTabTag ? .white : .gray)
                            }
                            }
                            .accentColor(.white)
                    } else {
                        DegenTrendingView()
                            .tag(0)
                            .tabItem {
                                VStack {
                                    Image(selectedTab == 0 ? "DegenTappedTrending" : "DegenUntappedTrending")
                                        .foregroundColor(selectedTab == 0 ? .white : .gray)
                                    Text("Trending")
                                        .font(.caption)
                                        .foregroundColor(selectedTab == 0 ? .white : .gray)
                                }
                            }
                            .accentColor(.white)
                            .scaleEffect(showSidebar ? 0.95 : 1.0)
                            .offset(x: showSidebar ? UIScreen.main.bounds.width * 0.1 : 0)
                            .animation(.interpolatingSpring(mass: 1.0, stiffness: 200, damping: 25, initialVelocity: 0), value: showSidebar)

                        WalletSocialMediaTrackerView()
                            .tag(1)
                            .tabItem {
                                VStack {
                                    Image(selectedTab == 1 ? "DegenTappedTracker" : "DegenUntappedTracker")
                                        .foregroundColor(selectedTab == 1 ? .white : .gray)
                                    Text("Tracker")
                                        .font(.caption)
                                        .foregroundColor(selectedTab == 1 ? .white : .gray)
                                }
                            }
                            .accentColor(.white)
                            .environmentObject(tradingWalletViewModel)
                            .scaleEffect(showSidebar ? 0.95 : 1.0)
                            .offset(x: showSidebar ? UIScreen.main.bounds.width * 0.1 : 0)
                            .animation(.interpolatingSpring(mass: 1.0, stiffness: 200, damping: 25, initialVelocity: 0), value: showSidebar)

                        DegenTradeView()
                            .tag(2)
                            .tabItem {
                                VStack {
                                    Image(selectedTab == 2 ? "DegenTappedTrade" : "DegenUntappedSwap")
                                        .foregroundColor(selectedTab == 2 ? .white : .gray)
                                    Text("Trade")
                                        .font(.caption)
                                        .foregroundColor(selectedTab == 2 ? .white : .gray)
                                }
                            }
                            .accentColor(.white)
                            .scaleEffect(showSidebar ? 0.95 : 1.0)
                            .offset(x: showSidebar ? UIScreen.main.bounds.width * 0.1 : 0)
                            .animation(.interpolatingSpring(mass: 1.0, stiffness: 200, damping: 25, initialVelocity: 0), value: showSidebar)

                        DegenPortfolioView()
                            .tag(3)
                            .tabItem {
                                VStack {
                                    Image(selectedTab == 3 ? "DegenTappedFolder" : "DegenUntappedPortfolio")
                                        .foregroundColor(selectedTab == 3 ? .white : .gray)
                                    Text("Portfolio")
                                        .font(.caption)
                                        .foregroundColor(selectedTab == 3 ? .white : .gray)
                                }
                            }
                            .accentColor(.white)
                            .scaleEffect(showSidebar ? 0.95 : 1.0)
                            .offset(x: showSidebar ? UIScreen.main.bounds.width * 0.1 : 0)
                            .animation(.interpolatingSpring(mass: 1.0, stiffness: 200, damping: 25, initialVelocity: 0), value: showSidebar)

                        Color.clear
                            .tag(degenExitTabTag)
                            .tabItem {
                                VStack {
                                    ZStack {
                                        // Rounded rectangle background for segment selector style
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(
                                                LinearGradient(
                                                    gradient: Gradient(stops: [
                                                        .init(color: Color(hex: "4F2FB6"), location: 0.0),
                                                        .init(color: Color(hex: "9746F6"), location: 0.5),
                                                        .init(color: Color(hex: "F7B0FE"), location: 1.0)
                                                    ]),
                                                    startPoint: .leading,
                                                    endPoint: .trailing
                                                )
                                            )
                                            .frame(width: 60, height: 30)
                                            .shadow(color: Color(hex: "4F2FB6").opacity(0.5), radius: 4, x: 0, y: 2)
                                        
                                        // DegenTappedIcon
                                        Image("DegenTappedIcon")
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(width: 16, height: 16)
                                    }
                                    Text("Degen")
                                        .font(.caption)
                                        .foregroundColor(.white)
                                }
                            }
                            .accentColor(.white)
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
                
                // Entry Warning Popup (New)
                if showDegenEntryWarning {
                    DegenEntryWarningView(
                        isPresented: $showDegenEntryWarning,
                        onAccept: {
                            showDegenEntryWarning = false
                            
                            // Close sidebar silently in the background if open
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                showSidebar = false
                            }
                            
                            // Activate degen splash animation and mode change
                            activateDegenSplash()
                        }
                    )
                    .transition(.scale(scale: 0.9).combined(with: .opacity))
                    .zIndex(999)
                }
                
                // Exit Confirmation Popup (Updated)
                if showDegenExitConfirmation {
                    DegenExitConfirmationView(
                        isPresented: $showDegenExitConfirmation,
                        onConfirm: {
                            showDegenExitConfirmation = false
                            
                            // Prepare for exit before showing the splash
                            selectedTab = 0
                            
                            // Activate exit splash first
                            activateExitSplash()
                            
                            // Close sidebar silently in the background
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                showSidebar = false
                            }
                            
                            currentMode = .standard
                            showDegenMode = false
                        }
                    )
                    .transition(.scale(scale: 0.9).combined(with: .opacity))
                    .zIndex(999)
                }
                
                // Degen Mode Splash Screen
                if isDegenSplashActive {
                    DegenSplashScreen()
                        .opacity(hideSplashScreen ? 0 : degenSplashOpacity)
                        .animation(.easeInOut(duration: 0.5), value: hideSplashScreen)
                        .animation(.easeInOut(duration: 0.8), value: degenSplashOpacity)
                        .ignoresSafeArea()
                }
                
                // Exit Splash Screen (using original app login splash)
                if isExitingSplashActive {
                    exitSplashScreen
                        .offset(y: hideSplashScreen ? -UIScreen.main.bounds.height : 0)
                        .animation(.easeInOut(duration: 1.5).delay(0.75), value: hideSplashScreen)
                        .ignoresSafeArea()
                }
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
    
    // Exit Splash Screen View (using original app login splash)
    private var exitSplashScreen: some View {
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
        
        // Reset opacity and activate splash
        degenSplashOpacity = 0.0
        isDegenSplashActive = true
        
        // Fade in the splash screen
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(.easeInOut(duration: 0.8)) {
                degenSplashOpacity = 1.0
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            showDegenMode = true
            currentMode = .degen
        }
        
        // Start the fade-out animation after a short delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation(.easeInOut(duration: 0.5)) {
                hideSplashScreen = true
            }
        }
        
        // Wait for the full animation to complete before showing toolbar and content
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            isDegenSplashActive = false
            hideSplashScreen = false
            degenSplashOpacity = 0.0
            // Show toolbar after splash screen animation fully completes
            withAnimation {
                showToolbar = true
            }
        }
    }
    
    // Method for Exit Splash (using original app login splash animation)
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
            showLogo = false
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
        VStack(spacing: 0) {
            // Warning icon
            Image("DegenWarningLogo")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 50, height: 50)
                .padding(.top, 4)
                .padding(.bottom, 20) // More space between icon and title
            
            // Title and subtitle grouped together
            VStack(spacing: 4) { // Very tight spacing between title and subtitle
                Text("DEGEN MODE")
                    .font(.custom("Korosu", size: 28))
                    .foregroundColor(.white)
                    .shadow(color: .black, radius: 2, x: 1, y: 1)
                
                Text("You're entering high-risk trading territory")
                    .font(.custom("Satoshi", size: 12))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .shadow(color: .black, radius: 1, x: 0.5, y: 0.5)
            }
            .padding(.bottom, 8)
            
            // Risk bubbles
            VStack(spacing: 8) {
                riskBubble(icon: "DegenArrow", text: "Higher market volatility")
                riskBubble(icon: "DegenCharge", text: "Rapid price movements")
                riskBubble(icon: "DegenMoney", text: "Potential for significant losses")
                riskBubble(icon: "DegenBank", text: "Less regulated assets")
            }
            .padding(.horizontal, 24)
            .padding(.top, 16) // More spacing above risk bubbles
            .padding(.bottom, 16) // More spacing below risk bubbles
            
            // Risk acknowledgment text
            Text("By entering Degen Mode, you acknowledge that you understand these risks and are trading at your own discretion.")
                .font(.custom("Satoshi-Medium", size: 12))
                .foregroundColor(.gray)
                .multilineTextAlignment(.leading)
                .padding(.horizontal, 28)
                .padding(.bottom, 16) // Same spacing as risk bubbles
            
            // Buttons
            HStack(spacing: 12) {
                Button(action: {
                    withAnimation(.spring()) {
                        isPresented = false
                    }
                }) {
                    Text("Cancel")
                        .font(.custom("Satoshi-Bold", size: 16))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color.black.opacity(0.3))
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.white.opacity(0.2), lineWidth: 1)
                        )
                }
                
                    Button(action: onAccept) {
                        Text("Accept Risk")
                            .font(.custom("Satoshi-Bold", size: 16))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(
                                LinearGradient(
                                    colors: [Color(hex: "4F2FB6"), Color(hex: "F7B0FE"), Color(hex: "F7B0FE")],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(10)
                            .shadow(color: Color(hex: "F7B0FE"), radius: 8, x: 0, y: 2)
                            .shadow(color: Color(hex: "F7B0FE").opacity(0.6), radius: 16, x: 0, y: 4)
                            .shadow(color: Color(hex: "F7B0FE").opacity(0.3), radius: 24, x: 0, y: 6)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color(hex: "F7B0FE").opacity(0.8), lineWidth: 1.5)
                            )
                    }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 16)
        }
        .frame(maxWidth: 320, maxHeight: 500)
        .background(
            ZStack {
                // Solid dark background first
                Color.black.opacity(0.9)
                
                // DegenBackground asset overlay - positioned to show top section
                GeometryReader { geometry in
                    Image("DegenBackground")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: geometry.size.width * 1.5, height: geometry.size.height * 1.5)
                        .offset(x: -geometry.size.width * 0.1, y: geometry.size.height * 0.2)
                        .clipped()
                }
            }
        )
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.white.opacity(0.3), lineWidth: 1)
        )
        .padding(.horizontal, 24)
    }
    
    private func riskBubble(icon: String, text: String) -> some View {
        HStack(spacing: 8) {
            Image(icon)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 24, height: 24)
            
            Text(text)
                .font(.custom("Satoshi-Medium", size: 14))
                .foregroundColor(.white)
            
            Spacer()
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color.clear)
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color(hex: "352C55"), lineWidth: 1)
        )
    }
}

// Updated Exit Confirmation View
struct DegenExitConfirmationView: View {
    @Binding var isPresented: Bool
    var onConfirm: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            // Exit icon
            Image("DegenReturn")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 60, height: 60)
            .padding(.top, 4)
            .padding(.bottom, 20)
            
            // Title and subtitle grouped together
            VStack(spacing: 4) {
                Text("EXIT DEGEN MODE")
                    .font(.custom("Korosu", size: 28))
                    .foregroundColor(.white)
                    .shadow(color: .black, radius: 2, x: 1, y: 1)
                
                Text("You're about to exit Degen Mode and return to the standard interface.")
                    .font(.custom("Satoshi-Medium", size: 12))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .shadow(color: .black, radius: 1, x: 0.5, y: 0.5)
            }
            .padding(.bottom, 8)
            
            // Info points
            VStack(spacing: 8) {
                infoRow(icon: "DegenExitIcon1", text: "Your portfolio data will remain intact")
                infoRow(icon: "DegenExitIcon2", text: "You can return to Degen Mode anytime")
            }
            .padding(.horizontal, 24)
            .padding(.top, 16)
            .padding(.bottom, 16)
            
            // Buttons
            HStack(spacing: 12) {
                Button(action: {
                    withAnimation(.spring()) {
                        isPresented = false
                    }
                }) {
                    Text("Cancel")
                        .font(.custom("Satoshi-Bold", size: 16))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color.black.opacity(0.3))
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.white.opacity(0.2), lineWidth: 1)
                        )
                }
                
                Button(action: onConfirm) {
                    Text("Confirm")
                        .font(.custom("Satoshi-Bold", size: 16))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(
                            LinearGradient(
                                colors: [Color(hex: "4F2FB6"), Color(hex: "F7B0FE")],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(10)
                        .shadow(color: Color(hex: "F7B0FE"), radius: 8, x: 0, y: 2)
                        .shadow(color: Color(hex: "F7B0FE").opacity(0.6), radius: 16, x: 0, y: 4)
                        .shadow(color: Color(hex: "F7B0FE").opacity(0.3), radius: 24, x: 0, y: 6)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color(hex: "F7B0FE").opacity(0.8), lineWidth: 1.5)
                        )
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 16)
        }
        .frame(maxWidth: 320, maxHeight: 450)
        .background(
            ZStack {
                // Solid dark background first
                Color.black.opacity(0.9)
                
                // DegenBackground asset overlay - positioned to show bottom section with glow
                GeometryReader { geometry in
                    Image("DegenBackground")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: geometry.size.width * 1.5, height: geometry.size.height * 1.5)
                        .offset(x: 0, y: -geometry.size.height * 0.7) // Move up a bit more
                        .clipped()
                }
            }
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(
                    LinearGradient(
                        gradient: Gradient(colors: [Color(hex: "4F2FB6").opacity(0.6), Color(hex: "F7B0FE").opacity(0.2), Color.clear]),
                        startPoint: .bottomTrailing, // Changed from topLeading to bottomTrailing
                        endPoint: .topLeading // Changed from bottomTrailing to topLeading
                    ),
                    lineWidth: 1
                )
        )
        .cornerRadius(20)
        .shadow(color: Color(hex: "F7B0FE").opacity(0.15), radius: 20, x: 0, y: 0)
        .padding(.horizontal, 24)
    }
    
    private func infoRow(icon: String, text: String) -> some View {
        HStack(spacing: 12) {
            Image(icon)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 30, height: 30)
            
            Text(text)
                .font(.custom("Satoshi-Medium", size: 14))
                .foregroundColor(.white)
            
            Spacer()
        }
    }
}

struct HomePageView_Previews: PreviewProvider {
    static var previews: some View {
        HomePageView()
    }
}
