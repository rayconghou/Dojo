//
//  WalletSocialMediaTracker.swift
//  Dojo
//
//  Created by Raymond Hou on 3/31/25.
//

import SwiftUI


/// This view is what you use in your Degen tab item:
/// - If user hasn't completed wallet setup: show PIN + FaceID flow
/// - If user already has a wallet: show the main wallet+sentiment with toggle
struct WalletSocialMediaTrackerView: View {
    @EnvironmentObject var viewModel: TradingWalletViewModel
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        NavigationStack {
            ToggleableContentView(viewModel: viewModel)
                .navigationTitle("Tracker")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        HStack(spacing: 16) {
                            Button(action: {
                                // Trigger notifications
                            }) {
                                Image(systemName: "bell")
                                    .foregroundColor(.white)
                            }
                            Button(action: {
                                // Show info sheet or view
                            }) {
                                Image(systemName: "info.circle")
                                    .foregroundColor(.white)
                            }
                        }                        }
                }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .preferredColorScheme(.dark)
    }
}

/// New main view that toggles between "Wallet" and "Sentiment" using a slider
struct ToggleableContentView: View {
    @ObservedObject var viewModel: TradingWalletViewModel
    @State private var selectedAsset: DegenAsset? = nil
    @State private var selectedMode: ContentMode = .wallet
    @State private var selectedSentimentFilter: SentimentFilterSelector.SentimentFilter = .trending
    
    enum ContentMode: String, CaseIterable {
        case wallet = "Wallet"
        case sentiment = "Sentiment"
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Degen Header Bar
            DegenHeaderBar()
            
            // SCROLLABLE CONTENT BELOW HEADERS
            ScrollView {
                VStack(spacing: 0) {
                    if selectedMode == .sentiment {
                        sentimentModeContent
                    } else {
                        mainContentLayer
                    }
                    
                    // Add spacing for floating buttons
                    Spacer()
                        .frame(height: 80)
                }
            }
        }
        .animation(.easeInOut(duration: 0.3), value: selectedMode)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color(hex: "2D1B69"), Color(hex: "0C0519")]),
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .overlay(floatingButtonOverlay)
    }
    
    // MARK: - Computed Properties for Complex Views
    
    private var mainContentLayer: some View {
        ZStack(alignment: .top) {
            catBackgroundImage
            headerSection
            contentSection
        }
    }
    
    private var sentimentModeContent: some View {
        ZStack(alignment: .top) {
            // Background and header section
            ZStack(alignment: .top) {
                catBackgroundImage
                headerSection
            }
            
            // Content overlaid on the background
            VStack(spacing: 0) {
                Spacer()
                    .frame(height: 370) // Tiny adjustment to move content down a bit more
                
                // Segment picker overlaid on the asset
                sentimentSegmentPicker
                    .padding(.horizontal, 20)
                    .padding(.top, 12)
                
                // Add spacing between segment picker and tweet cards
                Spacer()
                    .frame(height: 16)
                
                // Sentiment content overlaid on the asset
                VStack(spacing: 0) {
                    sentimentContent
                        .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .opacity))
                }
                .background(contentBackground)
                .padding(.horizontal, 16)
                .padding(.top, 8)
                
                Spacer()
            }
        }
    }
    
    private var sentimentSegmentPicker: some View {
        SentimentFilterSelector(selectedFilter: $selectedSentimentFilter)
    }
    
    private var catBackgroundImage: some View {
        Image("DegenTrackerBackground")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(maxWidth: .infinity)
            .offset(y: -20)
    }
    
    private var headerSection: some View {
        VStack(spacing: 12) {
            Text("TRACKED WALLETS")
                .font(.custom("Korosu", size: 24))
                .foregroundColor(.white)
                .shadow(color: .black, radius: 2, x: 1, y: 1)
            
            ModeToggleSelector(selectedMode: $selectedMode)
                .padding(.horizontal, 20)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(headerBackground)
        .cornerRadius(12)
        .padding(.horizontal, 20)
        .padding(.top, 8)
    }
    
    private var headerBackground: some View {
        GeometryReader { geometry in
            Image("DegenHeader")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: geometry.size.width * 1.5, height: geometry.size.height * 1.5)
                .scaleEffect(x: 1, y: 1)
                .offset(x: -geometry.size.width * 0.25, y: -geometry.size.height * 0.25)
                .clipped()
                .overlay(
                    LinearGradient(
                        gradient: Gradient(colors: [Color(hex: "2D1B69").opacity(0.3), Color.clear]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
        }
    }
    
    private var contentSection: some View {
        VStack(spacing: 0) {
            Spacer()
                .frame(height: 400)
            
            VStack(spacing: 0) {
                if selectedMode == .wallet {
                    WalletView(viewModel: viewModel, selectedAsset: $selectedAsset)
                        .transition(.asymmetric(insertion: .move(edge: .leading), removal: .opacity))
                } else {
                    sentimentContent
                        .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .opacity))
                }
            }
            .background(contentBackground)
            .padding(.horizontal, 16)
            .padding(.top, 8)
        }
    }
    
    private var sentimentContent: some View {
        VStack(spacing: 0) {
            SentimentAnalysisView(viewModel: viewModel, selectedAsset: $selectedAsset, selectedFilter: $selectedSentimentFilter)
        }
    }
    
    private var contentBackground: some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(Color(hex: "0C0519"))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
            )
    }
    
    private var floatingButtonOverlay: some View {
        Group {
            if selectedMode == .wallet {
                VStack {
                    Spacer()
                    addWalletButton
                }
            }
        }
    }
    
    private var addWalletButton: some View {
        Button(action: {
            print("Add New Wallet tapped")
        }) {
            Text("Add New Wallet")
                .font(.custom("Korosu", size: 18))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(buttonGradientBackground)
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 10)
    }
    
    private var buttonGradientBackground: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(buttonGradient)
                .blur(radius: 8)
                .opacity(0.8)
            
            RoundedRectangle(cornerRadius: 12)
                .fill(buttonGradient)
                .shadow(color: Color(hex: "4F2FB6").opacity(0.8), radius: 12, x: 0, y: 0)
                .shadow(color: Color(hex: "9746F6").opacity(0.6), radius: 8, x: 0, y: 0)
                .shadow(color: Color(hex: "F7B0FE").opacity(0.4), radius: 4, x: 0, y: 0)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.white.opacity(0.3), lineWidth: 1)
                )
        }
    }
    
    private var buttonGradient: LinearGradient {
        LinearGradient(
            gradient: Gradient(stops: [
                .init(color: Color(hex: "4F2FB6"), location: 0.0),
                .init(color: Color(hex: "9746F6"), location: 0.5),
                .init(color: Color(hex: "F7B0FE"), location: 1.0)
            ]),
            startPoint: .leading,
            endPoint: .trailing
        )
    }
}

/// Custom toggle slider between Wallet and Sentiment modes
struct ModeToggleSelector: View {
    @Binding var selectedMode: ToggleableContentView.ContentMode
    
    var body: some View {
        HStack(spacing: 0) {
            // WALLET Button
            Button(action: {
                selectedMode = .wallet
            }) {
                Text("WALLET")
                    .font(.custom("Korosu", size: 15))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 35)
                    .background(
                        selectedMode == .wallet ?
                        LinearGradient(
                            gradient: Gradient(colors: [Color(hex: "4F2FB6"), Color(hex: "F7B0FE")]),
                            startPoint: .leading,
                            endPoint: .trailing
                        ) :
                        LinearGradient(
                            gradient: Gradient(colors: [Color(hex: "1A1C2E"), Color(hex: "1A1C2E")]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(10, corners: [.topLeft, .bottomLeft])
            }
            
            // SENTIMENT Button
            Button(action: {
                selectedMode = .sentiment
            }) {
                Text("SENTIMENT")
                    .font(.custom("Korosu", size: 15))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 35)
                    .background(
                        selectedMode == .sentiment ?
                        LinearGradient(
                            gradient: Gradient(colors: [Color(hex: "4F2FB6"), Color(hex: "F7B0FE")]),
                            startPoint: .leading,
                            endPoint: .trailing
                        ) :
                        LinearGradient(
                            gradient: Gradient(colors: [Color(hex: "1A1C2E").opacity(0.3), Color(hex: "1A1C2E").opacity(0.3)]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(10, corners: [.topRight, .bottomRight])
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.clear) // Make transparent to show DegenBackground
        )
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color(hex: "4F2FB6").opacity(0.6), lineWidth: 1)
        )
    }
}

/// The wallet view showing user's balance and assets
struct WalletView: View {
    @ObservedObject var viewModel: TradingWalletViewModel
    @Binding var selectedAsset: DegenAsset?
    @State private var selectedWallet: TrackedWallet?
    @State private var showingAddWalletSheet = false
    
    var body: some View {
        VStack(spacing: 16) {
            // Top padding
            Spacer()
                .frame(height: 4)
            
            ForEach(viewModel.trackedWallets) { wallet in
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        if selectedWallet == wallet {
                            selectedWallet = nil
                        } else {
                            selectedWallet = wallet
                        }
                    }
                }) {
                    TrackedWalletCard(wallet: wallet, isSelected: wallet == selectedWallet)
                }
                .buttonStyle(PlainButtonStyle())
            }
            
            // Bottom padding
            Spacer()
                .frame(height: 4)
            
            if let wallet = selectedWallet {
                HStack {
                    Text("Wallet Analytics")
                        .font(.system(.headline, design: .rounded))
                        .fontWeight(.semibold)
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.white, .white.opacity(0.7)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                    
                    Spacer()
                    
                    Button(action: {
                        withAnimation {
                            selectedWallet = nil
                        }
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                            .font(.footnote)
                    }
                }
                .padding(.horizontal)
                
                WalletDetailView(wallet: wallet)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .padding(.horizontal)
            }
        }
        .padding(.horizontal, 16)
        .sheet(isPresented: $showingAddWalletSheet) {
            AddPublicWalletView(viewModel: viewModel)
        }
    }
}

struct TrackedWalletCard: View {
    let wallet: TrackedWallet
    let isSelected: Bool

    var body: some View {
        VStack(spacing: 16) {
            // Top Row: DegenWallet asset + wallet info
            HStack(spacing: 8) {
                // DegenWallet asset
                Image("DegenWallet")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 40, height: 40)
                
                // Wallet info VStack
                VStack(alignment: .leading, spacing: 2) {
                    Text(wallet.label)
                        .font(.custom("Satoshi-Bold", size: 15))
                        .foregroundColor(.white)
                        .lineLimit(1)
                    
                    Text(wallet.shortAddress)
                        .font(.custom("Satoshi-Medium", size: 12))
                        .foregroundColor(.gray)
                        .lineLimit(1)
                }
                
                Spacer()
            }
            
            // Bottom Row: Value container + sparkline
            HStack(spacing: 0) {
                // Rounded rectangle with dollar icon and value (flexible width)
                HStack(spacing: 8) {
                    // Dollar icon with glow (same as DegenHeaderBar)
                    ZStack {
                        // Glow effect
                        Circle()
                            .fill(Color(hex: "FFBE02"))
                            .frame(width: 28, height: 28)
                            .blur(radius: 4)
                            .opacity(0.6)
                        
                        // Main icon - yellow circle with white dollar sign
                        ZStack {
                            Circle()
                                .fill(Color(hex: "FFBE02"))
                                .frame(width: 24, height: 24)
                            
                            Text("$")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white)
                        }
                    }
                    
                    // Value and percentage on same line
                    HStack(spacing: 6) {
                        // Balance text - flexible width, no constraints
                        Text(wallet.formattedBalance)
                            .font(.custom("Satoshi-Bold", size: 15))
                            .foregroundColor(.white)
                            .fixedSize(horizontal: true, vertical: true)
                        
                        // Percentage text - only takes what it needs
                        Text(wallet.pnlText)
                            .font(.custom("Satoshi-Medium", size: 12))
                            .foregroundColor(wallet.pnlColor)
                            .fixedSize(horizontal: true, vertical: true)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .frame(height: 4)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(hex: "2c1F41"))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color(hex: "3E3251"), lineWidth: 1.5)
                )
                
                // Sparkline graph - extends all the way to the right edge
                SparklineGraph()
                    .frame(maxWidth: .infinity)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(
                    LinearGradient(
                        gradient: Gradient(stops: [
                            .init(color: Color(hex: "130825"), location: 0.0),
                            .init(color: Color(hex: "4F2FB6").opacity(0.1), location: 1.0)
                        ]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(hex: "22172F"), lineWidth: 1.5)
        )
        .scaleEffect(isSelected ? 1.02 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
    }
}

// MARK: - Sparkline Graph Component
struct SparklineGraph: View {
    var body: some View {
        GeometryReader { geometry in
            // Sparkline path - fills available width
            Path { path in
                let width = geometry.size.width
                let height = geometry.size.height
                let points = generateSparklinePoints(width: width, height: height)
                
                if !points.isEmpty {
                    path.move(to: points[0])
                    for point in points.dropFirst() {
                        path.addLine(to: point)
                    }
                }
            }
            .stroke(
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(hex: "4F2FB6"),
                        Color(hex: "9746F6")
                    ]),
                    startPoint: .leading,
                    endPoint: .trailing
                ),
                style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round)
            )
            .shadow(color: Color(hex: "4F2FB6").opacity(0.5), radius: 2, x: 0, y: 0)
        }
        .frame(height: 40) // Fixed height for consistent appearance
    }
    
    private func generateSparklinePoints(width: CGFloat, height: CGFloat) -> [CGPoint] {
        // Generate random sparkline data
        let pointCount = 20
        var points: [CGPoint] = []
        
        for i in 0..<pointCount {
            let x = (CGFloat(i) / CGFloat(pointCount - 1)) * width
            let randomY = CGFloat.random(in: 0.2...0.8) * height
            points.append(CGPoint(x: x, y: randomY))
        }
        
        return points
    }
}

struct WalletDetailView: View {
    let wallet: TrackedWallet
    @State private var selectedTimeframe: TimeFrame = .week
    
    enum TimeFrame: String, CaseIterable {
        case day = "24H"
        case week = "7D"
        case month = "30D"
        case year = "1Y"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            // Performance chart mock
            HStack {
                ForEach(TimeFrame.allCases, id: \.self) { timeframe in
                    Button(action: {
                        withAnimation {
                            selectedTimeframe = timeframe
                        }
                    }) {
                        Text(timeframe.rawValue)
                            .font(.caption)
                            .fontWeight(selectedTimeframe == timeframe ? .bold : .medium)
                            .foregroundColor(selectedTimeframe == timeframe ? .white : .gray)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(
                                selectedTimeframe == timeframe ?
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(
                                        LinearGradient(
                                            colors: [.blue.opacity(0.7), .purple.opacity(0.7)],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    ) : nil
                            )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .frame(maxWidth: .infinity, alignment: .center)
            
            // Mock chart
            RoundedRectangle(cornerRadius: 12)
                .fill(Color("CardBackgroundDark", bundle: .main) ?? Color.black.opacity(0.3))
                .frame(height: 120)
                .overlay(
                    ZStack {
                        // This is a placeholder for where you'd put actual chart data
                        Path { path in
                            let width: CGFloat = UIScreen.main.bounds.width - 80
                            let height: CGFloat = 80
                            
                            // Mock data points
                            let points = [
                                CGPoint(x: 0, y: height * 0.5),
                                CGPoint(x: width * 0.2, y: height * 0.4),
                                CGPoint(x: width * 0.4, y: height * 0.7),
                                CGPoint(x: width * 0.6, y: height * 0.3),
                                CGPoint(x: width * 0.8, y: height * 0.5),
                                CGPoint(x: width, y: height * 0.2)
                            ]
                            
                            path.move(to: points[0])
                            for point in points.dropFirst() {
                                path.addLine(to: point)
                            }
                        }
                        .stroke(
                            LinearGradient(
                                colors: [.blue, .purple],
                                startPoint: .leading,
                                endPoint: .trailing
                            ),
                            lineWidth: 3
                        )
                        
                        // Gradient fill below the line
                        LinearGradient(
                            colors: [.blue.opacity(0.3), .purple.opacity(0.1), .clear],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        .mask(
                            Path { path in
                                let width: CGFloat = UIScreen.main.bounds.width - 80
                                let height: CGFloat = 80
                                
                                // Mock data points
                                let points = [
                                    CGPoint(x: 0, y: height * 0.5),
                                    CGPoint(x: width * 0.2, y: height * 0.4),
                                    CGPoint(x: width * 0.4, y: height * 0.7),
                                    CGPoint(x: width * 0.6, y: height * 0.3),
                                    CGPoint(x: width * 0.8, y: height * 0.5),
                                    CGPoint(x: width, y: height * 0.2)
                                ]
                                
                                path.move(to: CGPoint(x: 0, y: height))
                                path.addLine(to: points[0])
                                for point in points.dropFirst() {
                                    path.addLine(to: point)
                                }
                                path.addLine(to: CGPoint(x: width, y: height))
                                path.closeSubpath()
                            }
                        )
                    }
                    .padding()
                )
            
            // Wallet stats
            VStack(spacing: 16) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Total Balance")
                            .font(.caption)
                            .foregroundColor(.gray)
                        Text(wallet.formattedBalance)
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("Performance")
                            .font(.caption)
                            .foregroundColor(.gray)
                        Text(wallet.pnlText)
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(wallet.pnlColor)
                    }
                }
                
                Divider()
                    .background(Color.gray.opacity(0.3))
                
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Transactions")
                            .font(.caption)
                            .foregroundColor(.gray)
                        Text("\(wallet.transactions.count)")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("Activity")
                            .font(.caption)
                            .foregroundColor(.gray)
                        Text(wallet.transactionFrequency)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                    }
                }
                
                Button(action: {
                    // Action to view full details
                }) {
                    Text("View Transactions")
                        .font(.footnote)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(
                                    LinearGradient(
                                        colors: [.blue.opacity(0.7), .purple.opacity(0.7)],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                        )
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color("CardBackgroundDark", bundle: .main) ?? Color(UIColor.tertiarySystemBackground))
                    .shadow(color: Color.black.opacity(0.15), radius: 8, x: 0, y: 4)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(
                                LinearGradient(
                                    colors: [Color.white.opacity(0.1), Color.clear],
                                    startPoint: .top,
                                    endPoint: .bottom
                                ),
                                lineWidth: 1
                            )
                    )
            )
        }
        .padding(.bottom, 24)
    }
}

struct AddPublicWalletView: View {
    @ObservedObject var viewModel: TradingWalletViewModel
    @Environment(\.presentationMode) var presentationMode
    @FocusState private var isAddressFieldFocused: Bool

    var body: some View {
        NavigationView {
            ZStack {
                // Background gradient
                LinearGradient(
                    colors: [Color.black, Color(hex: "101318")],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                VStack(spacing: 24) {
                    Image(systemName: "wallet.pass.fill")
                        .font(.system(size: 60))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.blue, .purple],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .padding(.top, 40)
                    
                    Text("Add New Wallet")
                        .font(.system(.title2, design: .rounded))
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    VStack(spacing: 20) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Wallet Address")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                                .padding(.leading, 4)
                            
                            TextField("", text: $viewModel.newWalletAddress)
                                .font(.system(.body, design: .monospaced))
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color("CardBackgroundDark", bundle: .main) ?? Color(UIColor.secondarySystemBackground))
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(
                                            LinearGradient(
                                                colors: [Color.white.opacity(0.1), Color.clear],
                                                startPoint: .top,
                                                endPoint: .bottom
                                            ),
                                            lineWidth: 1
                                        )
                                )
                                .focused($isAddressFieldFocused)
                                .onAppear {
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                        isAddressFieldFocused = true
                                    }
                                }
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Wallet Label (Optional)")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                                .padding(.leading, 4)
                            
                            TextField("", text: $viewModel.newWalletLabel)
                                .placeholder(when: viewModel.newWalletLabel.isEmpty) {
                                    Text("My Trading Wallet")
                                        .foregroundColor(.gray.opacity(0.5))
                                }
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color("CardBackgroundDark", bundle: .main) ?? Color(UIColor.secondarySystemBackground))
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(
                                            LinearGradient(
                                                colors: [Color.white.opacity(0.1), Color.clear],
                                                startPoint: .top,
                                                endPoint: .bottom
                                            ),
                                            lineWidth: 1
                                        )
                                )
                        }
                    }
                    .padding(.horizontal, 16)
                    
                    // Support for QR code scanning
                    Button(action: {
                        // QR code scanning action would go here
                    }) {
                        HStack {
                            Image(systemName: "qrcode.viewfinder")
                            Text("Scan QR Code")
                        }
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .padding(.vertical, 12)
                        .padding(.horizontal, 24)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color("CardBackgroundDark", bundle: .main) ?? Color(UIColor.secondarySystemBackground))
                        )
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        viewModel.addCustomWallet()
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Text("Import Wallet")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(
                                        LinearGradient(
                                            colors: viewModel.newWalletAddress.isEmpty ?
                                                    [.gray.opacity(0.3), .gray.opacity(0.2)] :
                                                    [.blue, .purple.opacity(0.8)],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .shadow(color: viewModel.newWalletAddress.isEmpty ?
                                            Color.clear :
                                            Color.blue.opacity(0.3),
                                            radius: 8, x: 0, y: 4)
                            )
                    }
                    .disabled(viewModel.newWalletAddress.isEmpty)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 24)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "xmark")
                        .font(.body)
                        .foregroundColor(.gray)
                        .padding(8)
                        .background(
                            Circle()
                                .fill(Color("CardBackgroundDark", bundle: .main) ?? Color(UIColor.tertiarySystemBackground))
                        )
                }
            )
        }
        .preferredColorScheme(.dark)
    }
}

/// Filter chip component for sentiment categories
struct FilterChip: View {
    var title: String
    var isSelected: Bool
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(isSelected ? .semibold : .regular)
                .foregroundColor(isSelected ? .white : Color(UIColor.secondaryLabel))
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(
                    Capsule()
                        .foregroundColor(.clear) // Needed to keep shape layout
                        .background(
                            isSelected
                            ? AnyView(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color.blue, Color.purple]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            : AnyView(
                                Color("CardBackgroundDark", bundle: .main) ?? Color(UIColor.tertiarySystemBackground)
                            )
                        )
                        .shadow(color: isSelected ? Color.blue.opacity(0.4) : Color.clear, radius: 6, x: 0, y: 3)
                )
                .overlay(
                    Capsule()
                        .stroke(isSelected ? Color.clear : Color.gray.opacity(0.2), lineWidth: 1)
                )
        }
    }
}

/// Asset filter chip component
struct AssetFilterChip: View {
    var title: String
    var isSelected: Bool
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(isSelected ? .black : .white)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(
                    Capsule()
                        .fill(isSelected ? Color.white : Color(hex: "160F23"))
                )
                .overlay(
                    Capsule()
                        .stroke(Color(hex: "3C2D44"), lineWidth: 1)
                )
        }
    }
}

// Helper extensions
extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content
    ) -> some View {
        ZStack(alignment: alignment) {
            placeholder().opacity(shouldShow ? 1 : 0)
            self
        }
    }
}
