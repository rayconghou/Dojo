//
//  DegenTrendingView.swift
//  Dojo
//
//  Created by Raymond Hou on 3/31/25.
//

import SwiftUI


extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

enum VerificationFilter: String, CaseIterable {
    case verified = "Verified"
    case unverified = "Unverified"
}

struct DegenTrendingView: View {
    @StateObject var degenVM = DegenTrendingViewModel()

    @State private var searchText = ""
    @State private var selectedFilter: VerificationFilter = .verified
    @State private var verifiedTokenSet: Set<String> = []
    
    @State private var selectedToken: DexScreenerTokenProfile? = nil  // For modal

    var filteredTokens: [DexScreenerTokenProfile] {
        degenVM.latestTokens.filter { token in
            let matchesVerification: Bool = {
                switch selectedFilter {
                case .verified: return verifiedTokenSet.contains(token.tokenAddress)
                case .unverified: return !verifiedTokenSet.contains(token.tokenAddress)
                }
            }()

            let matchesSearch = searchText.isEmpty ||
                token.tokenAddress.localizedCaseInsensitiveContains(searchText) ||
                token.chainId.localizedCaseInsensitiveContains(searchText) ||
                (token.description?.localizedCaseInsensitiveContains(searchText) ?? false)

            return matchesVerification && matchesSearch
        }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // STATIC HEADER ELEMENTS (don't scroll)
                // Degen Header Bar
                DegenHeaderBar()
                
                // SCROLLABLE CONTENT BELOW HEADERS
                ScrollView {
                    VStack(spacing: 0) {
                        // ZStack to layer everything together - cat, trending header, and token list
                        ZStack(alignment: .top) {
                            // Cat image - background layer
                            Image("DegenTrendingBackground")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(maxWidth: .infinity)
                                .offset(y: -20) // Less negative offset to add more space above cat
                            
                            // Trending Header with Filter - layered on top of cat
                            VStack(spacing: 12) {
                                // TRENDING Title
                                Text("TRENDING")
                                    .font(.custom("Korosu", size: 24))
                                    .foregroundColor(.white)
                                    .shadow(color: .black, radius: 2, x: 1, y: 1)
                                
                                // Custom Segmented Control
                                HStack(spacing: 0) {
            // VERIFIED Button
            Button(action: {
                selectedFilter = .verified
            }) {
                Text("VERIFIED")
                    .font(.custom("Korosu", size: 15))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 35)
                    .background(
                        selectedFilter == .verified ?
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
            
            // UNVERIFIED Button
            Button(action: {
                selectedFilter = .unverified
            }) {
                Text("UNVERIFIED")
                    .font(.custom("Korosu", size: 15))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 35)
                    .background(
                        selectedFilter == .unverified ?
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
                                        .stroke(Color(hex: "22172F"), lineWidth: 1.5)
                                )
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 16)
                            .background(
                                ZStack {
                                    // DegenHeader asset - using GeometryReader for precise positioning
                                    GeometryReader { geometry in
                                        Image("DegenHeader")
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .frame(width: geometry.size.width * 1.5, height: geometry.size.height * 1.5) // Make larger than container
                                            .scaleEffect(x: 1, y: 1) // Keep original orientation
                                            .offset(x: -geometry.size.width * 0.25, y: -geometry.size.height * 0.25) // Position to show top-right glow
                                            .clipped()
                                    }
                                }
                            )
                            .cornerRadius(12)
                            .padding(.horizontal, 20)
                            .padding(.top, 8)
                            
                            // Token list positioned to overlap on cat - moved up significantly
                            VStack(spacing: 0) {
                                Spacer()
                                    .frame(height: 400) // Increased spacing to add more space below cat
                                
                                // Search Bar and Token List Container
                                VStack(spacing: 0) {
                // Search Bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                        .font(.system(size: 16))

                    TextField("Search new tokens...", text: $searchText)
                        .foregroundColor(.white)
                        .font(.custom("Satoshi-Bold", size: 14))

                    if !searchText.isEmpty {
                        Button {
                            searchText = ""
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.gray)
                                .font(.system(size: 24))
                        }
                    }
                }
                .padding(.vertical, 12)
                .padding(.horizontal, 16)
                .background(
                    RoundedRectangle(cornerRadius: 8)
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
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color(hex: "22172F"), lineWidth: 1.5)
                        )
                )
                .padding(.horizontal, 16)
                .padding(.top, 16)

                // Token List
                    LazyVStack(spacing: 16) {
                                if filteredTokens.isEmpty && selectedFilter == .verified {
                                    // Show spot tokens when no verified tokens are available
                                    SpotTokenListView()
                                } else {
                        ForEach(filteredTokens) { token in
                            DegenTokenRow(token: token)
                                .listRowInsets(EdgeInsets())
                                .onTapGesture {
                                    selectedToken = token  // Show modal when tapped
                                }
                        }
                    }
                            }
                            .padding(.horizontal, 16)
                            .padding(.top, 16)
                            .padding(.bottom, 16)
                        }
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color(hex: "0C0519"))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(Color(hex: "22172F"), lineWidth: 1.5)
                                )
                        )
                        .padding(.horizontal, 20)
                        .padding(.top, 8)

                if let errorMsg = degenVM.errorMessage {
                    Text(errorMsg)
                        .foregroundColor(.red)
                                        .font(.system(size: 12))
                        .padding()
                                }
                            }
                        } // Close the ZStack
                        
                        // Add spacing for floating buttons
                        Spacer()
                            .frame(height: 80)
                    }
                }
            }
            .navigationTitle("Trending")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack(spacing: 16) {
                        Button(action: {}) {
                            Image(systemName: "bell")
                                .foregroundColor(.white)
                                .font(.system(size: 16))
                        }
                        Button(action: {}) {
                            Image(systemName: "info.circle")
                                .foregroundColor(.white)
                                .font(.system(size: 16))
                        }
                    }
                }
            }
            .onAppear {
                fetchVerifiedTokenSet()
                Task { await degenVM.fetchLatestTokens() } // fetch trending tokens here
            }
            .sheet(item: $selectedToken) { token in
                TokenDetailModal(token: token) {
                    selectedToken = nil
                }
            }
            .background(Color(hex: "0C0519"))
            .overlay(
                // Floating Buy/Sell buttons positioned directly above tab bar
                VStack {
                    Spacer()
                    
                    HStack(spacing: 12) {
                        // DegenBuy button (left)
                        Button(action: {
                            // TODO: Implement buy action
                            print("DegenBuy tapped")
                        }) {
                            Text("BUY")
                                .font(.custom("Korosu", size: 18))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(
                                    ZStack {
                                        // Glow effect with blur
                                        RoundedRectangle(cornerRadius: 12)
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
                                            .blur(radius: 8)
                                            .opacity(0.8)
                                        
                                        // Main button with gradient
                                        RoundedRectangle(cornerRadius: 12)
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
                                            .shadow(color: Color(hex: "4F2FB6").opacity(0.8), radius: 12, x: 0, y: 0)
                                            .shadow(color: Color(hex: "9746F6").opacity(0.6), radius: 8, x: 0, y: 0)
                                            .shadow(color: Color(hex: "F7B0FE").opacity(0.4), radius: 4, x: 0, y: 0)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 12)
                                                    .stroke(Color.white.opacity(0.3), lineWidth: 1.5)
                                            )
                                    }
                                )
                        }
                        
                        // DegenSell button (right)
                        Button(action: {
                            // TODO: Implement sell action
                            print("DegenSell tapped")
                        }) {
                            Text("SELL")
                                .font(.custom("Korosu", size: 18))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(
                                            LinearGradient(
                                                gradient: Gradient(stops: [
                                                    .init(color: Color(hex: "130825"), location: 0.0),
                                                    .init(color: Color(hex: "4F2FB6"), location: 1.0)
                                                ]),
                                                startPoint: .top,
                                                endPoint: .bottom
                                            )
                                        )
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(Color(hex: "22172F"), lineWidth: 1.5)
                                        )
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(Color.white.opacity(0.2), lineWidth: 1.5)
                                        )
                                        .shadow(color: Color(hex: "4F2FB6").opacity(0.3), radius: 4, x: 0, y: 2)
                                )
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 10) // Position directly above tab bar
                }
            )
        }
    }

    private func fetchVerifiedTokenSet() {
        guard let url = URL(string: "https://lite-api.jup.ag/tokens/v1/tagged/verified") else { return }
        Task {
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                if let tokens = try? JSONDecoder().decode([DexScreenerTokenProfile].self, from: data) {
                    let verifiedAddresses = tokens.map { $0.tokenAddress }
                    await MainActor.run {
                        self.verifiedTokenSet = Set(verifiedAddresses)
                    }
                }
            } catch {
                print("Failed to fetch verified tokens: \(error)")
            }
        }
    }
}

struct TokenIconView: View {
    let token: DexScreenerTokenProfile
    
    var body: some View {
        AsyncImage(url: URL(string: token.icon ?? "")) { image in
            image
                .resizable()
                .scaledToFit()
                .frame(width: 32, height: 32)
        } placeholder: {
            // Fallback icon based on token address or chain
            Text(tokenSymbol)
                .font(.custom("Satoshi-Bold", size: 16))
                .foregroundColor(.white)
                .frame(width: 32, height: 32)
        }
        .frame(width: 40, height: 40)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(tokenBackgroundColor)
        )
        .clipShape(Circle())
    }
    
    private var tokenSymbol: String {
        // Extract symbol from token address or use chain ID
        let addressPrefix = token.tokenAddress.prefix(4).uppercased()
        return addressPrefix
    }
    
    private var tokenBackgroundColor: Color {
        // Use hardcoded colors for known tokens, fallback to generated color
        let addressPrefix = token.tokenAddress.prefix(4).uppercased()
        let chainId = token.chainId.lowercased()
        
        // Check for common token patterns in address
        if addressPrefix.contains("BTC") || chainId.contains("bitcoin") {
            return Color(red: 1.0, green: 0.58, blue: 0.0) // Bitcoin orange
        } else if addressPrefix.contains("ETH") || chainId.contains("ethereum") {
            return Color(red: 0.46, green: 0.48, blue: 0.9) // Ethereum blue
        } else if addressPrefix.contains("SOL") || chainId.contains("solana") {
            return Color(red: 0.0, green: 0.0, blue: 0.0) // Solana black
        } else if addressPrefix.contains("USDC") || addressPrefix.contains("USDT") {
            return Color(red: 0.0, green: 0.5, blue: 0.8) // USD stablecoin blue
        } else if addressPrefix.contains("DOGE") || chainId.contains("dogecoin") {
            return Color(red: 0.8, green: 0.6, blue: 0.0) // Dogecoin yellow
        } else if addressPrefix.contains("ADA") || chainId.contains("cardano") {
            return Color(red: 0.0, green: 0.5, blue: 0.8) // Cardano blue
        } else if addressPrefix.contains("XRP") || chainId.contains("ripple") {
            return Color(red: 0.0, green: 0.0, blue: 0.0) // XRP black
        } else {
            // Generate consistent color based on address hash
            return backgroundColorForSymbol(addressPrefix)
        }
    }
}

struct DegenTokenRow: View {
    let token: DexScreenerTokenProfile

    var body: some View {
        HStack(spacing: 12) {
            // Token Icon - Circular with proper sizing (like SpotTokenRow)
            TokenIconView(token: token)

            // Token Info - Left aligned (like SpotTokenRow)
            VStack(alignment: .leading, spacing: 2) {
                Text(token.tokenAddress.prefix(4).uppercased())
                    .font(.custom("Satoshi-Bold", size: 20))
                    .foregroundColor(.white)
                
                Text(token.chainId.uppercased())
                    .font(.custom("Satoshi-Medium", size: 16))
                    .foregroundColor(.gray)
            }

            Spacer()

            // Navigation Arrow - Right aligned (like SpotTokenRow)
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.gray)
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
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
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color(hex: "22172F"), lineWidth: 1.5)
                )
        )
        .onTapGesture {
            // Handle token selection
            print("Selected \(token.tokenAddress.prefix(4).uppercased())")
        }
    }
}

struct TokenDetailModal: View {
    let token: DexScreenerTokenProfile
    let dismiss: () -> Void  // Add this closure

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                AsyncImage(url: URL(string: token.icon ?? "")) { phase in
                    switch phase {
                    case .empty: ProgressView()
                    case .success(let img): img.resizable().scaledToFit()
                    case .failure: Image(systemName: "exclamationmark.triangle.fill")
                    @unknown default: EmptyView()
                    }
                }
                .frame(width: 100, height: 100)
                .clipShape(Circle())

                Text(token.tokenAddress)
                    .font(.headline)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)

                if let desc = token.description {
                    Text(desc)
                        .font(.body)
                        .padding()
                }

                VStack(spacing: 12) {
                    if let website = token.websiteURL {
                        Link(destination: website) {
                            Label("Website", systemImage: "globe")
                                .foregroundColor(.blue)
                        }
                    }
                    if let twitter = token.twitterURL {
                        Link(destination: twitter) {
                            Label("Twitter", systemImage: "bird")
                                .foregroundColor(.blue)
                        }
                    }
                    if let telegram = token.telegramURL {
                        Link(destination: telegram) {
                            Label("Telegram", systemImage: "paperplane")
                                .foregroundColor(.blue)
                        }
                    }
                }
                Spacer()
            }
            .padding()
            .navigationTitle("Token Details")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                        // Modal dismissal handled by .sheet environment
                        // Dismiss by setting selectedToken = nil in parent
                        // This button can call a closure if you pass one, or rely on default swipe down
                        
                    }
                }
            }
        }
    }
}


struct SpotTokenListView: View {
    let spotTokens = [
        SpotToken(symbol: "BTC", name: "Bitcoin", icon: "https://assets.coingecko.com/coins/images/1/large/bitcoin.png"),
        SpotToken(symbol: "SOL", name: "Solana", icon: "https://assets.coingecko.com/coins/images/4128/large/solana.png"),
        SpotToken(symbol: "ETH", name: "Ethereum", icon: "https://assets.coingecko.com/coins/images/279/large/ethereum.png"),
        SpotToken(symbol: "XRP", name: "XRP", icon: "https://assets.coingecko.com/coins/images/44/large/xrp-symbol-white-128.png"),
        SpotToken(symbol: "TRX", name: "TRON", icon: "https://assets.coingecko.com/coins/images/1094/large/tron-logo.png"),
        SpotToken(symbol: "ADA", name: "Cardano", icon: "https://assets.coingecko.com/coins/images/975/large/cardano.png")
    ]
    
    var body: some View {
        VStack(spacing: 12) {
            ForEach(spotTokens) { token in
                SpotTokenRow(token: token)
            }
        }
    }
}

struct SpotToken: Identifiable {
    let id = UUID()
    let symbol: String
    let name: String
    let icon: String
}

struct SpotTokenIconView: View {
    let token: SpotToken
    
    var body: some View {
        AsyncImage(url: URL(string: token.icon)) { image in
            image
                .resizable()
                .scaledToFit()
                .frame(width: 32, height: 32)
        } placeholder: {
            // Fallback icon with token symbol
            Text(token.symbol.prefix(2).uppercased())
                .font(.custom("Satoshi-Bold", size: 16))
                .foregroundColor(.white)
                .frame(width: 32, height: 32)
        }
        .frame(width: 40, height: 40)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(backgroundColorForSymbol(token.symbol))
        )
        .clipShape(Circle())
    }
}

struct SpotTokenRow: View {
    let token: SpotToken
    
    var body: some View {
        HStack(spacing: 12) {
            // Token Icon - Circular with proper sizing (like SpotView)
            SpotTokenIconView(token: token)
            
            // Token Info - Left aligned
            VStack(alignment: .leading, spacing: 2) {
                Text(token.symbol)
                    .font(.custom("Satoshi-Bold", size: 20))
                    .foregroundColor(.white)
                
                Text(token.name)
                    .font(.custom("Satoshi-Medium", size: 16))
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            // Navigation Arrow - Right aligned
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.gray)
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
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
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color(hex: "22172F"), lineWidth: 1.5)
                )
        )
        .onTapGesture {
            // Handle token selection
            print("Selected \(token.symbol)")
        }
    }
}


struct DegenTrendingView_Previews: PreviewProvider {
    static var previews: some View {
        DegenTrendingView()
            .preferredColorScheme(.dark)
    }
}
