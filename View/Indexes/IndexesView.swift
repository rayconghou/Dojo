import Foundation
import SwiftUI

// MARK: - Main Index View
struct IndexesView: View {
    var hamburgerAction: () -> Void
    @State private var selectedTab: IndexSourceTab = .teamPicks
    @StateObject private var viewModel = LeaderboardViewModel()
    @State private var showManekiQuizModal = false
    @State private var showCreateIndexSheet = false
    @State private var searchText = ""
    @State private var hasCompletedQuiz = false
    
    var body: some View {
        ZStack(alignment: .top) {
            // Background color
            Color(hex: "050715")
                .ignoresSafeArea(.all)
            
            VStack(spacing: 0) {
                // TopBar with profile, search, notifications, and hamburger menu
                TopBar(
                    searchText: $searchText,
                    onHamburgerTap: hamburgerAction,
                    onNotificationTap: {
                        // TODO: Implement notification action
                        print("Notification tapped")
                    },
                    onProfileTap: {
                        // TODO: Implement profile action
                        print("Profile tapped")
                    }
                )
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Header with title and create button
                        headerSection
                        
                        // My Indexes section
                        myIndexesSection
                        
                        // Tab Selection
                        tabSelectionSection
                        
                        // Content based on selected tab
                        contentSection
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                }
            }
            
            // Programmatic overlay effect - no asset imports, no layout breaking
            GeometryReader { geometry in
                ZStack {
                    // Subtle radial gradient overlay
                    RadialGradient(
                        gradient: Gradient(colors: [
                            Color.white.opacity(0.03),
                            Color.blue.opacity(0.01),
                            Color.clear
                        ]),
                        center: .topLeading,
                        startRadius: 50,
                        endRadius: 300
                    )
                    .ignoresSafeArea(.all)
                    
                    // Additional subtle pattern overlay
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.clear,
                            Color.white.opacity(0.015),
                            Color.clear
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .ignoresSafeArea(.all)
                }
            }
            .allowsHitTesting(false)
        }
        .blur(radius: showCreateIndexSheet ? 3 : 0)
        .animation(.easeInOut(duration: 0.3), value: showCreateIndexSheet)
        .sheet(isPresented: $showManekiQuizModal) {
            ManekiQuizModalView(hasCompletedQuiz: $hasCompletedQuiz)
        }
        .sheet(isPresented: $showCreateIndexSheet) {
            CreateIndexView(
                selectedTab: $selectedTab,
                leaderboardVM: viewModel,
                isPresented: $showCreateIndexSheet
            )
        }
    }
    
    // MARK: - UI Components
    
    private var headerSection: some View {
        HStack {
            Text("Indexes")
                .font(.custom("Satoshi-Bold", size: 32))
                .foregroundColor(.white)
            
            Spacer()
            
            Button(action: {
                showCreateIndexSheet = true
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "plus")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                    
                    Text("Create Index")
                        .font(.custom("Satoshi-Bold", size: 16))
                        .foregroundColor(.white)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color(hex: "141628"))
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.white.opacity(0.1), lineWidth: 1)
                        )
                )
            }
        }
        .padding(.top, 20)
    }
    
    private var myIndexesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("My Indexes")
                .font(.custom("Satoshi-Bold", size: 20))
                .foregroundColor(.white)
            
            VStack(spacing: 0) {
                // AI James Select (Positive)
                MyIndexCard(
                    profileImage: "Profile",
                    indexName: "AI James Select",
                    creator: "by @jameswang",
                    value: "$12.23",
                    change: "▲ 1,12%",
                    isPositive: true
                )
                
                // AI James Select (Negative)
                MyIndexCard(
                    profileImage: "User",
                    indexName: "AI James Select",
                    creator: "by @jameswang",
                    value: "$117 176,16",
                    change: "▼ 1,12%",
                    isPositive: false
                )
            }
        }
    }
    
    private var tabSelectionSection: some View {
        HStack(spacing: 0) {
            ForEach(Array(IndexSourceTab.allCases.enumerated()), id: \.element) { index, tab in
                tabButton(for: tab, isFirst: index == 0, isLast: index == IndexSourceTab.allCases.count - 1)
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.gray.opacity(0.2))
        )
        .padding(.vertical, 12)
    }
    
    private func tabButton(for tab: IndexSourceTab, isFirst: Bool, isLast: Bool) -> some View {
        Button(action: {
            withAnimation(.easeInOut) {
                selectedTab = tab
            }
        }) {
            Text(tab.rawValue)
                .font(.custom("Satoshi-Bold", size: 14))
                .foregroundColor(selectedTab == tab ? .white : .gray)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(tabBackground(for: tab, isFirst: isFirst, isLast: isLast))
        }
    }
    
    private func tabBackground(for tab: IndexSourceTab, isFirst: Bool, isLast: Bool) -> some View {
        Group {
            if selectedTab == tab {
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 0.2, green: 0.5, blue: 1.0),
                        Color(red: 0.1, green: 0.3, blue: 0.8)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .clipShape(
                    TabSelectionShape(
                        cornerRadius: 8,
                        isFirst: isFirst,
                        isLast: isLast
                    )
                )
            } else {
                Color.clear
            }
        }
    }
    
    private var contentSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            switch selectedTab {
            case .teamPicks:
                teamPicksContent
            case .manekiQuiz:
                manekiQuizContent
            case .community:
                communityContent
            }
        }
    }
    
    private var teamPicksContent: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Recommended For You")
                .font(.custom("Satoshi-Bold", size: 20))
                .foregroundColor(.white)
            
            VStack(spacing: 12) {
                // Income Builder
                RecommendedIndexCard(
                    indexName: "Income Builder",
                    value: "$1 428,67",
                    change: "-$705,70 ▼ 1,32% • Today",
                    isPositive: false
                )
                
                // Growth Portfolio
                RecommendedIndexCard(
                    indexName: "Growth Portfolio",
                    value: "$785,32",
                    change: "+$293,70 ▲ 1,32% • Today",
                    isPositive: true
                )
                
                // Balanced Strategy
                RecommendedIndexCard(
                    indexName: "Balanced Strategy",
                    value: "$2 432.89",
                    change: "+$293,70 ▲ 1,32% • Today",
                    isPositive: true
                )
            }
        }
    }
    
    private var manekiQuizContent: some View {
        VStack(alignment: .leading, spacing: 16) {
            Button(action: {
                showManekiQuizModal = true
            }) {
                HStack {
                    Image("SealQuestion")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                    
                    Text("Take Maneki's Investment Quiz")
                        .font(.custom("Satoshi-Bold", size: 18))
                        .foregroundColor(.black)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.up")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.black)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.white)
                )
            }
            
            // Show recommended indexes after quiz completion
            if hasCompletedQuiz {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Recommended For You")
                        .font(.custom("Satoshi-Bold", size: 20))
                        .foregroundColor(.white)
                    
                    VStack(spacing: 12) {
                        // Income Builder
                        RecommendedIndexCard(
                            indexName: "Income Builder",
                            value: "$1 428,67",
                            change: "-$705,70 ▼ 1,32% • Today",
                            isPositive: false
                        )
                        
                        // Growth Portfolio
                        RecommendedIndexCard(
                            indexName: "Growth Portfolio",
                            value: "$785,32",
                            change: "+$293,70 ▲ 1,32% • Today",
                            isPositive: true
                        )
                        
                        // Balanced Strategy
                        RecommendedIndexCard(
                            indexName: "Balanced Strategy",
                            value: "$2 432.89",
                            change: "+$293,70 ▲ 1,32% • Today",
                            isPositive: true
                        )
                    }
                }
            }
        }
    }
    
    private var communityContent: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Leaderboard")
                .font(.custom("Satoshi-Bold", size: 20))
                .foregroundColor(.white)
            
            VStack(spacing: 12) {
                // Community Index 1
                CommunityIndexCard(
                    rank: 1,
                    indexName: "Community Index 1",
                    creator: "by @dojouser123",
                    roi: "▲ 24.8% ROI"
                )
                
                // Community Index 2
                CommunityIndexCard(
                    rank: 2,
                    indexName: "Community Index 2",
                    creator: "by @dojouser123",
                    roi: "▲ 22.3% ROI"
                )
                
                // Community Index 3
                CommunityIndexCard(
                    rank: 3,
                    indexName: "Community Index 3",
                    creator: "by @dojouser123",
                    roi: "▲ 19.7% ROI"
                )
                
                // Community Index 4
                CommunityIndexCard(
                    rank: 4,
                    indexName: "Community Index 4",
                    creator: "by @dojouser123",
                    roi: "▲ 16.2% ROI"
                )
                
                // Community Index 5
                CommunityIndexCard(
                    rank: 5,
                    indexName: "Community Index 5",
                    creator: "by @dojouser123",
                    roi: "▲ 15.1% ROI"
                )
            }
        }
    }
}

// MARK: - Tab Selection Shape
struct TabSelectionShape: Shape {
    let cornerRadius: CGFloat
    let isFirst: Bool
    let isLast: Bool
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let topLeft = isFirst ? cornerRadius : 0
        let topRight = isLast ? cornerRadius : 0
        let bottomLeft = isFirst ? cornerRadius : 0
        let bottomRight = isLast ? cornerRadius : 0
        
        // Start from top-left
        path.move(to: CGPoint(x: topLeft, y: 0))
        
        // Top edge
        if isFirst && isLast {
            // Both corners rounded - single tab
            path.addLine(to: CGPoint(x: rect.width - topRight, y: 0))
        } else if isFirst {
            // Left corner rounded
            path.addLine(to: CGPoint(x: rect.width, y: 0))
        } else if isLast {
            // Right corner rounded
            path.addLine(to: CGPoint(x: rect.width - topRight, y: 0))
        } else {
            // No corners rounded - middle tab
            path.addLine(to: CGPoint(x: rect.width, y: 0))
        }
        
        // Top-right corner
        if isLast {
            path.addQuadCurve(
                to: CGPoint(x: rect.width, y: topRight),
                control: CGPoint(x: rect.width, y: 0)
            )
        }
        
        // Right edge
        path.addLine(to: CGPoint(x: rect.width, y: rect.height - bottomRight))
        
        // Bottom-right corner
        if isLast {
            path.addQuadCurve(
                to: CGPoint(x: rect.width - bottomRight, y: rect.height),
                control: CGPoint(x: rect.width, y: rect.height)
            )
        }
        
        // Bottom edge
        if isFirst && isLast {
            // Both corners rounded - single tab
            path.addLine(to: CGPoint(x: bottomLeft, y: rect.height))
        } else if isFirst {
            // Left corner rounded
            path.addLine(to: CGPoint(x: bottomLeft, y: rect.height))
        } else if isLast {
            // Right corner rounded
            path.addLine(to: CGPoint(x: 0, y: rect.height))
        } else {
            // No corners rounded - middle tab
            path.addLine(to: CGPoint(x: 0, y: rect.height))
        }
        
        // Bottom-left corner
        if isFirst {
            path.addQuadCurve(
                to: CGPoint(x: 0, y: rect.height - bottomLeft),
                control: CGPoint(x: 0, y: rect.height)
            )
        }
        
        // Left edge
        path.addLine(to: CGPoint(x: 0, y: topLeft))
        
        // Top-left corner
        if isFirst {
            path.addQuadCurve(
                to: CGPoint(x: topLeft, y: 0),
                control: CGPoint(x: 0, y: 0)
            )
        }
        
        path.closeSubpath()
        return path
    }
}

// MARK: - Index Source Tab Enum
enum IndexSourceTab: String, CaseIterable {
    case teamPicks = "Team Picks"
    case manekiQuiz = "Maneki Quiz"
    case community = "Community"
}

// MARK: - Data Models for Index Detail Modal
struct IndexDetail: Identifiable {
    let id = UUID()
    let name: String
    let creator: String
    let description: String
    let currentPrice: Double
    let roi: Double
    let composition: [AssetComposition]
    let priceHistory: [PriceHistoryEntry]
    let marketCap: String
    let volume24h: String
    let circulatingSupply: String
    let maxSupply: String
    let allTimeHigh: String
    let popularity: String
}

struct AssetComposition: Identifiable {
    let id = UUID()
    let name: String
    let symbol: String
    let allocation: Double
    let imageUrl: String
}


// MARK: - Mock Data
extension IndexDetail {
    static let mockData: [IndexDetail] = [
        IndexDetail(
            name: "Fortune AI Select",
            creator: "Dojo Team",
            description: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Maecenas eget lacus ac nibh elementum volutpat aliquam in metus. Nullam in massa egestas, placerat justo nec, rutrum erat.",
            currentPrice: 117176.16,
            roi: 11.2,
            composition: [
                AssetComposition(name: "XRP", symbol: "XRP", allocation: 40, imageUrl: "https://assets.coingecko.com/coins/images/44/large/xrp-symbol-white-128.png"),
                AssetComposition(name: "Ethereum", symbol: "ETH", allocation: 30, imageUrl: "https://assets.coingecko.com/coins/images/279/large/ethereum.png"),
                AssetComposition(name: "Bitcoin", symbol: "BTC", allocation: 30, imageUrl: "https://assets.coingecko.com/coins/images/1/large/bitcoin.png")
            ],
            priceHistory: [
                PriceHistoryEntry(date: "Apr 09", price: 117176.16),
                PriceHistoryEntry(date: "Apr 08", price: 118611.15),
                PriceHistoryEntry(date: "Apr 07", price: 114497.52),
                PriceHistoryEntry(date: "Apr 06", price: 112927.92)
            ],
            marketCap: "$1.2T",
            volume24h: "$48.2B",
            circulatingSupply: "19.4M BTC",
            maxSupply: "21M BTC",
            allTimeHigh: "$119 176,16",
            popularity: "#1 Most held"
        ),
        IndexDetail(
            name: "AI James Select",
            creator: "James Wang",
            description: "A carefully curated selection of AI-focused cryptocurrencies and blockchain projects that are driving innovation in artificial intelligence and machine learning applications.",
            currentPrice: 12345.67,
            roi: 8.5,
            composition: [
                AssetComposition(name: "Ethereum", symbol: "ETH", allocation: 35, imageUrl: "https://assets.coingecko.com/coins/images/279/large/ethereum.png"),
                AssetComposition(name: "Cardano", symbol: "ADA", allocation: 25, imageUrl: "https://assets.coingecko.com/coins/images/975/large/cardano.png"),
                AssetComposition(name: "Chainlink", symbol: "LINK", allocation: 20, imageUrl: "https://assets.coingecko.com/coins/images/877/large/chainlink-new-logo.png"),
                AssetComposition(name: "Polygon", symbol: "MATIC", allocation: 20, imageUrl: "https://assets.coingecko.com/coins/images/4713/large/matic-token-icon.png")
            ],
            priceHistory: [
                PriceHistoryEntry(date: "Apr 09", price: 12345.67),
                PriceHistoryEntry(date: "Apr 08", price: 12123.45),
                PriceHistoryEntry(date: "Apr 07", price: 11987.32),
                PriceHistoryEntry(date: "Apr 06", price: 11876.54)
            ],
            marketCap: "$850B",
            volume24h: "$32.1B",
            circulatingSupply: "120.2M ETH",
            maxSupply: "∞ ETH",
            allTimeHigh: "$4,891.70",
            popularity: "#3 Most held"
        ),
        IndexDetail(
            name: "Income Builder",
            creator: "Sarah Chen",
            description: "A diversified portfolio focused on yield-generating assets and staking rewards, designed for steady income generation in the crypto market.",
            currentPrice: 9876.54,
            roi: 6.8,
            composition: [
                AssetComposition(name: "Ethereum", symbol: "ETH", allocation: 30, imageUrl: "https://assets.coingecko.com/coins/images/279/large/ethereum.png"),
                AssetComposition(name: "Solana", symbol: "SOL", allocation: 25, imageUrl: "https://assets.coingecko.com/coins/images/4128/large/solana.png"),
                AssetComposition(name: "Avalanche", symbol: "AVAX", allocation: 20, imageUrl: "https://assets.coingecko.com/coins/images/12559/large/Avalanche_Circle_RedWhite_Trans.png"),
                AssetComposition(name: "Polkadot", symbol: "DOT", allocation: 15, imageUrl: "https://assets.coingecko.com/coins/images/12171/large/polkadot.png"),
                AssetComposition(name: "Cosmos", symbol: "ATOM", allocation: 10, imageUrl: "https://assets.coingecko.com/coins/images/1481/large/cosmos_hub.png")
            ],
            priceHistory: [
                PriceHistoryEntry(date: "Apr 09", price: 9876.54),
                PriceHistoryEntry(date: "Apr 08", price: 9754.32),
                PriceHistoryEntry(date: "Apr 07", price: 9632.10),
                PriceHistoryEntry(date: "Apr 06", price: 9510.88)
            ],
            marketCap: "$420B",
            volume24h: "$18.5B",
            circulatingSupply: "450.2M SOL",
            maxSupply: "∞ SOL",
            allTimeHigh: "$260.06",
            popularity: "#5 Most held"
        ),
        IndexDetail(
            name: "Growth Portfolio",
            creator: "Mike Rodriguez",
            description: "High-growth potential cryptocurrencies and emerging blockchain projects with strong fundamentals and innovative technology solutions.",
            currentPrice: 5432.10,
            roi: 15.3,
            composition: [
                AssetComposition(name: "Bitcoin", symbol: "BTC", allocation: 40, imageUrl: "https://assets.coingecko.com/coins/images/1/large/bitcoin.png"),
                AssetComposition(name: "Ethereum", symbol: "ETH", allocation: 30, imageUrl: "https://assets.coingecko.com/coins/images/279/large/ethereum.png"),
                AssetComposition(name: "Binance Coin", symbol: "BNB", allocation: 15, imageUrl: "https://assets.coingecko.com/coins/images/825/large/bnb-icon2_2x.png"),
                AssetComposition(name: "XRP", symbol: "XRP", allocation: 15, imageUrl: "https://assets.coingecko.com/coins/images/44/large/xrp-symbol-white-128.png")
            ],
            priceHistory: [
                PriceHistoryEntry(date: "Apr 09", price: 5432.10),
                PriceHistoryEntry(date: "Apr 08", price: 5287.65),
                PriceHistoryEntry(date: "Apr 07", price: 5143.20),
                PriceHistoryEntry(date: "Apr 06", price: 4998.75)
            ],
            marketCap: "$95B",
            volume24h: "$2.1B",
            circulatingSupply: "153.8M BNB",
            maxSupply: "200M BNB",
            allTimeHigh: "$686.31",
            popularity: "#7 Most held"
        ),
        IndexDetail(
            name: "Balanced Strategy",
            creator: "Emma Thompson",
            description: "A well-balanced mix of established cryptocurrencies and promising altcoins, designed for moderate risk with steady growth potential.",
            currentPrice: 8765.43,
            roi: 9.7,
            composition: [
                AssetComposition(name: "Bitcoin", symbol: "BTC", allocation: 35, imageUrl: "https://assets.coingecko.com/coins/images/1/large/bitcoin.png"),
                AssetComposition(name: "Ethereum", symbol: "ETH", allocation: 25, imageUrl: "https://assets.coingecko.com/coins/images/279/large/ethereum.png"),
                AssetComposition(name: "Litecoin", symbol: "LTC", allocation: 15, imageUrl: "https://assets.coingecko.com/coins/images/2/large/litecoin.png"),
                AssetComposition(name: "Bitcoin Cash", symbol: "BCH", allocation: 15, imageUrl: "https://assets.coingecko.com/coins/images/780/large/bitcoin-cash.png"),
                AssetComposition(name: "Dogecoin", symbol: "DOGE", allocation: 10, imageUrl: "https://assets.coingecko.com/coins/images/5/large/dogecoin.png")
            ],
            priceHistory: [
                PriceHistoryEntry(date: "Apr 09", price: 8765.43),
                PriceHistoryEntry(date: "Apr 08", price: 8643.21),
                PriceHistoryEntry(date: "Apr 07", price: 8521.09),
                PriceHistoryEntry(date: "Apr 06", price: 8398.97)
            ],
            marketCap: "$180B",
            volume24h: "$8.7B",
            circulatingSupply: "74.2M LTC",
            maxSupply: "84M LTC",
            allTimeHigh: "$412.96",
            popularity: "#9 Most held"
        )
    ]
}

// MARK: - Index Detail Modal
struct IndexDetailModalView: View {
    let index: IndexDetail
    @Environment(\.dismiss) private var dismiss
    @State private var selectedTimeFrame: TimeFrame = .oneDay
    @State private var showBuySheet = false
    @State private var showSellSheet = false
    
    var body: some View {
        ZStack {
            // Background
            Color(hex: "050715")
                .ignoresSafeArea(.all)
            
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    headerSection
                    
                    // Index Description
                    descriptionSection
                    
                    // Index Graph
                    indexGraphSection
                    
                    // Resume Section
                    resumeSection
                    
                    // Index Composition
                    indexCompositionSection
                    
                    // Price History
                    priceHistorySection
                    
                    // Market Stats
                    marketStatsSection
                    
                    // Action Buttons
                    actionButtonsSection
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
            }
        }
        .sheet(isPresented: $showBuySheet) {
            BuyIndexSheet(index: index)
        }
        .sheet(isPresented: $showSellSheet) {
            SellIndexSheet(index: index)
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        HStack {
            // RedLogo icon
            Image("RedLogo")
                .resizable()
                .scaledToFit()
                .frame(width: 40, height: 40)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.red)
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Fortune AI Select")
                    .font(.custom("Satoshi-Bold", size: 20))
                    .foregroundColor(.white)
                
                Text("by Dojo Team")
                    .font(.custom("Satoshi-Medium", size: 14))
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            // Dismiss button
            Button(action: {
                dismiss()
            }) {
                Image(systemName: "chevron.down")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
            }
        }
        .padding(.top, 8)
    }
    
    // MARK: - Description Section
    private var descriptionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(index.name)
                .font(.custom("Satoshi-Bold", size: 20))
                .foregroundColor(.white)
            
            Text(index.description)
                .font(.custom("Satoshi-Regular", size: 14))
                .foregroundColor(.gray)
                .lineLimit(nil)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    // MARK: - Index Graph Section
    private var indexGraphSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Index Graph")
                .font(.custom("Satoshi-Bold", size: 18))
                .foregroundColor(.white)
            
            VStack(spacing: 16) {
                // Graph Container
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(hex: "141628"))
                        .frame(height: 200)
                    
                    // Sparkline Chart
                    SparklineChartView(
                        data: index.priceHistory.map { $0.price },
                        isPositive: index.roi >= 0
                    )
                }
                
                // Time Frame Selector
                HStack(spacing: 0) {
                    ForEach([TimeFrame.oneDay, .oneWeek, .oneMonth, .oneYear, .all], id: \.self) { timeFrame in
                        Button(action: {
                            selectedTimeFrame = timeFrame
                        }) {
                            Text(timeFrame.rawValue)
                                .font(.custom("Satoshi-Bold", size: 14))
                                .foregroundColor(selectedTimeFrame == timeFrame ? .white : .gray)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(
                                    RoundedRectangle(cornerRadius: 6)
                                        .fill(selectedTimeFrame == timeFrame ? Color.white.opacity(0.2) : Color.clear)
                                )
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Resume Section
    private var resumeSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Resume")
                .font(.custom("Satoshi-Bold", size: 18))
                .foregroundColor(.white)
            
            HStack(spacing: 16) {
                // Icon
                Image("ROI")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 40, height: 40)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Index ROI")
                        .font(.custom("Satoshi-Bold", size: 16))
                        .foregroundColor(.white)
                    
                    Text("Return on Investment")
                        .font(.custom("Satoshi-Regular", size: 12))
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                Text("▲ \(String(format: "%.1f", index.roi))%")
                    .font(.custom("Satoshi-Bold", size: 18))
                    .foregroundColor(.green)
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(hex: "141628"))
            )
        }
    }
    
    // MARK: - Index Composition Section
    private var indexCompositionSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Index Composition")
                .font(.custom("Satoshi-Bold", size: 18))
                .foregroundColor(.white)
            
            VStack(spacing: 12) {
                ForEach(index.composition, id: \.symbol) { asset in
                    HStack(spacing: 12) {
                        // Asset Icon with AsyncImage
                        AsyncImage(url: URL(string: asset.imageUrl)) { image in
                            image
                                .resizable()
                                .scaledToFit()
                                .frame(width: 32, height: 32)
                        } placeholder: {
                            RoundedRectangle(cornerRadius: 6)
                                .fill(Color.gray.opacity(0.3))
                                .frame(width: 32, height: 32)
                        }
                        .frame(width: 40, height: 40)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(backgroundColorForSymbol(asset.symbol))
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(asset.name)
                                .font(.custom("Satoshi-Bold", size: 16))
                                .foregroundColor(.white)
                            
                            Text(asset.symbol)
                                .font(.custom("Satoshi-Medium", size: 14))
                                .foregroundColor(.gray)
                        }
                        
                        Spacer()
                        
                        Text("\(Int(asset.allocation))%")
                            .font(.custom("Satoshi-Bold", size: 16))
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color(hex: "1A1C2E"))
                    )
                }
            }
        }
    }
    
    // MARK: - Price History Section
    private var priceHistorySection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Price History")
                .font(.custom("Satoshi-Bold", size: 18))
                .foregroundColor(.white)
            
            VStack(spacing: 12) {
                ForEach(index.priceHistory.prefix(4), id: \.date) { entry in
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(entry.date)
                                .font(.custom("Satoshi-Bold", size: 14))
                                .foregroundColor(.white)
                            
                            Text("1 BTC")
                                .font(.custom("Satoshi-Medium", size: 12))
                                .foregroundColor(.gray)
                        }
                        
                        Spacer()
                        
                        Text("$\(String(format: "%.2f", entry.price))")
                            .font(.custom("Satoshi-Bold", size: 14))
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                }
                
                Button(action: {
                    // Show more history
                }) {
                    Text("See Last 30 Days >")
                        .font(.custom("Satoshi-Bold", size: 14))
                        .foregroundColor(.blue)
                }
                .padding(.top, 8)
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(hex: "141628"))
            )
        }
    }
    
    // MARK: - Market Stats Section
    private var marketStatsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Market Stats")
                .font(.custom("Satoshi-Bold", size: 18))
                .foregroundColor(.white)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                MarketStatCard(title: "Market Cap", value: index.marketCap)
                MarketStatCard(title: "24h Volume", value: index.volume24h)
                MarketStatCard(title: "Circulating Supply", value: index.circulatingSupply)
                MarketStatCard(title: "Max Supply", value: index.maxSupply)
                MarketStatCard(title: "All-Time High", value: index.allTimeHigh)
                MarketStatCard(title: "Popularity", value: index.popularity)
            }
        }
    }
    
    // MARK: - Action Buttons Section
    private var actionButtonsSection: some View {
        HStack(spacing: 16) {
            Button(action: {
                showBuySheet = true
            }) {
                Text("Buy")
                    .font(.custom("Satoshi-Bold", size: 16))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(LinearGradient(
                                gradient: Gradient(colors: [
                                    Color(red: 0.2, green: 0.5, blue: 1.0),      // Bright blue
                                    Color(red: 0.1, green: 0.3, blue: 0.8)       // Darker blue
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ))
                    )
            }
            
            Button(action: {
                showSellSheet = true
            }) {
                Text("Sell")
                    .font(.custom("Satoshi-Bold", size: 16))
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.white)
                    )
            }
        }
        .padding(.top, 8)
    }
    
    // MARK: - Helper Functions
}


// MARK: - Market Stat Card
struct MarketStatCard: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.custom("Satoshi-Medium", size: 12))
                .foregroundColor(.gray)
            
            Text(value)
                .font(.custom("Satoshi-Bold", size: 16))
                .foregroundColor(.white)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(hex: "1A1C2E"))
        )
    }
}

// MARK: - Buy/Sell Sheets
struct BuyIndexSheet: View {
    let index: IndexDetail
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        BuyScreenView(coin: nil, asset: nil)
    }
}

struct SellIndexSheet: View {
    let index: IndexDetail
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack {
            Text("Sell \(index.name)")
                .font(.custom("Satoshi-Bold", size: 20))
                .foregroundColor(.white)
                .padding()
            
            Spacer()
            
            Text("Sell functionality coming soon")
                .font(.custom("Satoshi-Regular", size: 16))
                .foregroundColor(.gray)
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(hex: "050715"))
    }
}

// MARK: - My Index Card Component
struct MyIndexCard: View {
    let profileImage: String
    let indexName: String
    let creator: String
    let value: String
    let change: String
    let isPositive: Bool
    @State private var showDetailModal = false
    
    var body: some View {
        Button(action: {
            showDetailModal = true
        }) {
            ZStack {
                HStack(spacing: 12) {
                    // Profile image
                    if profileImage == "User" {
                        Image(profileImage)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 24, height: 24)
                            .padding(8)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color(hex: "272A45"))
                            )
                    } else {
                        Image(profileImage)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 40, height: 40)
                            .clipShape(Circle())
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(indexName)
                            .font(.custom("Satoshi-Bold", size: 16))
                            .foregroundColor(.white)
                        
                        Text(creator)
                            .font(.custom("Satoshi-Bold", size: 14))
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        Text(value)
                            .font(.custom("Satoshi-Bold", size: 16))
                            .foregroundColor(.white)
                        
                        Text(change)
                            .font(.custom("Satoshi-Bold", size: 14))
                            .foregroundColor(isPositive ? .green : .red)
                    }
                }
                .padding(16)
                .background(Color(hex: "141628"))
                .cornerRadius(12)
                
                // Chevron in top right corner
                VStack {
                    HStack {
                        Spacer()
                        Image(systemName: "chevron.up")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.gray)
                    }
                    Spacer()
                }
                .padding(16)
            }
        }
        .buttonStyle(PlainButtonStyle())
        .sheet(isPresented: $showDetailModal) {
            IndexDetailModalView(index: getIndexDetail(for: indexName))
        }
    }
    
    private func getIndexDetail(for name: String) -> IndexDetail {
        return IndexDetail.mockData.first { $0.name == name } ?? IndexDetail.mockData[0]
    }
}

// MARK: - Team Index Card Component
struct TeamIndexCard: View {
    let indexName: String
    let value: String
    let change: String
    let isPositive: Bool
    @State private var showDetailModal = false
    
    var body: some View {
        Button(action: {
            showDetailModal = true
        }) {
            ZStack {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(indexName)
                                .font(.custom("Satoshi-Bold", size: 16))
                                .foregroundColor(.white)
                            
                            Text(value)
                                .font(.custom("Satoshi-Bold", size: 24))
                                .foregroundColor(.white)
                            
                            HStack(spacing: 4) {
                                Text(change.components(separatedBy: " • ").first ?? change)
                                    .font(.custom("Satoshi-Bold", size: 14))
                                    .foregroundColor(isPositive ? .green : .red)
                                
                                if change.contains("•") {
                                    Text("• Today")
                                        .font(.custom("Satoshi-Bold", size: 14))
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                        
                        Spacer()
                    }
                    
                    // Sparkline Chart with extrapolation
                    SparklineChartView(data: generateMockSparklineData(), isPositive: isPositive)
                        .frame(height: 60)
                }
                .padding(16)
                .background(Color(hex: "141628"))
                .cornerRadius(12)
                
                // Chevron in top right corner
                VStack {
                    HStack {
                        Spacer()
                        Image(systemName: "chevron.up")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.gray)
                    }
                    Spacer()
                }
                .padding(16)
            }
        }
        .buttonStyle(PlainButtonStyle())
        .sheet(isPresented: $showDetailModal) {
            IndexDetailModalView(index: getIndexDetail(for: indexName))
        }
    }
    
    private func getIndexDetail(for name: String) -> IndexDetail {
        return IndexDetail.mockData.first { $0.name == name } ?? IndexDetail.mockData[0]
    }
    
    // Helper function to generate mock sparkline data
    private func generateMockSparklineData() -> [Double] {
        // Generate more data points for better chart coverage
        let dataPoints = 50
        var data: [Double] = []
        var currentValue = Double.random(in: 20...80)
        
        for _ in 0..<dataPoints {
            // Create a more realistic trend with some randomness
            let trend = isPositive ? 0.5 : -0.3
            let randomChange = Double.random(in: -2...2)
            currentValue += trend + randomChange
            currentValue = max(0, min(100, currentValue)) // Keep within bounds
            data.append(currentValue)
        }
        
        return data
    }
}

// MARK: - Community Index Card Component
struct CommunityIndexCard: View {
    let rank: Int
    let indexName: String
    let creator: String
    let roi: String
    @State private var showDetailModal = false
    
    var body: some View {
        Button(action: {
            showDetailModal = true
        }) {
            ZStack {
                HStack(spacing: 12) {
                    // Rank number
                    Text("#\(rank)")
                        .font(.custom("Satoshi-Bold", size: 16))
                        .foregroundColor(.white)
                        .frame(width: 30, alignment: .leading)
                    
                    // Profile icon
                    Image(systemName: "person.circle")
                        .font(.system(size: 24))
                        .foregroundColor(.white)
                        .frame(width: 40, height: 40)
                        .background(Color.gray.opacity(0.2))
                        .clipShape(Circle())
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(indexName)
                            .font(.custom("Satoshi-Bold", size: 14))
                            .foregroundColor(.white)
                            .lineLimit(1)
                        
                        Text(creator)
                            .font(.custom("Satoshi-Bold", size: 12))
                            .foregroundColor(.gray)
                            .lineLimit(1)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        Text(roi)
                            .font(.custom("Satoshi-Bold", size: 14))
                            .foregroundColor(.green)
                            .lineLimit(1)
                    }
                }
                .padding(16)
                .background(Color(hex: "141628"))
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
                
                // Chevron in top right corner
                VStack {
                    HStack {
                        Spacer()
                        Image(systemName: "chevron.up")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.gray)
                    }
                    Spacer()
                }
                .padding(16)
            }
        }
        .buttonStyle(PlainButtonStyle())
        .sheet(isPresented: $showDetailModal) {
            IndexDetailModalView(index: getIndexDetail(for: indexName))
        }
    }
    
    private func getIndexDetail(for name: String) -> IndexDetail {
        return IndexDetail.mockData.first { $0.name == name } ?? IndexDetail.mockData[0]
    }
}

// MARK: - Recommended Index Card Component
struct RecommendedIndexCard: View {
    let indexName: String
    let value: String
    let change: String
    let isPositive: Bool
    @State private var showDetailModal = false
    
    var body: some View {
        Button(action: {
            showDetailModal = true
        }) {
            ZStack {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(indexName)
                                .font(.custom("Satoshi-Bold", size: 16))
                                .foregroundColor(.white)
                            
                            Text(value)
                                .font(.custom("Satoshi-Bold", size: 24))
                                .foregroundColor(.white)
                            
                            HStack(spacing: 4) {
                                Text(change.components(separatedBy: " • ").first ?? change)
                                    .font(.custom("Satoshi-Bold", size: 14))
                                    .foregroundColor(isPositive ? .green : .red)
                                
                                if change.contains("•") {
                                    Text("• Today")
                                        .font(.custom("Satoshi-Bold", size: 14))
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                        
                        Spacer()
                    }
                    
                    // Sparkline Chart with extrapolation
                    SparklineChartView(data: generateMockSparklineData(), isPositive: isPositive)
                        .frame(height: 60)
                }
                .padding(16)
                .background(Color(hex: "141628"))
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
                
                // Chevron in top right corner
                VStack {
                    HStack {
                        Spacer()
                        Image(systemName: "chevron.up")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.gray)
                    }
                    Spacer()
                }
                .padding(16)
            }
        }
        .buttonStyle(PlainButtonStyle())
        .sheet(isPresented: $showDetailModal) {
            IndexDetailModalView(index: getIndexDetail(for: indexName))
        }
    }
    
    private func getIndexDetail(for name: String) -> IndexDetail {
        return IndexDetail.mockData.first { $0.name == name } ?? IndexDetail.mockData[0]
    }
    
    // Helper function to generate mock sparkline data
    private func generateMockSparklineData() -> [Double] {
        // Generate more data points for better chart coverage
        let dataPoints = 50
        var data: [Double] = []
        var currentValue = Double.random(in: 20...80)
        
        for _ in 0..<dataPoints {
            // Create a more realistic trend with some randomness
            let trend = isPositive ? 0.5 : -0.3
            let randomChange = Double.random(in: -2...2)
            currentValue += trend + randomChange
            currentValue = max(0, min(100, currentValue)) // Keep within bounds
            data.append(currentValue)
        }
        
        return data
    }
}


// MARK: - Community Indexes Tab
struct CommunityIndexesView: View {
    @State private var selectedTimeFrame: TimeFrame = .month
    @Binding var showCreateIndexSheet: Bool
    @ObservedObject var viewModel: LeaderboardViewModel
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Leaderboard")
                    .font(.headline)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                TimeFrameSelector(selected: $selectedTimeFrame)
            }
            .padding(.top, 8)
            
            // Leaderboard Header
            HStack {
                Text("Rank")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .frame(width: 40, alignment: .leading)
                
                Text("Index Name")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Text("ROI")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .frame(width: 80, alignment: .trailing)
                
                Text("Creator")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .frame(width: 80, alignment: .trailing)
            }
            .padding(.horizontal, 8)
            
            Text("Leaderboard count: \(viewModel.leaderboard.count)")
                .foregroundColor(.green)
            
            ForEach(Array(viewModel.leaderboard.prefix(5).enumerated()), id: \.element.id) { index, item in
                LeaderboardItem(
                    rank: index + 1,
                    name: item.index_name,
                    roi: item.formattedROI,
                    creator: item.creator
                )
            }
            
            Button(action: {
                showCreateIndexSheet = true
            }) {
                HStack {
                    Image(systemName: "plus.circle.fill")
                    Text("Create Your Own Index")
                    Spacer()
                    Text("+20% Token Rewards")
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.green.opacity(0.2))
                        .cornerRadius(8)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(UIColor.tertiarySystemBackground))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.accentColor, lineWidth: 1)
                )
            }
            .foregroundColor(.primary)
            .padding(.top, 8)
            
            Spacer(minLength: 50)
        }
        .onAppear {
            print("community indexes appeard")
            viewModel.fetchLeaderboard()
        }
    }
}

// Time frame for leaderboard and modals
enum TimeFrame: String, CaseIterable {
    case oneDay = "1D"
    case oneWeek = "1W"
    case oneMonth = "1M"
    case oneYear = "1Y"
    case all = "All"
    case week = "Week"
    case month = "Month"
    case year = "Year"
}

struct TimeFrameSelector: View {
    @Binding var selected: TimeFrame
    
    var body: some View {
        HStack(spacing: 2) {
            ForEach(TimeFrame.allCases, id: \.self) { timeFrame in
                Button(action: {
                    selected = timeFrame
                }) {
                    Text(timeFrame.rawValue)
                        .font(.caption)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            Capsule()
                                .fill(selected == timeFrame ? Color.accentColor : Color.clear)
                        )
                        .foregroundColor(selected == timeFrame ? .white : .secondary)
                }
            }
        }
        .background(
            Capsule()
                .fill(Color(UIColor.tertiarySystemBackground))
        )
    }
}

struct LeaderboardItem: View {
    var rank: Int
    var name: String
    var roi: String
    var creator: String
    
    var body: some View {
        HStack {
            Text("#\(rank)")
                .font(.subheadline)
                .foregroundColor(rank <= 3 ? .yellow : .secondary)
                .fontWeight(rank <= 3 ? .bold : .regular)
                .frame(width: 40, alignment: .leading)
            
            Text(name)
                .font(.subheadline)
                .foregroundColor(.primary)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Text(roi)
                .font(.subheadline)
                .foregroundColor(.green)
                .frame(width: 80, alignment: .trailing)
            
            Text("@\(creator)")
                .font(.caption)
                .foregroundColor(.secondary)
                .frame(width: 80, alignment: .trailing)
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 8)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(UIColor.secondarySystemBackground))
        )
    }
}

struct LeaderboardIndex: Codable, Identifiable {
    var id: UUID { UUID() } // ← This makes a random UUID for each row
    let index_name: String
    let roi: Double
    let creator: String

    var formattedROI: String {
        String(format: roi >= 0 ? "+%.1f%%" : "%.1f%%", roi)
    }
}

class LeaderboardViewModel: ObservableObject {
    @Published var leaderboard: [LeaderboardIndex] = []

    func fetchLeaderboard() {
        print("🔍 Attempting to fetch leaderboard...")

        // For now, use mock data to avoid network issues
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.leaderboard = [
                LeaderboardIndex(index_name: "AI Memes Index", roi: 15.2, creator: "jameswang"),
                LeaderboardIndex(index_name: "Fortune AI Select", roi: 12.8, creator: "alexchen"),
                LeaderboardIndex(index_name: "AI Blue Chips", roi: 8.5, creator: "sarahkim")
            ]
            print("✅ Mock leaderboard data loaded")
        }
    }
}



// MARK: - Maneki Quiz Modal
struct ManekiQuizModalView: View {
    @Environment(\.presentationMode) var presentationMode
    @Binding var hasCompletedQuiz: Bool
    @State private var currentQuestion = 0
    @State private var selectedAnswers: [Int] = []
    
    let questions = [
        "Whats your investment time horizon?",
        "How would you react to a 20% market drop?",
        "What's your primary investment goal?"
    ]
    
    let answers = [
        ["Short Term (< 1 year)", "Medium Term (1-5 years)", "Long Term (5+ years)"],
        ["Sell Immediately", "Hold and Wait", "Buy More"],
        ["Capital preservation", "Balanced growth", "Maximum returns"]
    ]
    
    var body: some View {
        ZStack {
            // Background color
            Color(hex: "050715")
                .ignoresSafeArea(.all)
            
            VStack(spacing: 0) {
                // Header with back button and title
                HStack {
                    Button(action: {
                        if currentQuestion > 0 {
                            currentQuestion -= 1
                        } else {
                            presentationMode.wrappedValue.dismiss()
                        }
                    }) {
                        Image(systemName: "arrow.left")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.white)
                    }
                    
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
                
                // Title and question counter
                VStack(alignment: .leading, spacing: 8) {
                    Text("Maneki's Investment Quiz")
                        .font(.custom("Satoshi-Bold", size: 24))
                        .foregroundColor(.white)
                    
                    Text("Question \(currentQuestion + 1) of \(questions.count)")
                        .font(.custom("Satoshi-Bold", size: 16))
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 20)
                .padding(.top, 20)
                
                if currentQuestion < questions.count {
                    // Question content
                    VStack(alignment: .leading, spacing: 24) {
                        Text(questions[currentQuestion])
                            .font(.custom("Satoshi-Bold", size: 20))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.leading)
                        
                        VStack(spacing: 16) {
                            ForEach(0..<answers[currentQuestion].count, id: \.self) { index in
                                QuizAnswerButton(
                                    text: answers[currentQuestion][index],
                                    isSelected: selectedAnswers.count > currentQuestion && selectedAnswers[currentQuestion] == index,
                                    action: {
                                        if selectedAnswers.count > currentQuestion {
                                            selectedAnswers[currentQuestion] = index
                                        } else {
                                            selectedAnswers.append(index)
                                        }
                                    }
                                )
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 40)
                    
                    Spacer()
                    
                    // Navigation button with validation
                    Button(action: {
                        if currentQuestion < questions.count - 1 {
                            currentQuestion += 1
                        } else {
                            // Mark quiz as completed and dismiss
                            hasCompletedQuiz = true
                            presentationMode.wrappedValue.dismiss()
                        }
                    }) {
                        Text(currentQuestion < questions.count - 1 ? "Next Question" : "Finish Quiz")
                            .font(.custom("Satoshi-Bold", size: 18))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(
                                        LinearGradient(
                                            gradient: Gradient(colors: [
                                                Color(red: 0.2, green: 0.5, blue: 1.0),      // Bright blue
                                                Color(red: 0.1, green: 0.3, blue: 0.8)       // Darker blue
                                            ]),
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                            )
                    }
                    .disabled(selectedAnswers.count <= currentQuestion)
                    .opacity(selectedAnswers.count <= currentQuestion ? 0.5 : 1.0)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                    
                    // Progress indicator
                    HStack(spacing: 8) {
                        ForEach(0..<questions.count, id: \.self) { index in
                            Rectangle()
                                .fill(index <= currentQuestion ? Color.white : Color.gray.opacity(0.3))
                                .frame(height: 4)
                                .cornerRadius(2)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                } else {
                    // Results view
                    VStack(spacing: 24) {
                        Text("Your Recommended Portfolio:")
                            .font(.custom("Satoshi-Bold", size: 20))
                            .foregroundColor(.white)
                        
                        RecommendedIndexCard(
                            indexName: "Balanced Growth Portfolio",
                            value: "1,247.38",
                            change: "+2.3% • Today",
                            isPositive: true
                        )
                        
                        Text("This portfolio matches your risk tolerance and time horizon.")
                            .font(.custom("Satoshi-Bold", size: 16))
                            .multilineTextAlignment(.center)
                            .foregroundColor(.gray)
                            .padding(.horizontal)
                        
                        Button(action: {
                            presentationMode.wrappedValue.dismiss()
                        }) {
                            Text("Apply This Portfolio")
                                .font(.custom("Satoshi-Bold", size: 18))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.blue)
                                )
                        }
                        .padding(.horizontal, 20)
                    }
                    .padding(.top, 40)
                    
                    Spacer()
                }
            }
        }
    }
}

// MARK: - Quiz Answer Button Component
struct QuizAnswerButton: View {
    let text: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Text(text)
                    .font(.custom("Satoshi-Bold", size: 16))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.leading)
                
                Spacer()
                
                // Radio button
                Circle()
                    .fill(isSelected ? Color.white : Color.clear)
                    .frame(width: 20, height: 20)
                    .overlay(
                        Circle()
                            .stroke(Color.white, lineWidth: 2)
                    )
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(hex: "141628"))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                    )
            )
        }
    }
}

// MARK: - Preview
struct IndexesView_Previews: PreviewProvider {
    static var previews: some View {
        IndexesView(hamburgerAction: {})
            .preferredColorScheme(.dark)
    }
}
