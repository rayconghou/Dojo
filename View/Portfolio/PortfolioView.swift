//
//  PortfolioView.swift
//  Dojo
//
//  Created by Raymond Hou on 3/11/25.
//

import Foundation
import SwiftUI

// MARK: - Data Models

struct PortfolioAssetData: Identifiable {
    let id = UUID()
    let name: String
    let symbol: String
    let balance: String
    let value: String
    let change: String
    let isPositive: Bool
    let logo: String
    let logoColor: Color
    let imageUrl: String
}


struct PortfolioView: View {
    var hamburgerAction: () -> Void
    @State private var selectedTimeframe: Timeframe = .day
    @StateObject private var viewModel = PortfolioViewModel()
    @State private var searchText = ""
    @State private var selectedAssetTab = "All"
    @State private var selectedNewsTab = "For You"
    @State private var selectedNewsItem: NewsItem?
    @State private var showNewsModal = false
    @State private var showBuyScreen = false
    
    // Sample asset data
    private let allAssets = [
        PortfolioAssetData(name: "Bitcoin", symbol: "BTC", balance: "0,0006 BTC", value: "$2.02", change: "13,45%", isPositive: true, logo: "bitcoin", logoColor: .orange, imageUrl: "https://assets.coingecko.com/coins/images/1/large/bitcoin.png"),
        PortfolioAssetData(name: "Ethereum", symbol: "ETH", balance: "1,2 ETH", value: "$1,634.60", change: "1,32%", isPositive: false, logo: "ethereum", logoColor: .blue, imageUrl: "https://assets.coingecko.com/coins/images/279/large/ethereum.png"),
        PortfolioAssetData(name: "Tether", symbol: "USDT", balance: "0,0006 USDT", value: "$2.02", change: "13,45%", isPositive: true, logo: "tether", logoColor: .green, imageUrl: "https://assets.coingecko.com/coins/images/325/large/Tether.png"),
        PortfolioAssetData(name: "Solana", symbol: "SOL", balance: "5.2 SOL", value: "$850.00", change: "-2.5%", isPositive: false, logo: "S", logoColor: .purple, imageUrl: "https://assets.coingecko.com/coins/images/4128/large/solana.png"),
        PortfolioAssetData(name: "Cardano", symbol: "ADA", balance: "1000 ADA", value: "$750.00", change: "8.2%", isPositive: true, logo: "A", logoColor: .blue, imageUrl: "https://assets.coingecko.com/coins/images/975/large/cardano.png")
    ]
    
    // Filtered assets based on selected tab
    private var filteredAssets: [PortfolioAssetData] {
        switch selectedAssetTab {
        case "Gainers":
            return allAssets.filter { $0.isPositive }
        case "Losers":
            return allAssets.filter { !$0.isPositive }
        default: // "All"
            return allAssets
        }
    }
    
    // Sample news data
    private let allNews: [NewsItem] = [
        NewsItem(id: "1", title: "Stablecoin Explosion: Over $13.5B Added in July as Market Nears $270B...", description: "The latest figures reveal that the...", source: "CoinDesk", url: "https://example.com", publishedAt: "2025-08-03T10:00:00Z", imageUrl: "TetherNews", relatedAssetId: "tether"),
        NewsItem(id: "2", title: "Arkham Says $3.5B LuBian Bitcoin Theft Went Undetected for Nearly...", description: "A crypto wallet tied to a little...", source: "The Block", url: "https://example.com", publishedAt: "2025-08-02T10:00:00Z", imageUrl: "HackerNews", relatedAssetId: "bitcoin"),
        NewsItem(id: "3", title: "SEC's Crypto Task Force Will Tour U.S. to Hear From Small Startups...", description: "The U.S. Securities and Exchange...", source: "Reuters", url: "https://example.com", publishedAt: "2025-08-01T10:00:00Z", imageUrl: "GovernmentNews", relatedAssetId: nil),
        NewsItem(id: "4", title: "Solana Price Breaks Below $165: ETF Hype Fades, Fed Fuels Decline", description: "Solana's strong run in July...", source: "Decrypt", url: "https://example.com", publishedAt: "2025-07-30T10:00:00Z", imageUrl: "SolNews", relatedAssetId: "solana"),
        NewsItem(id: "5", title: "Bitcoin and the crypto market are in the red today, here's why", description: "The crypto market took a sharp...", source: "CoinTelegraph", url: "https://example.com", publishedAt: "2025-07-28T10:00:00Z", imageUrl: "BearNews", relatedAssetId: "bitcoin")
    ]
    
    private var filteredNews: [NewsItem] {
        switch selectedNewsTab {
        case "For You":
            return allNews
        case "All News":
            return allNews
        case "Bitcoin News":
            return allNews.filter { $0.title.localizedCaseInsensitiveContains("Bitcoin") || $0.description.localizedCaseInsensitiveContains("Bitcoin") }
        case "Ethereum News":
            return allNews.filter { $0.title.localizedCaseInsensitiveContains("Ethereum") || $0.description.localizedCaseInsensitiveContains("Ethereum") }
        default:
            return allNews
        }
    }
    
    var body: some View {
        ZStack(alignment: .top) {
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
                VStack(spacing: 32) {
                        // Portfolio Value Section
                        VStack(spacing: 8) {
                            Text("Portfolio Value")
                                .font(.custom("Satoshi-Medium", size: 16))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            HStack(alignment: .bottom) {
                                VStack(alignment: .leading, spacing: 4) {
                                    HStack(alignment: .bottom, spacing: 8) {
                                        Text("$4,237.36")
                                            .font(.custom("Satoshi-Bold", size: 36))
                                            .foregroundColor(.white)
                                        
                                        HStack(spacing: 4) {
                                            Image(systemName: "triangle.fill")
                                                .font(.system(size: 10, weight: .bold))
                                                .foregroundColor(.green)
                                            Text("26.25%")
                                                .font(.custom("Satoshi-Bold", size: 16))
                                    .foregroundColor(.green)
                            }
                                    }
                                    
                                    Text("+ $1,046.95")
                                        .font(.custom("Satoshi-Medium", size: 14))
                                .foregroundColor(.gray)
                        }
                        
                                Spacer()
                            }
                            
                            // Timeframe Selector
                        HStack(spacing: 0) {
                            ForEach(Timeframe.allCases, id: \.self) { timeframe in
                                Button(action: {
                                    selectedTimeframe = timeframe
                                }) {
                                    Text(timeframe.rawValue.uppercased())
                                            .font(.custom("Satoshi-Bold", size: 16))
                                            .padding(.vertical, 12)
                                            .frame(maxWidth: .infinity)
                                        .foregroundColor(selectedTimeframe == timeframe ? .white : .gray)
                                            .background(
                                                selectedTimeframe == timeframe ? 
                                                LinearGradient(
                                                    gradient: Gradient(colors: [
                                                        Color(red: 0.2, green: 0.5, blue: 1.0),
                                                        Color(red: 0.1, green: 0.3, blue: 0.8)
                                                    ]),
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                ) : LinearGradient(
                                                    gradient: Gradient(colors: [Color.clear]),
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                )
                                            )
                                    }
                                }
                            }
                            .background(Color(hex: "141628"))
                            .cornerRadius(8)
                        }
                        .padding(.horizontal, 32)
                        .padding(.top, 12)
                        
                        // Full Width Chart Area
                        ZStack {
                            // Subtle bottom halo effect
                            Path { path in
                                let width: CGFloat = UIScreen.main.bounds.width - 40
                                let height: CGFloat = 200
                                let points: [CGPoint] = [
                                    CGPoint(x: 0, y: height * 0.75),
                                    CGPoint(x: width * 0.1, y: height * 0.72),
                                    CGPoint(x: width * 0.2, y: height * 0.65),
                                    CGPoint(x: width * 0.3, y: height * 0.55),
                                    CGPoint(x: width * 0.4, y: height * 0.45),
                                    CGPoint(x: width * 0.5, y: height * 0.48),
                                    CGPoint(x: width * 0.6, y: height * 0.62),
                                    CGPoint(x: width * 0.7, y: height * 0.58),
                                    CGPoint(x: width * 0.8, y: height * 0.42),
                                    CGPoint(x: width * 0.9, y: height * 0.38),
                                    CGPoint(x: width, y: height * 0.45)
                                ]
                                
                                path.move(to: points[0])
                                for i in 1..<points.count {
                                    let currentPoint = points[i]
                                    let previousPoint = points[i-1]
                                    
                                    // Create control points for smooth curves
                                    let controlPoint1 = CGPoint(
                                        x: previousPoint.x + (currentPoint.x - previousPoint.x) * 0.3,
                                        y: previousPoint.y
                                    )
                                    let controlPoint2 = CGPoint(
                                        x: previousPoint.x + (currentPoint.x - previousPoint.x) * 0.7,
                                        y: currentPoint.y
                                    )
                                    
                                    path.addCurve(to: currentPoint, control1: controlPoint1, control2: controlPoint2)
                                }
                            }
                            .stroke(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color.green.opacity(0.15),
                                        Color.green.opacity(0.08),
                                        Color.green.opacity(0.03),
                                        Color.clear
                                    ]),
                                    startPoint: .top,
                                    endPoint: .bottom
                                ),
                                lineWidth: 12
                            )
                            
                            // Main green line
                                Path { path in
                                    let width: CGFloat = UIScreen.main.bounds.width - 40
                                    let height: CGFloat = 200
                                    let points: [CGPoint] = [
                                    CGPoint(x: 0, y: height * 0.75),
                                    CGPoint(x: width * 0.1, y: height * 0.72),
                                    CGPoint(x: width * 0.2, y: height * 0.65),
                                    CGPoint(x: width * 0.3, y: height * 0.55),
                                    CGPoint(x: width * 0.4, y: height * 0.45),
                                    CGPoint(x: width * 0.5, y: height * 0.48),
                                    CGPoint(x: width * 0.6, y: height * 0.62),
                                    CGPoint(x: width * 0.7, y: height * 0.58),
                                    CGPoint(x: width * 0.8, y: height * 0.42),
                                    CGPoint(x: width * 0.9, y: height * 0.38),
                                    CGPoint(x: width, y: height * 0.45)
                                    ]
                                    
                                    path.move(to: points[0])
                                for i in 1..<points.count {
                                    let currentPoint = points[i]
                                    let previousPoint = points[i-1]
                                    
                                    // Create control points for smooth curves
                                    let controlPoint1 = CGPoint(
                                        x: previousPoint.x + (currentPoint.x - previousPoint.x) * 0.3,
                                        y: previousPoint.y
                                    )
                                    let controlPoint2 = CGPoint(
                                        x: previousPoint.x + (currentPoint.x - previousPoint.x) * 0.7,
                                        y: currentPoint.y
                                    )
                                    
                                    path.addCurve(to: currentPoint, control1: controlPoint1, control2: controlPoint2)
                                    }
                                }
                                .stroke(Color.green, lineWidth: 3)
                        }
                        .frame(height: 180)
                            .padding(.horizontal, 20)
                        .padding(.bottom, 8)
                        
                        // Action Buttons
                        HStack(spacing: 16) {
                            ActionButton(icon: "QrCode", title: "Receive", color: Color(hex: "141628"))
                            ActionButton(icon: "PaperPlane", title: "Send", color: Color(hex: "141628"))
                            ActionButton(icon: "Swap", title: "Swap", color: Color(hex: "141628"))
                            Button(action: {
                                showBuyScreen = true
                            }) {
                                ActionButton(icon: "ShoppingCart", title: "Buy", color: Color(hex: "141628"))
                            }
                        }
                        .padding(.horizontal, 32)
                        .padding(.top, 8)
                        
                        // My Assets Section
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Text("My Assets")
                                    .font(.custom("Satoshi-Bold", size: 16))
                                    .foregroundColor(.white)
                                Spacer()
                            }
                            .padding(.horizontal, 32)
                            
                            // Asset Tabs
                            HStack(spacing: 0) {
                                ForEach(["All", "Gainers", "Losers"], id: \.self) { tab in
                                    Button(action: {
                                        selectedAssetTab = tab
                                    }) {
                                        Text(tab)
                                            .font(.custom("Satoshi-Medium", size: 14))
                                            .padding(.vertical, 8)
                                            .frame(maxWidth: .infinity)
                                            .foregroundColor(.white)
                                            .background(
                                                selectedAssetTab == tab ? 
                                                AnyView(LinearGradient(
                                                    gradient: Gradient(colors: [
                                                        Color(red: 0.2, green: 0.5, blue: 1.0),
                                                        Color(red: 0.1, green: 0.3, blue: 0.8)
                                                    ]),
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                )) : AnyView(Color.clear)
                                            )
                                            .cornerRadius(6)
                                    }
                                }
                            }
                            .padding(.horizontal, 4)
                            .padding(.vertical, 4)
                            .background(Color(hex: "141628"))
                            .cornerRadius(8)
                            .padding(.horizontal, 32)
                            
                            // Asset List Card
                            VStack(spacing: 12) {
                                ForEach(filteredAssets, id: \.symbol) { asset in
                                CustomAssetRow(
                                        name: asset.name,
                                        symbol: asset.symbol,
                                        balance: asset.balance,
                                        value: asset.value,
                                        change: asset.change,
                                        isPositive: asset.isPositive,
                                        logo: asset.logo,
                                        logoColor: asset.logoColor,
                                        imageUrl: asset.imageUrl
                                )
                            }
                        }
                        .padding(20)
                        .background(Color(hex: "141628"))
                        .cornerRadius(20)
                            .padding(.horizontal, 32)
                        }
                        
                        // My Favorite Assets Section
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Text("My Favorite Assets")
                                    .font(.custom("Satoshi-Bold", size: 16))
                                    .foregroundColor(.white)
                                Spacer()
                            }
                            .padding(.horizontal, 32)
                            
                            VStack(alignment: .leading, spacing: 16) {
                                VStack(spacing: 12) {
                                    FavoriteAssetRow(
                                        name: "Solana",
                                        symbol: "SOL",
                                        value: "$160.59",
                                        change: "2,75%",
                                        isPositive: false,
                                        logo: "S",
                                        logoColor: .purple,
                                        imageUrl: "https://assets.coingecko.com/coins/images/4128/large/solana.png"
                                    )
                                    
                                    FavoriteAssetRow(
                                        name: "USDC",
                                        symbol: "USDC",
                                        value: "$0.9998",
                                        change: "0,04%",
                                        isPositive: true,
                                        logo: "$",
                                        logoColor: .blue,
                                        imageUrl: "https://assets.coingecko.com/coins/images/6319/large/USD_Coin_icon.png"
                                    )
                                    
                                    FavoriteAssetRow(
                                        name: "TRON",
                                        symbol: "TRX",
                                        value: "$0.3234",
                                        change: "0.53%",
                                        isPositive: false,
                                        logo: "T",
                                        logoColor: .red,
                                        imageUrl: "https://assets.coingecko.com/coins/images/1094/large/tron-logo.png"
                                    )
                                    
                                    FavoriteAssetRow(
                                        name: "Cardano",
                                        symbol: "ADA",
                                        value: "$0.7130",
                                        change: "5,94%",
                                        isPositive: true,
                                        logo: "A",
                                        logoColor: .blue,
                                        imageUrl: "https://assets.coingecko.com/coins/images/975/large/cardano.png"
                                    )
                                }
                                
                                HStack {
                                    Spacer()
                                    Button("View All >") {
                                        // Navigate to all assets
                                    }
                                    .font(.custom("Satoshi-Medium", size: 14))
                                    .foregroundStyle(
                                        LinearGradient(
                                            gradient: Gradient(colors: [
                                                Color(red: 0.2, green: 0.5, blue: 1.0),
                                                Color(red: 0.1, green: 0.3, blue: 0.8)
                                            ]),
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    Spacer()
                                }
                            }
                            .padding(20)
                            .background(Color(hex: "141628"))
                            .cornerRadius(20)
                            .padding(.horizontal, 32)
                        }
                        
                        // Latest News Section
                        VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text("Latest News")
                                    .font(.custom("Satoshi-Bold", size: 16))
                                .foregroundColor(.white)
                            Spacer()
                            }
                            .padding(.horizontal, 32)
                            
                            // News Tabs
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    ForEach(["For You", "All News", "Bitcoin News", "Ethereum News"], id: \.self) { tab in
                            Button(action: {
                                            selectedNewsTab = tab
                                        }) {
                                            Text(tab)
                                                .font(.custom("Satoshi-Medium", size: 12))
                                                .padding(.vertical, 6)
                                                .padding(.horizontal, 8)
                                                .foregroundColor(.white)
                                                .background(
                                                    selectedNewsTab == tab ? 
                                                    AnyView(LinearGradient(
                                                        gradient: Gradient(colors: [
                                                            Color(red: 0.2, green: 0.5, blue: 1.0),
                                                            Color(red: 0.1, green: 0.3, blue: 0.8)
                                                        ]),
                                                        startPoint: .topLeading,
                                                        endPoint: .bottomTrailing
                                                    )) : AnyView(Color(hex: "141628"))
                                                )
                                                .cornerRadius(6)
                                        }
                                    }
                                }
                                .padding(.horizontal, 32)
                            }
                            .overlay(
                                // Right shadow to indicate more content
                                HStack {
                                    Spacer()
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            Color.clear,
                                            Color.black.opacity(0.3)
                                        ]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                    .frame(width: 20)
                                }
                            )
                            
                            // News Items Card
                            VStack(spacing: 16) {
                                if filteredNews.isEmpty {
                                    // Empty state
                                    VStack(spacing: 12) {
                                        Image(systemName: "newspaper")
                                            .font(.system(size: 40))
                                            .foregroundColor(.gray.opacity(0.6))
                                        
                                        Text("No news available")
                                            .font(.custom("Satoshi-Medium", size: 16))
                                            .foregroundColor(.gray)
                                        
                                        Text("Check back later for updates")
                                            .font(.custom("Satoshi-Regular", size: 14))
                                            .foregroundColor(.gray.opacity(0.7))
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 40)
                                } else {
                                    ForEach(filteredNews) { newsItem in
                                        Button(action: {
                                            selectedNewsItem = newsItem
                                            showNewsModal = true
                                        }) {
                                            PortfolioNewsCard(newsItem: newsItem)
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                    }
                                }
                            }
                            .padding(20)
                            .background(Color(hex: "141628"))
                            .cornerRadius(20)
                            .padding(.horizontal, 32)
                        }
                    }
                    .padding(.vertical, 20)
                }
            }
        }
        .background(Color(hex: "050715"))
        .onAppear {
            viewModel.fetchData()
        }
        .sheet(isPresented: $showNewsModal) {
            if let newsItem = selectedNewsItem {
                NewsDetailModal(
                    newsItem: newsItem, 
                    isPresented: $showNewsModal,
                    selectedNewsItem: $selectedNewsItem,
                    showNewsModal: $showNewsModal
                )
            }
        }
        .fullScreenCover(isPresented: $showBuyScreen) {
            BuyScreenView(coin: nil, asset: nil)
        }
    }
}
// MARK: - Models

enum Timeframe: String, CaseIterable {
    case day = "24H"
    case week = "1W"
    case month = "1M"
    case year = "1Y"
    case all = "ALL"
}


// MARK: - Wallet Management Views

struct WalletSelectorView: View {
    @ObservedObject var viewModel = PortfolioViewModel()
    @State private var showWalletSheet = false
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Your Wallets")
                    .font(.headline)
                    .foregroundColor(.white)
                
                Spacer()
                
                Button(action: {
                    showWalletSheet = true
                }) {
                    Text("Manage")
                        .font(.subheadline)
                        .foregroundColor(.blue)
                }
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(viewModel.wallets) { wallet in
                        WalletCard(wallet: wallet, isSelected: wallet.id == viewModel.selectedWalletId)
                            .onTapGesture {
                                viewModel.selectedWalletId = wallet.id
                                viewModel.fetchData()
                            }
                    }
                    
                    Button(action: {
                        showWalletSheet = true
                    }) {
                        VStack(spacing: 10) {
                            Image(systemName: "plus.circle")
                                .font(.system(size: 24))
                                .foregroundColor(.blue)
                            
                            Text("Add Wallet")
                                .font(.subheadline)
                                .foregroundColor(.blue)
                        }
                        .frame(width: 100, height: 80)
                        .background(Color(UIColor.systemGray6))
                        .cornerRadius(12)
                    }
                }
            }
        }
        .padding()
        .background(Color(UIColor.systemGray6))
        .cornerRadius(16)
        .sheet(isPresented: $showWalletSheet) {
            WalletListView(viewModel: viewModel)
        }
    }
}

struct WalletCard: View {
    let wallet: PersonalWallet
    let isSelected: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Image(systemName: wallet.iconName)
                    .foregroundColor(wallet.type.color)
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                }
            }
            
            Spacer()
            
            Text(wallet.name)
                .font(.caption)
                .lineLimit(1)
                .foregroundColor(.white)
            
            Text(wallet.balanceFormatted)
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding(10)
        .frame(width: 100, height: 80)
        .background(isSelected ? Color(UIColor.systemGray5) : Color(UIColor.systemGray6))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
        )
    }
}

struct WalletListView: View {
    @ObservedObject var viewModel = PortfolioViewModel()
    @Environment(\.presentationMode) var presentationMode
    @State private var showAddWalletSheet = false
    
    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.wallets) { wallet in
                    WalletListRow(wallet: wallet, isSelected: wallet.id == viewModel.selectedWalletId)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            viewModel.selectedWalletId = wallet.id
                            viewModel.fetchData()
                            presentationMode.wrappedValue.dismiss()
                        }
                }
                .onDelete { indexSet in
                    viewModel.removeWallet(at: indexSet)
                }
            }
            .listStyle(InsetGroupedListStyle())
            .navigationTitle("Your Wallets")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showAddWalletSheet = true
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
        }
        .sheet(isPresented: $showAddWalletSheet) {
            AddWalletView(viewModel: viewModel)
        }
    }
}

struct WalletListRow: View {
    let wallet: PersonalWallet
    let isSelected: Bool
    
    var body: some View {
        HStack {
            Image(systemName: wallet.iconName)
                .foregroundColor(wallet.type.color)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(wallet.name)
                    .font(.headline)
                
                Text(wallet.type.rawValue)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text(wallet.balanceFormatted)
                    .font(.headline)
                
                if isSelected {
                    Text("Active")
                        .font(.caption)
                        .foregroundColor(.green)
                }
            }
        }
        .padding(.vertical, 4)
    }
}

struct AddWalletView: View {
    @ObservedObject var viewModel = PortfolioViewModel()
    @Environment(\.presentationMode) var presentationMode
    @State private var name = ""
    @State private var walletType: PersonalWalletType = .bank
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Wallet Details")) {
                    TextField("Wallet Name", text: $name)
                    
                    Picker("Type", selection: $walletType) {
                        ForEach(PersonalWalletType.allCases, id: \.self) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                }
                
                Section {
                    Button("Add Wallet") {
                        viewModel.addWallet(name: name, type: walletType)
                        presentationMode.wrappedValue.dismiss()
                    }
                    .disabled(name.isEmpty)
                }
            }
            .navigationTitle("Add New Wallet")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
}

struct WalletManagementView: View {
    let isDeposit: Bool
    @ObservedObject var viewModel = PortfolioViewModel()
    @Environment(\.presentationMode) var presentationMode
    @State private var amount = ""
    @State private var selectedPaymentMethod: PaymentMethod?
    @State private var showProcessingView = false
    
    var body: some View {
        NavigationView {
            VStack {
                // Active wallet section
                if let wallet = viewModel.wallets.first(where: { $0.id == viewModel.selectedWalletId }) {
                    VStack(alignment: .center, spacing: 4) {
                        Text(isDeposit ? "Deposit to" : "Withdraw from")
                            .font(.headline)
                            .foregroundColor(.gray)
                        
                        HStack {
                            Image(systemName: wallet.iconName)
                                .foregroundColor(wallet.type.color)
                            Text(wallet.name)
                                .font(.headline)
                        }
                        
                        Text(wallet.balanceFormatted)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    .padding()
                }
                
                // Amount input
                VStack(alignment: .leading, spacing: 6) {
                    Text("Amount")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                    HStack {
                        Text("$")
                            .font(.title)
                            .foregroundColor(.white)
                        
                        TextField("0.00", text: $amount)
                            .font(.custom("Satoshi-Bold", size: 30))
                            .keyboardType(.decimalPad)
                            .foregroundColor(.white)
                    }
                    .padding()
                    .background(Color(UIColor.systemGray6))
                    .cornerRadius(10)
                }
                .padding()
                
                // Payment method selection
                VStack(alignment: .leading, spacing: 10) {
                    Text("Payment Method")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.horizontal)
                    
                    ScrollView {
                        VStack(spacing: 10) {
                            ForEach(viewModel.paymentMethods) { method in
                                PaymentMethodRow(method: method, isSelected: selectedPaymentMethod?.id == method.id)
                                    .onTapGesture {
                                        selectedPaymentMethod = method
                                    }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                
                Spacer()
                
                // Action button
                Button(action: {
                    showProcessingView = true
                    // Simulate processing delay
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        if let amountValue = Double(amount), let wallet = viewModel.wallets.first(where: { $0.id == viewModel.selectedWalletId }) {
                            if isDeposit {
                                viewModel.depositToWallet(walletId: wallet.id, amount: amountValue)
                            } else {
                                viewModel.withdrawFromWallet(walletId: wallet.id, amount: amountValue)
                            }
                        }
                        showProcessingView = false
                        presentationMode.wrappedValue.dismiss()
                    }
                }) {
                    Text(isDeposit ? "Deposit Funds" : "Withdraw Funds")
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(amount.isEmpty || selectedPaymentMethod == nil ? Color.gray : (isDeposit ? Color.green : Color.orange))
                        .cornerRadius(10)
                        .padding(.horizontal)
                }
                .disabled(amount.isEmpty || selectedPaymentMethod == nil)
            }
            .navigationTitle(isDeposit ? "Deposit" : "Withdraw")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
            .overlay(
                Group {
                    if showProcessingView {
                        ZStack {
                            Color.black.opacity(0.7)
                                .edgesIgnoringSafeArea(.all)
                            
                            VStack(spacing: 20) {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .scaleEffect(1.5)
                                
                                Text(isDeposit ? "Processing Deposit..." : "Processing Withdrawal...")
                                    .font(.headline)
                                    .foregroundColor(.white)
                            }
                            .padding(30)
                            .background(Color(UIColor.systemGray6))
                            .cornerRadius(15)
                        }
                    }
                }
            )
        }
    }
}

struct PaymentMethodRow: View {
    let method: PaymentMethod
    let isSelected: Bool
    
    var body: some View {
        HStack {
            Image(systemName: method.iconName)
                .font(.system(size: 24))
                .foregroundColor(method.type.color)
                .frame(width: 40)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(method.name)
                    .font(.headline)
                
                Text(method.detailsFormatted)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            if isSelected {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
            }
        }
        .padding()
        .background(isSelected ? Color(UIColor.systemGray5) : Color(UIColor.systemGray6))
        .cornerRadius(10)
    }
}

// MARK: - Models

class PortfolioViewModel: ObservableObject {
    @Published var coins: [Coin] = []
    @Published var portfolioAssets: [PortfolioAsset] = []
    @Published var newsItems: [NewsItem] = []
    @Published var isLoadingNews = false
    @Published var wallets: [PersonalWallet] = []
    @Published var paymentMethods: [PaymentMethod] = []
    @Published var selectedWalletId: String = ""
    
    @Published var totalBalance: Double = 0.0
    @Published var totalChange: Double = 0.0
    @Published var totalChangeValue: Double = 0.0
    @Published var unrealizedPnL: Double = 0.0
    @Published var realizedPnL: Double = 0.0
    @Published var totalPnL: Double = 0.0
    @Published var totalPnLPercentage: Double = 0.0
    
    // Sample portfolio holdings - in a real app, this would come from user data
    private let holdings = [
        AssetHolding(id: "bitcoin", amount: 0.5),
        AssetHolding(id: "ethereum", amount: 2.5),
        AssetHolding(id: "solana", amount: 25.0),
        AssetHolding(id: "cardano", amount: 1000.0)
    ]
    
    init() {
        setupWallets()
        setupPaymentMethods()
    }
    
    private func setupWallets() {
        wallets = [
            PersonalWallet(id: "wallet1", name: "Main Wallet", type: .personal, balance: 10543.27, iconName: "briefcase.fill"),
            PersonalWallet(id: "wallet2", name: "Savings", type: .savings, balance: 5321.89, iconName: "banknote"),
            PersonalWallet(id: "wallet3", name: "Chase Bank", type: .bank, balance: 2150.50, iconName: "building.columns.fill")
        ]
        
        // Set default selected wallet
        if let firstWallet = wallets.first {
            selectedWalletId = firstWallet.id
        }
    }
    
    private func setupPaymentMethods() {
        paymentMethods = [
            PaymentMethod(id: "bank1", name: "Chase Bank", type: .bank, details: "**** 4582", iconName: "building.columns.fill"),
            PaymentMethod(id: "card1", name: "Visa Debit", type: .card, details: "**** 7629", iconName: "creditcard.fill"),
            PaymentMethod(id: "card2", name: "Mastercard", type: .card, details: "**** 1284", iconName: "creditcard.fill"),
            PaymentMethod(id: "cash1", name: "Cash Deposit", type: .cash, details: "via ATM", iconName: "dollarsign.circle.fill")
        ]
    }
    
    func addWallet(name: String, type: PersonalWalletType) {
        let id = "wallet\(wallets.count + 1)"
        let iconName = type == .bank ? "building.columns.fill" : (type == .savings ? "banknote" : "briefcase.fill")
        let newWallet = PersonalWallet(id: id, name: name, type: type, balance: 0.0, iconName: iconName)
        wallets.append(newWallet)
    }
    
    func removeWallet(at indexSet: IndexSet) {
        wallets.remove(atOffsets: indexSet)
        
        // If selected wallet was removed, select the first wallet
        if !wallets.contains(where: { $0.id == selectedWalletId }) {
            selectedWalletId = wallets.first?.id ?? ""
        }
    }
    
    func depositToWallet(walletId: String, amount: Double) {
        if let index = wallets.firstIndex(where: { $0.id == walletId }) {
            wallets[index].balance += amount
        }
    }
    
    func withdrawFromWallet(walletId: String, amount: Double) {
        if let index = wallets.firstIndex(where: { $0.id == walletId }) {
            if wallets[index].balance >= amount {
                wallets[index].balance -= amount
            }
        }
    }
    
    func fetchData() {
        
        guard let url = URL(string: "https://api.coingecko.com/api/v3/coins/markets?vs_currency=usd&order=market_cap_desc&per_page=250&page=1&sparkline=false&price_change_percentage=24h") else {
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error fetching market data:", error)
                return
            }
            guard let data = data else { return }
            
            do {
                let decoded = try JSONDecoder().decode([Coin].self, from: data)
                DispatchQueue.main.async {
                    self.coins = decoded
                    self.createPortfolioAssets()
                    self.calculateTotals()
                    self.updatePnL(for: .week)
                }
            } catch {
                print("Decoding error:", error)
            }
        }.resume()
    }
    
    func refreshData() {
        fetchData()
    }
    
    func fetchNews() {
        isLoadingNews = true
        
        // In a real app, this would fetch news for the assets in the portfolio
        // For now, we'll use mock data
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.newsItems = self.getMockNewsItems()
            self.isLoadingNews = false
        }
    }
    
    func refreshNews() {
        fetchNews()
    }
    
    private func getMockNewsItems() -> [NewsItem] {
        // Generate news based on the assets in portfolio
        var news: [NewsItem] = []
        
        // Bitcoin news
        if holdings.contains(where: { $0.id == "bitcoin" }) {
            news.append(
                NewsItem(
                    id: "btc1",
                    title: "Bitcoin Hits New Monthly High as Institutional Adoption Grows",
                    description: "Large financial institutions continue to increase their Bitcoin holdings as the asset shows strong resilience in the market.",
                    source: "Crypto Daily",
                    url: "https://cryptodaily.com/bitcoin-institutional-adoption",
                    publishedAt: "2025-04-08T14:30:00Z",
                    imageUrl: "https://example.com/bitcoin-news.jpg",
                    relatedAssetId: "bitcoin"
                )
            )
            
            news.append(
                NewsItem(
                    id: "btc2",
                    title: "Bitcoin Mining Difficulty Reaches All-Time High",
                    description: "Bitcoin's network difficulty adjustment has hit a new record, reflecting growing computing power dedicated to securing the network.",
                    source: "Block Insight",
                    url: "https://blockinsight.com/bitcoin-mining-difficulty",
                    publishedAt: "2025-04-07T16:45:00Z",
                    imageUrl: "https://example.com/bitcoin-mining.jpg",
                    relatedAssetId: "bitcoin"
                )
            )
        }
        
        // Ethereum news
        if holdings.contains(where: { $0.id == "ethereum" }) {
            news.append(
                NewsItem(
                    id: "eth1",
                    title: "Ethereum Layer 2 Solutions See Surge in User Activity",
                    description: "Rollup technologies on Ethereum continue to gain traction as users seek lower fees and faster transactions.",
                    source: "ETH World",
                    url: "https://ethworld.com/layer2-activity",
                    publishedAt: "2025-04-09T09:15:00Z",
                    imageUrl: "https://example.com/ethereum-l2.jpg",
                    relatedAssetId: "ethereum"
                )
            )
            
            news.append(
                NewsItem(
                    id: "eth2",
                    title: "Ethereum Developer Conference Announces New Protocol Upgrades",
                    description: "The latest Ethereum developer summit revealed plans for upcoming improvements to the network's scalability and security.",
                    source: "DeFi Pulse",
                    url: "https://defipulse.com/eth-developer-conf",
                    publishedAt: "2025-04-06T11:20:00Z",
                    imageUrl: "https://example.com/ethereum-dev.jpg",
                    relatedAssetId: "ethereum"
                )
            )
        }
        
        // Solana news
        if holdings.contains(where: { $0.id == "solana" }) {
            news.append(
                NewsItem(
                    id: "sol1",
                    title: "Solana NFT Market Continues to Set New Records",
                    description: "The Solana NFT ecosystem has seen unprecedented growth in trading volume and new project launches.",
                    source: "SOL News",
                    url: "https://solnews.com/nft-market-growth",
                    publishedAt: "2025-04-08T12:10:00Z",
                    imageUrl: "https://example.com/solana-nft.jpg",
                    relatedAssetId: "solana"
                )
            )
        }
        
        // Cardano news
        if holdings.contains(where: { $0.id == "cardano" }) {
            news.append(
                NewsItem(
                    id: "ada1",
                    title: "Cardano Foundation Launches Developer Grant Program",
                    description: "A new initiative aims to accelerate the development of DApps and infrastructure on the Cardano blockchain.",
                    source: "Cardano Insider",
                    url: "https://cardanoinsider.com/grant-program",
                    publishedAt: "2025-04-07T10:45:00Z",
                    imageUrl: "https://example.com/cardano-dev.jpg",
                    relatedAssetId: "cardano"
                )
            )
        }
        
        // General crypto news
        news.append(
            NewsItem(
                id: "gen1",
                title: "New Crypto Regulations Set to Impact Global Markets",
                description: "Lawmakers in major economies have announced coordinated regulatory frameworks for cryptocurrency assets.",
                source: "Crypto Reports",
                url: "https://cryptoreports.com/global-regulations",
                publishedAt: "2025-04-09T08:30:00Z",
                imageUrl: "https://example.com/crypto-regulations.jpg",
                relatedAssetId: nil
            )
        )
        
        return news.shuffled() // Randomize order for variety
    }

    private func createPortfolioAssets() {
        portfolioAssets = []
        
        for holding in holdings {
            if let coin = coins.first(where: { $0.id == holding.id }) {
                let totalValue = coin.current_price * holding.amount
                let asset = PortfolioAsset(
                    id: coin.id,
                    name: coin.name,
                    symbol: coin.symbol,
                    amount: holding.amount,
                    currentPrice: coin.current_price,
                    totalValue: totalValue,
                    priceChangePercentage: coin.price_change_percentage_24h ?? 0,
                    imageUrl: coin.image
                )
                portfolioAssets.append(asset)
            }
        }
    }

    private func calculateTotals() {
        totalBalance = portfolioAssets.reduce(0) { $0 + $1.totalValue }
        
        // Calculate overall change based on 24h percentage
        let weightedChange = portfolioAssets.reduce(0.0) {
            $0 + ($1.priceChangePercentage * ($1.totalValue / max(1, totalBalance)))
        }
        totalChange = weightedChange
        totalChangeValue = totalBalance * (totalChange / 100)
    }

    func updatePnL(for timeframe: Timeframe) {
        // In a real app, this would use historical data for the selected timeframe
        // For this demo, we'll use simulated values based on the timeframe
        switch timeframe {
        case .day:
            unrealizedPnL = totalBalance * 0.02
            realizedPnL = totalBalance * -0.005
        case .week:
            unrealizedPnL = totalBalance * 0.045
            realizedPnL = totalBalance * -0.003
        case .month:
            unrealizedPnL = totalBalance * 0.12
            realizedPnL = totalBalance * 0.01
        case .year:
            unrealizedPnL = totalBalance * 0.35
            realizedPnL = totalBalance * 0.05
        case .all:
            unrealizedPnL = totalBalance * 0.65
            realizedPnL = totalBalance * 0.15
        }
        
        totalPnL = unrealizedPnL + realizedPnL
        totalPnLPercentage = (totalPnL / totalBalance) * 100
    }
}

// MARK: - Asset Models



// MARK: - Wallet Models

enum PersonalWalletType: String, CaseIterable {
    case personal = "Personal"
    case savings = "Savings"
    case bank = "Bank Account"
    
    var color: Color {
        switch self {
        case .personal:
            return .blue
        case .savings:
            return .green
        case .bank:
            return .purple
        }
    }
}

struct PersonalWallet: Identifiable {
    let id: String
    let name: String
    let type: PersonalWalletType
    var balance: Double
    let iconName: String
    
    var balanceFormatted: String {
        String(format: "$%.2f", balance)
    }
}

// MARK: - Payment Method Models

enum PaymentMethodType: String, CaseIterable {
    case bank = "Bank Account"
    case card = "Card"
    case cash = "Cash"
    
    var color: Color {
        switch self {
        case .bank:
            return .purple
        case .card:
            return .blue
        case .cash:
            return .green
        }
    }
}

struct PaymentMethod: Identifiable {
    let id: String
    let name: String
    let type: PaymentMethodType
    let details: String
    let iconName: String
    
    var detailsFormatted: String {
        switch type {
        case .bank:
            return "Account \(details)"
        case .card:
            return "Card \(details)"
        case .cash:
            return details
        }
    }
}

// MARK: - Data Models

struct PortfolioCoin: Codable {
    let id: String
    let symbol: String
    let name: String
    let image: String
    let current_price: Double
    let price_change_percentage_24h: Double?
}

// MARK: - Supporting Views

private func portfolioBackgroundColorForSymbol(_ symbol: String) -> Color {
    switch symbol.uppercased() {
    case "BTC": return .orange
    case "ETH": return Color(red: 0.4, green: 0.5, blue: 0.7)
    case "XRP": return .black
    case "USDT": return .green
    case "SOL": return .black
    case "USDC": return .blue
    case "TRX": return .red
    case "ADA": return .blue
    default: return .gray
    }
}

struct ActionButton: View {
    let icon: String
    let title: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(icon)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 24, height: 24)
                .foregroundColor(.blue)
            
            Text(title)
                .font(.custom("Satoshi-Medium", size: 12))
                .foregroundColor(.white)
        }
        .frame(width: 80, height: 80)
        .background(color)
        .cornerRadius(12)
    }
}

struct CustomAssetRow: View {
    let name: String
    let symbol: String
    let balance: String
    let value: String
    let change: String
    let isPositive: Bool
    let logo: String
    let logoColor: Color
    let imageUrl: String
    
    var body: some View {
        HStack(spacing: 12) {
            // Token Icon
            AsyncImage(url: URL(string: imageUrl)) { image in
                image
                    .resizable()
                    .scaledToFit()
                    .frame(width: 32, height: 32)
            } placeholder: {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 32, height: 32)
            }
                    .frame(width: 40, height: 40)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(portfolioBackgroundColorForSymbol(symbol))
            )
            .clipShape(RoundedRectangle(cornerRadius: 8))
            
            // Asset Info
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(name)
                        .font(.custom("Satoshi-Bold", size: 16))
                        .foregroundColor(.white)
                    
                    Image(systemName: "star.fill")
                        .font(.system(size: 12))
                        .foregroundColor(.yellow)
                }
                
                Text(balance)
                    .font(.custom("Satoshi-Medium", size: 14))
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            // Value and Change
            VStack(alignment: .trailing, spacing: 4) {
                Text(value)
                    .font(.custom("Satoshi-Bold", size: 16))
                    .foregroundColor(.white)
                
                HStack(spacing: 4) {
                    Image(systemName: "triangle.fill")
                        .font(.system(size: 8, weight: .bold))
                        .foregroundColor(isPositive ? .green : .red)
                        .rotationEffect(.degrees(isPositive ? 0 : 180))
                    
                    Text(change)
                        .font(.custom("Satoshi-Medium", size: 14))
                        .foregroundColor(isPositive ? .green : .red)
                }
            }
        }
        .padding(.vertical, 8)
    }
}

struct FavoriteAssetRow: View {
    let name: String
    let symbol: String
    let value: String
    let change: String
    let isPositive: Bool
    let logo: String
    let logoColor: Color
    let imageUrl: String
    
    var body: some View {
        HStack(spacing: 12) {
            // Token Icon
            AsyncImage(url: URL(string: imageUrl)) { image in
                image
                    .resizable()
                    .scaledToFit()
                    .frame(width: 32, height: 32)
            } placeholder: {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 32, height: 32)
            }
            .frame(width: 40, height: 40)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(portfolioBackgroundColorForSymbol(symbol))
            )
            .clipShape(RoundedRectangle(cornerRadius: 8))
            
            // Asset Info
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(name)
                        .font(.custom("Satoshi-Bold", size: 16))
                        .foregroundColor(.white)
                    
                    Image(systemName: "star.fill")
                        .font(.system(size: 12))
                        .foregroundColor(.yellow)
                }
                
                Text(symbol)
                    .font(.custom("Satoshi-Medium", size: 14))
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            // Value and Change
            VStack(alignment: .trailing, spacing: 4) {
                Text(value)
                    .font(.custom("Satoshi-Bold", size: 16))
                    .foregroundColor(.white)
                
                HStack(spacing: 4) {
                    Image(systemName: "triangle.fill")
                        .font(.system(size: 8, weight: .bold))
                        .foregroundColor(isPositive ? .green : .red)
                        .rotationEffect(.degrees(isPositive ? 0 : 180))
                    
                    Text(change)
                        .font(.custom("Satoshi-Medium", size: 14))
                        .foregroundColor(isPositive ? .green : .red)
                }
            }
        }
        .padding(.vertical, 8)
    }
}

struct PortfolioNewsCard: View {
    let newsItem: NewsItem
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // News Image - Left third
            if let imageUrl = newsItem.imageUrl, !imageUrl.isEmpty {
                Image(imageUrl)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 100, height: 132)
                    .cornerRadius(12)
                    .clipped()
            } else {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 100, height: 132)
            }
            
            // News Content - Right two thirds
            VStack(alignment: .leading, spacing: 8) {
                // Title with 3 lines
                Text(newsItem.title)
                    .font(.custom("Satoshi-Bold", size: 16))
                    .foregroundColor(.white)
                    .lineLimit(3)
                    .multilineTextAlignment(.leading)
                
                // Description with ellipsis
                Text(newsItem.description)
                    .font(.custom("Satoshi-Medium", size: 12))
                    .foregroundColor(.gray)
                    .lineLimit(1)
                    .truncationMode(.tail)
                
                Spacer()
                
                // Time and Views in separate shadowed boxes
                HStack(spacing: 8) {
                    // Time box
                    HStack(spacing: 4) {
                        Image("ClockCountdown")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 12, height: 12)
                        Text(formatNewsDate(newsItem.publishedAt))
                        .font(.custom("Satoshi-Medium", size: 10))
                        .foregroundColor(.gray)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color.black.opacity(0.3))
                            .shadow(color: .black.opacity(0.2), radius: 2, x: 0, y: 1)
                    )
                    
                    // Views box
                    HStack(spacing: 4) {
                        Image("Eye")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 12, height: 12)
                        Text("1.2K")
                        .font(.custom("Satoshi-Medium", size: 10))
                        .foregroundColor(.gray)
                }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color.black.opacity(0.3))
                            .shadow(color: .black.opacity(0.2), radius: 2, x: 0, y: 1)
                    )
                    
                    Spacer()
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.vertical, 8)
    }
    
    private func formatNewsDate(_ dateString: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        
        if let date = formatter.date(from: dateString) {
            formatter.dateFormat = "MMM d, yyyy"
            return formatter.string(from: date)
        }
        
        return dateString
    }
}

struct PortfolioView_Previews: PreviewProvider {
    static var previews: some View {
        PortfolioView(hamburgerAction: {})
            .preferredColorScheme(.dark)
    }
}

