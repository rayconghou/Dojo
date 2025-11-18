//
//  CryptoMarketViewModel.swift
//  Dojo
//
//  Created by Raymond Hou on 3/13/25.
//  Updated to fetch the full coin list with sparkline data from CoinGecko
//

import Foundation
import Combine
import SwiftUI

// MARK: - Coin Models

struct Coin: Codable, Identifiable {
    let id: String
    let symbol: String
    let name: String
    let image: String
    let current_price: Double
    let market_cap: Double?
    let market_cap_rank: Int?
    let price_change_percentage_24h: Double?
    let sparkline_in_7d: SparklineData?
    
    enum CodingKeys: String, CodingKey {
        case id
        case symbol
        case name
        case image
        case current_price = "current_price"
        case market_cap = "market_cap"
        case market_cap_rank = "market_cap_rank"
        case price_change_percentage_24h = "price_change_percentage_24h"
        case sparkline_in_7d = "sparkline_in_7d"
    }
}

struct CoinDetail: Codable, Identifiable {
    let id: String
    let name: String
    let symbol: String
    let description: [String: String]
    let links: CoinLinks?
}

struct CoinLinks: Codable {
    let homepage: [String]?
}

struct PriceHistoryEntry: Identifiable {
    let id = UUID()
    let date: String
    let price: Double
}


struct CoinDetailModalView: View {
    let coin: Coin
    @ObservedObject var marketVM: CryptoMarketViewModel
    @State private var selectedTimeframe = 0
    @State private var showBuyScreen = false
    @Environment(\.dismiss) private var dismiss
    
    let timeframes = ["1D", "1W", "1M", "1Y", "All"]
    
    let priceHistory = [
        PriceHistoryEntry(date: "Apr 09", price: 117176.16),
        PriceHistoryEntry(date: "Apr 08", price: 118611.15),
        PriceHistoryEntry(date: "Apr 07", price: 114497.52),
        PriceHistoryEntry(date: "Apr 06", price: 112927.92),
        PriceHistoryEntry(date: "Apr 05", price: 109876.54),
        PriceHistoryEntry(date: "Apr 04", price: 111234.56)
    ]
    
    let marketStats = [
        ("Market Cap", "$1.2T"),
        ("24h Volume", "$48.2B"),
        ("Circulating Supply", "19.4M BTC"),
        ("Max Supply", "21M BTC"),
        ("All-Time High", "$119,176.16"),
        ("Popularity", "#1 Most held")
    ]
    
    var body: some View {
        ZStack {
            // Background - same as other screens
            Color(hex: "050715")
                .ignoresSafeArea(.all)
            
            ScrollView {
                VStack(spacing: 24) {
                    // Header with back button, coin info, and favorite
                    headerSection
                        .padding(.top, 20)
                    
                    // Price section
                    priceSection
                    
                    // Chart section
                    chartSection
                    
                    // Timeframe selector
                    timeframeSelector
                    
                    // Price History section
                    priceHistorySection
                    
                    // Market Stats section
                    marketStatsSection
                    
                    // About section
                    aboutSection
                    
                    // Resources section
                    resourcesSection
                    
                    // Footer
                    footerSection
                }
                .padding(.bottom, 80) // Space for bottom buttons
            }
            
            // Bottom action buttons - positioned at very bottom of screen
            VStack {
                Spacer()
                HStack(spacing: 12) {
                    // Buy Button with blue gradient
                    Button(action: {
                        showBuyScreen = true
                    }) {
                        Text("Buy")
                            .font(.custom("Satoshi-Black", size: 18))
                            .foregroundColor(.white)
                            .frame(height: 56)
                            .frame(maxWidth: .infinity)
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color(red: 0.2, green: 0.5, blue: 1.0),      // Bright blue
                                        Color(red: 0.1, green: 0.3, blue: 0.8)       // Darker blue
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .cornerRadius(28)
                    }
                    
                    // Sell Button with white background and black text
                    Button(action: {}) {
                        Text("Sell")
                            .font(.custom("Satoshi-Black", size: 18))
                            .foregroundColor(.black)
                            .frame(height: 56)
                            .frame(maxWidth: .infinity)
                            .background(Color.white)
                            .cornerRadius(28)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 0) // No bottom padding since there's no tab bar in modal
            }
        }
        .onAppear {
            marketVM.fetchCoinDetail(id: coin.id)
        }
        .fullScreenCover(isPresented: $showBuyScreen) {
            BuyScreenView(coin: coin, asset: nil)
        }
    }
    
    // MARK: - UI Components
    
    private var headerSection: some View {
        HStack {
            // Coin icon and name
            HStack(spacing: 12) {
                // Coin icon with background color
                AsyncImage(url: URL(string: coin.image)) { image in
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
                        .fill(backgroundColorForSymbol(coin.symbol))
                )
                .clipShape(RoundedRectangle(cornerRadius: 8))
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(coin.name)
                        .font(.custom("Satoshi-Black", size: 20))
                        .foregroundColor(.white)
                    
                    Text(coin.symbol.uppercased())
                        .font(.custom("Satoshi-Black", size: 16))
                        .foregroundColor(.gray)
                }
                }
                
                Spacer()
                
            // Down arrow button for dismissing modal
                Button(action: {
                dismiss()
            }) {
                Image(systemName: "chevron.down")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
            }
        }
        .padding(.horizontal, 20)
    }
    
    private var priceSection: some View {
        let percentageChange = coin.price_change_percentage_24h ?? 0
        let dollarChange = coin.current_price * (percentageChange / 100)
        let priceChangeText = dollarChange >= 0 ? "+$\(String(format: "%.2f", abs(dollarChange)))" : "-$\(String(format: "%.2f", abs(dollarChange)))"
        
        return VStack(alignment: .leading, spacing: 8) {
            // Current price
            Text(coin.current_price.asFormattedCurrency)
                .font(.custom("Satoshi-Black", size: 32))
                                .foregroundColor(.white)
            
            // Price change row
            HStack(spacing: 8) {
                // Dollar change
                Text(priceChangeText)
                    .font(.custom("Satoshi-Black", size: 16))
                    .foregroundColor(.white)
                
                // Percentage change with triangle
                HStack(spacing: 4) {
                    Image(systemName: "triangle.fill")
                        .font(.system(size: 8))
                        .foregroundColor(percentageChange >= 0 ? .green : .red)
                        .rotationEffect(.degrees(percentageChange >= 0 ? 0 : 180))
                    
                    Text(String(format: "%.2f%%", abs(percentageChange)))
                        .font(.custom("Satoshi-Black", size: 16))
                        .foregroundColor(percentageChange >= 0 ? .green : .red)
                }
                
                Text("Today")
                    .font(.custom("Satoshi-Black", size: 14))
                    .foregroundColor(.gray)
                
                Spacer()
            }
        }
        .padding(.horizontal, 20)
    }
    
    private var chartSection: some View {
        Group {
            // Chart with sparkline - exactly like CryptoTrendCard
            if let sparklineData = coin.sparkline_in_7d?.price, !sparklineData.isEmpty {
                SparklineChartView(data: sparklineData, isPositive: coin.price_change_percentage_24h ?? 0 >= 0)
                    .frame(height: 200)
                    .onAppear {
                        print("🔍 Sparkline data for \(coin.symbol): \(sparklineData.prefix(10))... (total: \(sparklineData.count) points)")
                        if let min = sparklineData.min(), let max = sparklineData.max() {
                            print("📊 Price range: \(min) to \(max)")
                        }
                    }
            } else {
                // Fallback chart
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(hex: "141628"))
                    .frame(height: 200)
                    .overlay(
                        Text("Chart data unavailable")
                            .font(.custom("Satoshi-Black", size: 14))
                            .foregroundColor(.gray)
                    )
            }
        }
    }
    
    private var timeframeSelector: some View {
        HStack(spacing: 8) {
            ForEach(Array(timeframes.enumerated()), id: \.offset) { index, timeframe in
                Button(action: {
                    // TODO: Implement actual price tracking for different timeframes
                    // This should fetch and display price data for the selected timeframe
                    selectedTimeframe = index
                    print("Selected timeframe: \(timeframe)")
                }) {
                    Text(timeframe)
                        .font(.custom("Satoshi-Black", size: 16))
                        .foregroundColor(selectedTimeframe == index ? .white : .gray)
                        .padding(.vertical, 12)
                        .padding(.horizontal, 16)
                        .background(
                            selectedTimeframe == index ?
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color(red: 0.2, green: 0.5, blue: 1.0),      // Bright blue
                                    Color(red: 0.1, green: 0.3, blue: 0.8)       // Darker blue
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ) : LinearGradient(
                                gradient: Gradient(colors: [Color(hex: "141628")]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .cornerRadius(8)
                }
            }
        }
        .padding(.horizontal, 20)
    }
    
    
    private var priceHistorySection: some View {
            VStack(alignment: .leading, spacing: 16) {
                Text("Price History")
                .font(.custom("Satoshi-Black", size: 20))
                    .foregroundColor(.white)
                .padding(.horizontal, 20)
                
            VStack(spacing: 0) {
                    ForEach(priceHistory) { entry in
                        HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(entry.date)
                                .font(.custom("Satoshi-Black", size: 16))
                                .foregroundColor(.white)
                            
                            Text("1 \(coin.symbol.uppercased())")
                                .font(.custom("Satoshi-Black", size: 14))
                                .foregroundColor(.gray)
                        }
                            
                            Spacer()
                            
                        Text(entry.price.asFormattedCurrency)
                            .font(.custom("Satoshi-Black", size: 16))
                                .foregroundColor(.white)
                        }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    
                    if entry.id != priceHistory.last?.id {
                        Divider()
                            .background(Color.gray.opacity(0.3))
                            .padding(.horizontal, 20)
                    }
                }
                
                HStack {
                    Spacer()
                    Button(action: {}) {
                        Text("See Last 30 Days >")
                            .font(.custom("Satoshi-Black", size: 16))
                            .foregroundColor(Color(hex: "5987FF"))
                    }
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .padding(.bottom, 16)
            }
            .background(Color(hex: "141628"))
            .cornerRadius(12)
            .padding(.horizontal, 20)
        }
    }
    
    private var marketStatsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Market Stats")
                .font(.custom("Satoshi-Black", size: 20))
                .foregroundColor(.white)
                .padding(.horizontal, 20)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 8) {
                ForEach(Array(marketStats.enumerated()), id: \.offset) { index, stat in
                    VStack(alignment: .leading, spacing: 6) {
                        Text(stat.0)
                            .font(.custom("Satoshi-Black", size: 12))
                            .foregroundColor(.gray)
                            .lineLimit(2)
                            .multilineTextAlignment(.leading)
                        
                        Text(stat.1)
                            .font(.custom("Satoshi-Black", size: 16))
                            .foregroundColor(.white)
                            .lineLimit(3)
                            .multilineTextAlignment(.leading)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .frame(height: 70)
                    .padding(.vertical, 12)
                    .padding(.horizontal, 16)
                    .background(Color(hex: "141628"))
                    .cornerRadius(15)
                }
            }
            .padding(.horizontal, 20)
        }
    }
    
    private var aboutSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("About")
                .font(.custom("Satoshi-Black", size: 20))
                    .foregroundColor(.white)
                .padding(.horizontal, 20)
            
            Text("Bitcoin is the first decentralized cryptocurrency, released as open-source software in 2009. It operates on a peer-to-peer network without central authority or banks. Transaction verification and network integrity are maintained by cryptography and recorded in a public distributed ledger called a blockchain.")
                .font(.custom("Satoshi-Black", size: 16))
                    .foregroundColor(.gray)
                .lineSpacing(4)
                .padding(20)
                .background(Color(hex: "141628"))
                .cornerRadius(12)
                .padding(.horizontal, 20)
        }
    }
    
    private var resourcesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Resources")
                .font(.custom("Satoshi-Black", size: 20))
                .foregroundColor(.white)
                .padding(.horizontal, 20)
            
            VStack(spacing: 12) {
                ForEach([
                    ("globe", "Official Website"),
                    ("doc.text", "White Paper"),
                    ("magnifyingglass", "Block Explorer"),
                    ("chevron.left.forwardslash.chevron.right", "Source Code")
                ], id: \.1) { icon, title in
                    Button(action: {}) {
        HStack {
            Image(systemName: icon)
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.white)
                                .frame(width: 24)
            
            Text(title)
                                .font(.custom("Satoshi-Black", size: 16))
                .foregroundColor(.white)
            
            Spacer()
            
            Image(systemName: "chevron.right")
                                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.gray)
        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 16)
                        .background(Color(hex: "141628"))
                        .cornerRadius(12)
                    }
                }
            }
            .padding(.horizontal, 20)
        }
    }
    
    
    private var footerSection: some View {
        Text("Cryptocurrency Services Powered by Zero Hash")
            .font(.custom("Satoshi-Black", size: 12))
            .foregroundColor(.gray)
            .padding(.horizontal, 20)
            .padding(.top, 20)
    }
}

// MARK: - Sparkline Data Models

struct SparklineData: Codable {
    let price: [Double]
}

// MARK: - View Model

class CryptoMarketViewModel: ObservableObject {
    @Published var coins: [Coin] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private var cancellables = Set<AnyCancellable>()
    
    func fetchData() {
        isLoading = true
        errorMessage = nil
        
        guard let url = URL(string: "https://api.coingecko.com/api/v3/coins/markets?vs_currency=usd&order=market_cap_desc&per_page=100&page=1&sparkline=true&price_change_percentage=24h") else {
            errorMessage = "Invalid URL"
            isLoading = false
            return
        }
        
        URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: [Coin].self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    if case .failure(let error) = completion {
                        self?.errorMessage = error.localizedDescription
                    }
                },
                receiveValue: { [weak self] coins in
                    self?.coins = coins
                }
            )
            .store(in: &cancellables)
    }
    
    func fetchCoinDetail(id: String) {
        // Implementation for fetching detailed coin information
        // This would typically make another API call to get more detailed data
    }
}

// MARK: - Helper Functions

func backgroundColorForSymbol(_ symbol: String) -> Color {
    let lowercasedSymbol = symbol.lowercased()
    
    switch lowercasedSymbol {
    case "btc", "bitcoin":
        return Color(red: 1.0, green: 0.58, blue: 0.0) // Bitcoin orange
    case "eth", "ethereum":
        return Color(red: 0.46, green: 0.48, blue: 0.9) // Ethereum blue
    case "bnb", "binance":
        return Color(red: 0.8, green: 0.6, blue: 0.0) // Binance darker yellow
    case "sol", "solana":
        return Color(red: 0.0, green: 0.0, blue: 0.0) // Solana black
    case "ada", "cardano":
        return Color(red: 0.0, green: 0.0, blue: 0.0) // Cardano black
    case "xrp", "ripple":
        return Color(red: 0.0, green: 0.0, blue: 0.0) // Ripple black
    case "doge", "dogecoin":
        return Color(red: 0.8, green: 0.6, blue: 0.0) // Dogecoin darker yellow
    case "trx", "tron":
        return Color(red: 0.0, green: 0.0, blue: 0.0) // Tron black
    case "usdt", "tether":
        return Color(red: 0.0, green: 0.4, blue: 0.0) // Tether forest green
    case "usde", "ethena-usde":
        return Color(red: 0.0, green: 0.0, blue: 0.0) // Ethena USDE black
    case "wbeth", "wrapped-beth":
        return Color(red: 1.0, green: 0.84, blue: 0.0) // Wrapped BETH golden yellow
    case "wbtc", "wrapped-bitcoin":
        return Color(red: 0.0, green: 0.0, blue: 0.0) // Wrapped Bitcoin black
    case "tao", "bittensor":
        return Color(red: 1.0, green: 1.0, blue: 1.0) // Bittensor white
    case "story":
        return Color(red: 1.0, green: 0.84, blue: 0.0) // Story gold
    case "jitosol", "jito-staked-sol":
        return Color(red: 1.0, green: 1.0, blue: 1.0) // Jito Staked SOL white
    case "apt", "aptos":
        return Color(red: 1.0, green: 1.0, blue: 1.0) // Aptos white
    case "steth", "lido-staked-ether":
        return Color(red: 1.0, green: 1.0, blue: 1.0) // Lido Staked Ether white
    case "usdc", "usd-coin":
        return Color(red: 0.2, green: 0.4, blue: 0.9) // USDC blue
    case "avax", "avalanche":
        return Color(red: 0.8, green: 0.2, blue: 0.2) // Avalanche red
    case "matic", "polygon":
        return Color(red: 0.6, green: 0.3, blue: 0.9) // Polygon purple
    case "link", "chainlink":
        return Color(red: 0.2, green: 0.4, blue: 0.8) // Chainlink blue
    case "atom", "cosmos":
        return Color(red: 0.2, green: 0.4, blue: 0.8) // Cosmos blue
    case "near":
        return Color(red: 0.8, green: 0.4, blue: 0.2) // NEAR orange
    case "ftm", "fantom":
        return Color(red: 0.2, green: 0.4, blue: 0.8) // Fantom blue
    case "algo", "algorand":
        return Color(red: 0.0, green: 0.0, blue: 0.0) // Algorand black
    case "vet", "vechain":
        return Color(red: 0.0, green: 0.6, blue: 0.8) // VeChain cyan
    case "icp", "internet-computer":
        return Color(red: 0.8, green: 0.2, blue: 0.2) // Internet Computer red
    case "fil", "filecoin":
        return Color(red: 0.2, green: 0.4, blue: 0.8) // Filecoin blue
    case "hbar", "hedera":
        return Color(red: 0.0, green: 0.0, blue: 0.0) // Hedera black
    case "sand", "the-sandbox":
        return Color(red: 0.0, green: 0.6, blue: 0.8) // The Sandbox cyan
    case "mana", "decentraland":
        return Color(red: 0.8, green: 0.4, blue: 0.8) // Decentraland purple
    case "axs", "axie-infinity":
        return Color(red: 0.0, green: 0.6, blue: 0.8) // Axie Infinity cyan
    case "gala":
        return Color(red: 0.8, green: 0.4, blue: 0.2) // Gala orange
    case "enj", "enjin-coin":
        return Color(red: 0.4, green: 0.6, blue: 0.8) // Enjin Coin blue
    case "chz", "chiliz":
        return Color(red: 0.8, green: 0.2, blue: 0.2) // Chiliz red
    case "flow":
        return Color(red: 0.0, green: 0.6, blue: 0.8) // Flow cyan
    case "theta":
        return Color(red: 0.2, green: 0.4, blue: 0.8) // Theta blue
    case "klay", "klaytn":
        return Color(red: 0.0, green: 0.6, blue: 0.4) // Klaytn teal
    case "eos":
        return Color(red: 0.0, green: 0.0, blue: 0.0) // EOS black
    case "xtz", "tezos":
        return Color(red: 0.2, green: 0.4, blue: 0.8) // Tezos blue
    case "zec", "zcash":
        return Color(red: 0.8, green: 0.6, blue: 0.0) // Zcash yellow
    case "dash":
        return Color(red: 0.0, green: 0.6, blue: 0.8) // Dash cyan
    case "xlm", "stellar":
        return Color(red: 0.0, green: 0.4, blue: 0.8) // Stellar blue
    case "neo":
        return Color(red: 0.0, green: 0.8, blue: 0.0) // NEO green
    case "qtum":
        return Color(red: 0.8, green: 0.4, blue: 0.2) // Qtum orange
    case "waves":
        return Color(red: 0.0, green: 0.6, blue: 0.8) // Waves cyan
    case "omg", "omg-network":
        return Color(red: 0.8, green: 0.2, blue: 0.2) // OMG Network red
    case "zrx", "0x":
        return Color(red: 0.0, green: 0.0, blue: 0.0) // 0x black
    case "bat", "basic-attention-token":
        return Color(red: 0.8, green: 0.4, blue: 0.2) // Basic Attention Token orange
    case "knc", "kyber-network":
        return Color(red: 0.0, green: 0.6, blue: 0.8) // Kyber Network cyan
    case "lrc", "loopring":
        return Color(red: 0.0, green: 0.4, blue: 0.8) // Loopring blue
    case "rep", "augur":
        return Color(red: 0.8, green: 0.2, blue: 0.2) // Augur red
    case "gnt", "golem":
        return Color(red: 0.0, green: 0.6, blue: 0.4) // Golem teal
    case "mkr", "maker":
        return Color(red: 0.8, green: 0.4, blue: 0.2) // Maker orange
    case "snx", "synthetix":
        return Color(red: 0.0, green: 0.0, blue: 0.0) // Synthetix black
    case "comp", "compound":
        return Color(red: 0.0, green: 0.6, blue: 0.8) // Compound cyan
    case "yfi", "yearn-finance":
        return Color(red: 0.0, green: 0.6, blue: 0.4) // Yearn Finance teal
    case "uni", "uniswap":
        return Color(red: 0.8, green: 0.2, blue: 0.8) // Uniswap pink
    case "aave":
        return Color(red: 0.8, green: 0.2, blue: 0.2) // Aave red
    case "sushi", "sushiswap":
        return Color(red: 0.0, green: 0.6, blue: 0.4) // SushiSwap teal
    case "crv", "curve-dao-token":
        return Color(red: 0.0, green: 0.8, blue: 0.0) // Curve DAO Token green
    case "1inch":
        return Color(red: 0.0, green: 0.0, blue: 0.0) // 1inch black
    case "bal", "balancer":
        return Color(red: 0.0, green: 0.6, blue: 0.8) // Balancer cyan
    case "lpt", "livepeer":
        return Color(red: 0.0, green: 0.4, blue: 0.8) // Livepeer blue
    case "ren", "republic-protocol":
        return Color(red: 0.0, green: 0.0, blue: 0.0) // Republic Protocol black
    case "uma", "uma":
        return Color(red: 0.8, green: 0.4, blue: 0.2) // UMA orange
    case "band":
        return Color(red: 0.0, green: 0.6, blue: 0.4) // Band Protocol teal
    case "nkn":
        return Color(red: 0.0, green: 0.4, blue: 0.8) // NKN blue
    case "ocean", "ocean-protocol":
        return Color(red: 0.0, green: 0.6, blue: 0.8) // Ocean Protocol cyan
    case "rsr", "reserve-rights":
        return Color(red: 0.8, green: 0.2, blue: 0.2) // Reserve Rights red
    case "nmr", "numeraire":
        return Color(red: 0.0, green: 0.0, blue: 0.0) // Numeraire black
    case "ant", "aragon":
        return Color(red: 0.0, green: 0.6, blue: 0.8) // Aragon cyan
    case "lend", "ethlend":
        return Color(red: 0.0, green: 0.4, blue: 0.8) // Aave (formerly ETHLend) blue
    case "cvc", "civic":
        return Color(red: 0.0, green: 0.6, blue: 0.4) // Civic teal
    case "dnt", "district0x":
        return Color(red: 0.0, green: 0.0, blue: 0.0) // district0x black
    case "gno", "gnosis":
        return Color(red: 0.0, green: 0.6, blue: 0.4) // Gnosis teal
    case "powr", "power-ledger":
        return Color(red: 0.8, green: 0.4, blue: 0.2) // Power Ledger orange
    case "req", "request-network":
        return Color(red: 0.0, green: 0.4, blue: 0.8) // Request Network blue
    case "salt":
        return Color(red: 0.0, green: 0.6, blue: 0.8) // SALT cyan
    case "storj":
        return Color(red: 0.0, green: 0.4, blue: 0.8) // Storj blue
    case "sub", "substratum":
        return Color(red: 0.0, green: 0.6, blue: 0.4) // Substratum teal
    case "wtc", "waltonchain":
        return Color(red: 0.0, green: 0.0, blue: 0.0) // Waltonchain black
    case "zil", "zilliqa":
        return Color(red: 0.0, green: 0.6, blue: 0.8) // Zilliqa cyan
    case "fun", "funfair":
        return Color(red: 0.8, green: 0.4, blue: 0.2) // FunFair orange
    case "kcs", "kucoin-shares":
        return Color(red: 0.0, green: 0.6, blue: 0.4) // KuCoin Shares teal
    case "nano":
        return Color(red: 0.0, green: 0.4, blue: 0.8) // Nano blue
    case "iost":
        return Color(red: 0.8, green: 0.2, blue: 0.2) // IOST red
    case "btt", "bit torrent":
        return Color(red: 0.0, green: 0.6, blue: 0.8) // BitTorrent cyan
    case "hot", "holo":
        return Color(red: 0.0, green: 0.6, blue: 0.4) // Holo teal
    case "zrx", "0x-protocol":
        return Color(red: 0.0, green: 0.0, blue: 0.0) // 0x Protocol black
    case "icx", "icon":
        return Color(red: 0.0, green: 0.4, blue: 0.8) // ICON blue
    case "ont", "ontology":
        return Color(red: 0.0, green: 0.0, blue: 0.0) // Ontology black
    case "zec", "zcash":
        return Color(red: 0.8, green: 0.6, blue: 0.0) // Zcash yellow
    case "dash":
        return Color(red: 0.0, green: 0.6, blue: 0.8) // Dash cyan
    case "xlm", "stellar":
        return Color(red: 0.0, green: 0.4, blue: 0.8) // Stellar blue
    case "neo":
        return Color(red: 0.0, green: 0.8, blue: 0.0) // NEO green
    case "qtum":
        return Color(red: 0.8, green: 0.4, blue: 0.2) // Qtum orange
    case "waves":
        return Color(red: 0.0, green: 0.6, blue: 0.8) // Waves cyan
    case "omg", "omg-network":
        return Color(red: 0.8, green: 0.2, blue: 0.2) // OMG Network red
    case "zrx", "0x":
        return Color(red: 0.0, green: 0.0, blue: 0.0) // 0x black
    case "bat", "basic-attention-token":
        return Color(red: 0.8, green: 0.4, blue: 0.2) // Basic Attention Token orange
    case "knc", "kyber-network":
        return Color(red: 0.0, green: 0.6, blue: 0.8) // Kyber Network cyan
    case "lrc", "loopring":
        return Color(red: 0.0, green: 0.4, blue: 0.8) // Loopring blue
    case "rep", "augur":
        return Color(red: 0.8, green: 0.2, blue: 0.2) // Augur red
    case "gnt", "golem":
        return Color(red: 0.0, green: 0.6, blue: 0.4) // Golem teal
    case "mkr", "maker":
        return Color(red: 0.8, green: 0.4, blue: 0.2) // Maker orange
    case "snx", "synthetix":
        return Color(red: 0.0, green: 0.0, blue: 0.0) // Synthetix black
    case "comp", "compound":
        return Color(red: 0.0, green: 0.6, blue: 0.8) // Compound cyan
    case "yfi", "yearn-finance":
        return Color(red: 0.0, green: 0.6, blue: 0.4) // Yearn Finance teal
    case "uni", "uniswap":
        return Color(red: 0.8, green: 0.2, blue: 0.8) // Uniswap pink
    case "aave":
        return Color(red: 0.8, green: 0.2, blue: 0.2) // Aave red
    case "sushi", "sushiswap":
        return Color(red: 0.0, green: 0.6, blue: 0.4) // SushiSwap teal
    case "crv", "curve-dao-token":
        return Color(red: 0.0, green: 0.8, blue: 0.0) // Curve DAO Token green
    case "1inch":
        return Color(red: 0.0, green: 0.0, blue: 0.0) // 1inch black
    case "bal", "balancer":
        return Color(red: 0.0, green: 0.6, blue: 0.8) // Balancer cyan
    case "lpt", "livepeer":
        return Color(red: 0.0, green: 0.4, blue: 0.8) // Livepeer blue
    case "ren", "republic-protocol":
        return Color(red: 0.0, green: 0.0, blue: 0.0) // Republic Protocol black
    case "uma", "uma":
        return Color(red: 0.8, green: 0.4, blue: 0.2) // UMA orange
    case "band":
        return Color(red: 0.0, green: 0.6, blue: 0.4) // Band Protocol teal
    case "nkn":
        return Color(red: 0.0, green: 0.4, blue: 0.8) // NKN blue
    case "ocean", "ocean-protocol":
        return Color(red: 0.0, green: 0.6, blue: 0.8) // Ocean Protocol cyan
    case "rsr", "reserve-rights":
        return Color(red: 0.8, green: 0.2, blue: 0.2) // Reserve Rights red
    case "nmr", "numeraire":
        return Color(red: 0.0, green: 0.0, blue: 0.0) // Numeraire black
    case "ant", "aragon":
        return Color(red: 0.0, green: 0.6, blue: 0.8) // Aragon cyan
    case "lend", "ethlend":
        return Color(red: 0.0, green: 0.4, blue: 0.8) // Aave (formerly ETHLend) blue
    case "cvc", "civic":
        return Color(red: 0.0, green: 0.6, blue: 0.4) // Civic teal
    case "dnt", "district0x":
        return Color(red: 0.0, green: 0.0, blue: 0.0) // district0x black
    case "gno", "gnosis":
        return Color(red: 0.0, green: 0.6, blue: 0.4) // Gnosis teal
    case "powr", "power-ledger":
        return Color(red: 0.8, green: 0.4, blue: 0.2) // Power Ledger orange
    case "req", "request-network":
        return Color(red: 0.0, green: 0.4, blue: 0.8) // Request Network blue
    case "salt":
        return Color(red: 0.0, green: 0.6, blue: 0.8) // SALT cyan
    case "storj":
        return Color(red: 0.0, green: 0.4, blue: 0.8) // Storj blue
    case "sub", "substratum":
        return Color(red: 0.0, green: 0.6, blue: 0.4) // Substratum teal
    case "wtc", "waltonchain":
        return Color(red: 0.0, green: 0.0, blue: 0.0) // Waltonchain black
    case "zil", "zilliqa":
        return Color(red: 0.0, green: 0.6, blue: 0.8) // Zilliqa cyan
    case "fun", "funfair":
        return Color(red: 0.8, green: 0.4, blue: 0.2) // FunFair orange
    case "kcs", "kucoin-shares":
        return Color(red: 0.0, green: 0.6, blue: 0.4) // KuCoin Shares teal
    case "nano":
        return Color(red: 0.0, green: 0.4, blue: 0.8) // Nano blue
    case "iost":
        return Color(red: 0.8, green: 0.2, blue: 0.2) // IOST red
    case "btt", "bit torrent":
        return Color(red: 0.0, green: 0.6, blue: 0.8) // BitTorrent cyan
    case "hot", "holo":
        return Color(red: 0.0, green: 0.6, blue: 0.4) // Holo teal
    case "zrx", "0x-protocol":
        return Color(red: 0.0, green: 0.0, blue: 0.0) // 0x Protocol black
    case "icx", "icon":
        return Color(red: 0.0, green: 0.4, blue: 0.8) // ICON blue
    case "ont", "ontology":
        return Color(red: 0.0, green: 0.0, blue: 0.0) // Ontology black
    default:
        // Fallback: generate a color based on the symbol's hash
        let colors = [
            Color(red: 0.2, green: 0.4, blue: 0.8), // Blue
            Color(red: 0.8, green: 0.2, blue: 0.2), // Red
            Color(red: 0.0, green: 0.6, blue: 0.4), // Teal
            Color(red: 0.8, green: 0.4, blue: 0.2), // Orange
            Color(red: 0.6, green: 0.2, blue: 0.8), // Purple
            Color(red: 0.0, green: 0.8, blue: 0.0), // Green
            Color(red: 0.8, green: 0.8, blue: 0.2), // Yellow
            Color(red: 0.8, green: 0.2, blue: 0.8)  // Pink
        ]
        
        let hash = lowercasedSymbol.hashValue
        return colors[abs(hash) % colors.count]
    }
}

// MARK: - Extensions

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

extension Double {
    var asFormattedCurrency: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        formatter.currencySymbol = "$"
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 2
        
        // Add spaces for thousands separator like in the image
        let formatted = formatter.string(from: NSNumber(value: self)) ?? "$0.00"
        return formatted.replacingOccurrences(of: ",", with: " ")
    }
}