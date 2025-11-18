//
//  WalletViewModel.swift
//  Dojo
//
//  Created by Raymond Hou on 3/31/25.
//

//
//  WalletViewModel.swift
//  Dojo
//
//  Created by Raymond Hou on 3/31/25.
//

import SwiftUI
import LocalAuthentication
import Combine

class TradingWalletViewModel: ObservableObject {
    // MARK: Wallet Data
    @Published var walletBalance: Double = 178532.65
    @Published var assets: [DegenAsset] = [
        DegenAsset(symbol: "BTC",   name: "Bitcoin",  price: 87432.51, change:  3.2, sentiment: 78, trend: .up),
        DegenAsset(symbol: "ETH",   name: "Ethereum", price: 4521.32,  change:  1.8, sentiment: 65, trend: .up),
        DegenAsset(symbol: "SOL",   name: "Solana",   price: 198.45,   change:  5.4, sentiment: 82, trend: .up),
        DegenAsset(symbol: "XRP",   name: "Ripple",   price: 0.58,     change: -2.1, sentiment: 42, trend: .down),
        DegenAsset(symbol: "DOGE",  name: "Dogecoin", price: 0.12,     change:  0.3, sentiment: 58, trend: .neutral),
        DegenAsset(symbol: "AVAX",  name: "Avalanche",price: 35.76,    change: -1.5, sentiment: 47, trend: .down),
        DegenAsset(symbol: "MATIC", name: "Polygon",  price: 0.87,     change:  2.3, sentiment: 71, trend: .up)
    ]
    
    // MARK: Multi-Wallet Tracking
    @Published var trackedWallets: [TrackedWallet] = []
    @Published var presetWallets: [TrackedWallet] = []
    @Published var customWallets: [TrackedWallet] = []
    @Published var selectedWallet: TrackedWallet?
    @Published var selectedChain: Blockchain = .ethereum
    @Published var isAddingNewWallet: Bool = false
    @Published var newWalletAddress: String = ""
    @Published var newWalletLabel: String = ""
    @Published var isLoading: Bool = false
    @Published var showErrorAlert: Bool = false
    @Published var errorMessage: String = ""
    @Published var timeFilter: TimeFilter = .day
    @Published var sortOption: WalletSortOption = .balance
    
    var marketBullishPercentage: Int = 68
    var marketBearishPercentage: Int = 32
    
    // Cancellables for API requests
    private var cancellables = Set<AnyCancellable>()
    
    enum TimeFilter: String, CaseIterable, Identifiable {
        case hour = "1H"
        case day = "24H"
        case week = "7D"
        case month = "30D"
        case year = "1Y"
        
        var id: String { rawValue }
    }
    
    enum WalletSortOption: String, CaseIterable, Identifiable {
        case balance = "Balance"
        case profit = "Profit"
        case activity = "Activity"
        case alphabetical = "A-Z"
        
        var id: String { rawValue }
    }
    
    init() {
        
        // Load demo data
        loadPresetWallets()
    }
    
    // MARK: - Wallet Tracking Functions
    
    func loadPresetWallets() {
        // Simulate loading some popular/notable wallets as presets
        let presets = [
            TrackedWallet(
                address: "0x95222290DD7278Aa3Ddd389Cc1E1d165CC4BAfe5",
                label: "Ethereum Foundation",
                chain: .ethereum,
                balance: 12893254.87,
                assets: generateRandomAssets(count: 8),
                transactions: generateRandomTransactions(count: 15),
                isVerified: true,
                pnlData: generatePnLData(),
                type: .preset
            ),
            TrackedWallet(
                address: "0x3eF51B5089d53D7AeCD242Bf696ECb49334dD103",
                label: "Solana Treasury",
                chain: .solana,
                balance: 37192543.21,
                assets: generateRandomAssets(count: 5),
                transactions: generateRandomTransactions(count: 12),
                isVerified: true,
                pnlData: generatePnLData(),
                type: .preset
            ),
            TrackedWallet(
                address: "0xf977814e90da44bfa03b6295a0616a897441acec",
                label: "Binance Hot Wallet",
                chain: .binance,
                balance: 984632145.32,
                assets: generateRandomAssets(count: 12),
                transactions: generateRandomTransactions(count: 25),
                isVerified: true,
                pnlData: generatePnLData(),
                type: .preset
            ),
            TrackedWallet(
                address: "0x28C6c06298d514Db089934071355E5743bf21d60",
                label: "Binance Cold Wallet",
                chain: .binance,
                balance: 2483621987.32,
                assets: generateRandomAssets(count: 9),
                transactions: generateRandomTransactions(count: 5),
                isVerified: true,
                pnlData: generatePnLData(),
                type: .preset
            ),
            TrackedWallet(
                address: "0x06012c8cf97BEaD5deAe237070F9587f8E7A266d",
                label: "CryptoKitties",
                chain: .ethereum,
                balance: 589324.76,
                assets: generateRandomAssets(count: 6, includeNFTs: true),
                transactions: generateRandomTransactions(count: 18),
                isVerified: true,
                pnlData: generatePnLData(),
                type: .preset
            )
        ]
        
        self.presetWallets = presets
        self.trackedWallets = presets + self.customWallets
    }
    
    func addCustomWallet() {
        guard !newWalletAddress.isEmpty else {
            self.errorMessage = "Wallet address cannot be empty"
            self.showErrorAlert = true
            return
        }
        
        // Simulate loading/verification
        self.isLoading = true
        
        // Simulate API call to check if wallet is valid
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            let label = self.newWalletLabel.isEmpty ? "Wallet \(self.customWallets.count + 1)" : self.newWalletLabel
            
            let newWallet = TrackedWallet(
                address: self.newWalletAddress,
                label: label,
                chain: self.selectedChain,
                balance: Double.random(in: 10000...5000000),
                assets: self.generateRandomAssets(count: Int.random(in: 3...12)),
                transactions: self.generateRandomTransactions(count: Int.random(in: 5...20)),
                isVerified: false,
                pnlData: self.generatePnLData(),
                type: .custom
            )
            
            self.customWallets.append(newWallet)
            self.trackedWallets = self.presetWallets + self.customWallets
            self.selectedWallet = newWallet
            
            // Reset form
            self.newWalletAddress = ""
            self.newWalletLabel = ""
            self.isLoading = false
            self.isAddingNewWallet = false
        }
    }
    
    func removeWallet(_ wallet: TrackedWallet) {
        if let index = customWallets.firstIndex(where: { $0.id == wallet.id }) {
            customWallets.remove(at: index)
            trackedWallets = presetWallets + customWallets
            
            if selectedWallet?.id == wallet.id {
                selectedWallet = trackedWallets.first
            }
        }
    }
    
    func refreshWalletData(_ wallet: TrackedWallet) {
        isLoading = true
        
        // Simulate API call
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            // Find and update the wallet with new data
            if let index = self.trackedWallets.firstIndex(where: { $0.id == wallet.id }) {
                var updatedWallet = self.trackedWallets[index]
                
                // Update with new random data for demo purposes
                let priceChangeFactor = Double.random(in: 0.95...1.05)
                updatedWallet.balance = updatedWallet.balance * priceChangeFactor
                
                // Update assets with random changes
                for i in 0..<updatedWallet.assets.count {
                    let changePercent = Double.random(in: -5.0...5.0)
                    let newPrice = updatedWallet.assets[i].price * (1 + (changePercent / 100))
                    updatedWallet.assets[i].price = newPrice
                    updatedWallet.assets[i].change = changePercent
                    updatedWallet.assets[i].trend = changePercent > 0 ? .up : (changePercent < 0 ? .down : .neutral)
                }
                
                // Add a new random transaction
                let newTransaction = self.generateRandomTransactions(count: 1).first!
                updatedWallet.transactions.insert(newTransaction, at: 0)
                
                // Update PnL data
                let newPnLEntry = PnLEntry(
                    date: Date(),
                    value: updatedWallet.balance,
                    percentChange: Double.random(in: -5.0...5.0)
                )
                updatedWallet.pnlData.append(newPnLEntry)
                
                // Update the wallet in arrays
                self.trackedWallets[index] = updatedWallet
                
                if let customIndex = self.customWallets.firstIndex(where: { $0.id == wallet.id }) {
                    self.customWallets[customIndex] = updatedWallet
                } else if let presetIndex = self.presetWallets.firstIndex(where: { $0.id == wallet.id }) {
                    self.presetWallets[presetIndex] = updatedWallet
                }
                
                // Update selected wallet if needed
                if self.selectedWallet?.id == wallet.id {
                    self.selectedWallet = updatedWallet
                }
            }
            
            self.isLoading = false
        }
    }
    
    func filterWalletsByChain(_ chain: Blockchain?) -> [TrackedWallet] {
        if let chain = chain {
            return trackedWallets.filter { $0.chain == chain }
        } else {
            return trackedWallets
        }
    }
    
    func sortWallets(_ wallets: [TrackedWallet]) -> [TrackedWallet] {
        switch sortOption {
        case .balance:
            return wallets.sorted { $0.balance > $1.balance }
        case .profit:
            return wallets.sorted { $0.pnlPercentage > $1.pnlPercentage }
        case .activity:
            return wallets.sorted { $0.transactions.count > $1.transactions.count }
        case .alphabetical:
            return wallets.sorted { $0.label < $1.label }
        }
    }
    
    // MARK: - Data Generation Helpers
    
    func generateRandomAssets(count: Int, includeNFTs: Bool = false) -> [WalletAsset] {
        let tokenSymbols = ["BTC", "ETH", "SOL", "MATIC", "AVAX", "LINK", "APE", "UNI", "AAVE", "DOT", "ADA", "LTC", "XRP", "PEPE", "DOGE", "ICP", "MKR", "USDC", "USDT", "DAI"]
        let tokenNames = ["Bitcoin", "Ethereum", "Solana", "Polygon", "Avalanche", "Chainlink", "ApeCoin", "Uniswap", "Aave", "Polkadot", "Cardano", "Litecoin", "Ripple", "Pepe", "Dogecoin", "Internet Computer", "Maker", "USD Coin", "Tether", "Dai"]
        
        var assets: [WalletAsset] = []
        
        // Add tokens
        for i in 0..<min(count, tokenSymbols.count) {
            let price = i < 2 ? Double.random(in: 1000...100000) : Double.random(in: 0.1...1000)
            let quantity = Double.random(in: 0.5...100)
            let change = Double.random(in: -15.0...15.0)
            let sentiment = Int.random(in: 30...90)
            
            let trend: DegenAsset.TrendDirection = change > 0 ? .up : (change < 0 ? .down : .neutral)
            
            assets.append(WalletAsset(
                symbol: tokenSymbols[i],
                name: tokenNames[i],
                price: price,
                quantity: quantity,
                value: price * quantity,
                change: change,
                sentiment: sentiment,
                trend: trend,
                isNFT: false
            ))
        }
        
        // Add NFTs if requested
        if includeNFTs {
            let nftCollections = ["Bored Ape", "CryptoPunk", "Azuki", "Doodles", "Art Blocks"]
            
            for i in 0..<min(3, nftCollections.count) {
                let price = Double.random(in: 5...100) * 1000
                let quantity = Double(Int.random(in: 1...5))
                let change = Double.random(in: -30.0...30.0)
                let sentiment = Int.random(in: 40...95)
                
                let trend: DegenAsset.TrendDirection = change > 0 ? .up : (change < 0 ? .down : .neutral)
                
                assets.append(WalletAsset(
                    symbol: "NFT",
                    name: nftCollections[i],
                    price: price,
                    quantity: quantity,
                    value: price * quantity,
                    change: change,
                    sentiment: sentiment,
                    trend: trend,
                    isNFT: true
                ))
            }
        }
        
        return assets
    }
    
    func generateRandomTransactions(count: Int) -> [WalletTransaction] {
        var transactions: [WalletTransaction] = []
        
        let now = Date()
        let tokenSymbols = ["ETH", "BTC", "SOL", "MATIC", "AVAX", "USDC", "USDT", "DAI"]
        let actionTypes: [TransactionType] = [.buy, .sell, .swap, .transfer]
        
        for i in 0..<count {
            let timeAgo = TimeInterval(i * Int.random(in: 3600...86400))
            let date = now.addingTimeInterval(-timeAgo)
            
            let type = actionTypes.randomElement()!
            let tokenA = tokenSymbols.randomElement()!
            var tokenB = tokenSymbols.randomElement()!
            while tokenA == tokenB {
                tokenB = tokenSymbols.randomElement()!
            }
            
            let amount = type == .transfer ? Double.random(in: 0.01...5.0) : Double.random(in: 100...10000)
            let fee = Double.random(in: 1...50)
            
            let transaction = WalletTransaction(
                hash: "0x" + UUID().uuidString.replacingOccurrences(of: "-", with: ""),
                date: date,
                type: type,
                amount: amount,
                token: tokenA,
                swapToken: type == .swap ? tokenB : nil,
                fee: fee,
                successful: Bool.random()
            )
            
            transactions.append(transaction)
        }
        
        return transactions.sorted(by: { $0.date > $1.date })
    }
    
    func generatePnLData() -> [PnLEntry] {
        var entries: [PnLEntry] = []
        let now = Date()
        
        // Generate data for past year
        var cumulativeValue = Double.random(in: 50000...500000)
        
        for i in 0..<365 {
            let daysAgo = TimeInterval(i * 86400)
            let date = now.addingTimeInterval(-daysAgo)
            
            // Random daily fluctuation
            let dailyChange = Double.random(in: -0.05...0.05)
            cumulativeValue *= (1 + dailyChange)
            
            entries.append(PnLEntry(
                date: date,
                value: cumulativeValue,
                percentChange: dailyChange * 100
            ))
        }
        
        return entries.reversed()
    }
}

// MARK: - New Models

enum Blockchain: String, CaseIterable, Identifiable {
    case ethereum = "Ethereum"
    case binance = "Binance"
    case solana = "Solana"
    case polygon = "Polygon"
    case avalanche = "Avalanche"
    case arbitrum = "Arbitrum"
    case optimism = "Optimism"
    
    var id: String { rawValue }
    
    var symbol: String {
        switch self {
        case .ethereum: return "ETH"
        case .binance: return "BNB"
        case .solana: return "SOL"
        case .polygon: return "MATIC"
        case .avalanche: return "AVAX"
        case .arbitrum: return "ARB"
        case .optimism: return "OP"
        }
    }
    
    var color: Color {
        switch self {
        case .ethereum: return Color(hex: "#627EEA")
        case .binance: return Color(hex: "#F3BA2F")
        case .solana: return Color(hex: "#9945FF")
        case .polygon: return Color(hex: "#8247E5")
        case .avalanche: return Color(hex: "#E84142")
        case .arbitrum: return Color(hex: "#2D374B")
        case .optimism: return Color(hex: "#FF0420")
        }
    }
    
    var gradient: [Color] {
        switch self {
        case .ethereum: return [Color(hex: "#627EEA"), Color(hex: "#8194f0")]
        case .binance: return [Color(hex: "#F3BA2F"), Color(hex: "#f7cc5c")]
        case .solana: return [Color(hex: "#9945FF"), Color(hex: "#b370ff")]
        case .polygon: return [Color(hex: "#8247E5"), Color(hex: "#9d6eeb")]
        case .avalanche: return [Color(hex: "#E84142"), Color(hex: "#f16e6f")]
        case .arbitrum: return [Color(hex: "#2D374B"), Color(hex: "#3d4a66")]
        case .optimism: return [Color(hex: "#FF0420"), Color(hex: "#ff4c60")]
        }
    }
}

enum TrackingWalletType {
    case preset
    case custom
}

enum TransactionType: String {
    case buy = "Buy"
    case sell = "Sell"
    case swap = "Swap"
    case transfer = "Transfer"
    
    var icon: String {
        switch self {
        case .buy: return "arrow.down.circle.fill"
        case .sell: return "arrow.up.circle.fill"
        case .swap: return "arrow.triangle.2.circlepath.circle.fill"
        case .transfer: return "arrow.right.circle.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .buy: return .green
        case .sell: return .red
        case .swap: return .blue
        case .transfer: return .orange
        }
    }
}

struct WalletAsset: Identifiable, Equatable {
    let id = UUID()
    let symbol: String
    let name: String
    var price: Double
    let quantity: Double
    var value: Double
    var change: Double
    let sentiment: Int
    var trend: DegenAsset.TrendDirection
    let isNFT: Bool
    
    var changeText: String {
        return change >= 0
            ? "+\(String(format: "%.1f", change))%"
            : "\(String(format: "%.1f", change))%"
    }
    
    var changeColor: Color {
        change >= 0 ? .green : .red
    }
    
    var sentimentColor: Color {
        if sentiment > 70 {
            return .green
        } else if sentiment > 50 {
            return .blue
        } else if sentiment > 30 {
            return .yellow
        } else {
            return .red
        }
    }
}

struct WalletTransaction: Identifiable {
    let id = UUID()
    let hash: String
    let date: Date
    let type: TransactionType
    let amount: Double
    let token: String
    let swapToken: String?
    let fee: Double
    let successful: Bool
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    var timeAgo: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

struct PnLEntry: Identifiable {
    let id = UUID()
    let date: Date
    let value: Double
    let percentChange: Double
    
    var color: Color {
        if percentChange > 5 {
            return Color.green
        } else if percentChange > 0 {
            return Color.green.opacity(0.7)
        } else if percentChange == 0 {
            return Color.gray
        } else if percentChange > -5 {
            return Color.red.opacity(0.7)
        } else {
            return Color.red
        }
    }
}

struct TrackedWallet: Identifiable, Equatable {
    let id = UUID()
    let address: String
    var label: String
    let chain: Blockchain
    var balance: Double
    var assets: [WalletAsset]
    var transactions: [WalletTransaction]
    let isVerified: Bool
    var pnlData: [PnLEntry]
    let type: TrackingWalletType
    
    static func == (lhs: TrackedWallet, rhs: TrackedWallet) -> Bool {
        lhs.id == rhs.id
    }
    
    var formattedBalance: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = "$"
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        return formatter.string(from: NSNumber(value: balance)) ?? "$\(balance)"
    }
    
    var shortAddress: String {
        guard address.count > 12 else { return address }
        let start = address.prefix(6)
        let end = address.suffix(4)
        return "\(start)...\(end)"
    }
    
    var lastTransaction: WalletTransaction? {
        return transactions.first
    }
    
    var transactionFrequency: String {
        guard !transactions.isEmpty else { return "No activity" }
        
        let count = transactions.count
        let firstDate = transactions.last?.date ?? Date()
        let lastDate = transactions.first?.date ?? Date()
        
        let daysBetween = Calendar.current.dateComponents([.day], from: firstDate, to: lastDate).day ?? 1
        
        if daysBetween < 1 {
            return "\(count) txns today"
        } else {
            let txnsPerDay = Double(count) / Double(max(1, daysBetween))
            return String(format: "%.1f txns/day", txnsPerDay)
        }
    }
    
    var pnlPercentage: Double {
        guard pnlData.count >= 2 else { return 0 }
        
        let current = pnlData.last!.value
        let initial = pnlData.first!.value
        
        return ((current - initial) / initial) * 100
    }
    
    var pnlText: String {
        return pnlPercentage >= 0
            ? "+\(String(format: "%.1f", pnlPercentage))%"
            : "\(String(format: "%.1f", pnlPercentage))%"
    }
    
    var pnlColor: Color {
        pnlPercentage >= 0 ? .green : .red
    }
}

// MARK: - UI Helper Extensions

// MARK: - Reusable UI Components

struct DegenAsset: Identifiable, Equatable {
    let id = UUID()
    let symbol: String
    let name: String
    let price: Double
    let change: Double
    let sentiment: Int
    let trend: TrendDirection
    
    enum TrendDirection: String {
        case up = "up"
        case down = "down"
        case neutral = "neutral"
    }
    
    var displayPrice: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = "$"
        
        if price > 1000 {
            formatter.maximumFractionDigits = 0
        } else if price > 1 {
            formatter.maximumFractionDigits = 2
        } else {
            formatter.maximumFractionDigits = 4
        }
        
        return formatter.string(from: NSNumber(value: price)) ?? "$\(price)"
    }
    
    var changeText: String {
        return change >= 0
            ? "+\(String(format: "%.1f", change))%"
            : "\(String(format: "%.1f", change))%"
    }
    
    var changeColor: Color {
        change >= 0 ? .green : .red
    }
    
    var sentimentColor: Color {
        if sentiment > 70 {
            return .green
        } else if sentiment > 50 {
            return .blue
        } else if sentiment > 30 {
            return .yellow
        } else {
            return .red
        }
    }
    
    static func == (lhs: DegenAsset, rhs: DegenAsset) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Portfolio Analysis Methods

extension TradingWalletViewModel {
    
    func getPortfolioDistribution() -> [(name: String, value: Double)] {
        var distribution: [(name: String, value: Double)] = []
        
        // Group assets by symbol/type
        var symbolTotals: [String: Double] = [:]
        
        for asset in assets {
            let symbol = asset.symbol
            let value = asset.price
            
            if let existingValue = symbolTotals[symbol] {
                symbolTotals[symbol] = existingValue + value
            } else {
                symbolTotals[symbol] = value
            }
        }
        
        // Convert to array and sort by value
        distribution = symbolTotals.map { (name: $0.key, value: $0.value) }
            .sorted(by: { $0.value > $1.value })
        
        return distribution
    }
    
    func getPortfolioPerformance(timeframe: TimeFilter) -> Double {
        // Calculate portfolio performance based on timeframe
        switch timeframe {
        case .hour:
            return Double.random(in: -2.0...2.0)
        case .day:
            return Double.random(in: -5.0...5.0)
        case .week:
            return Double.random(in: -12.0...12.0)
        case .month:
            return Double.random(in: -25.0...25.0)
        case .year:
            return Double.random(in: -45.0...45.0)
        }
    }
    
    func getHistoricalData(for wallet: TrackedWallet, timeframe: TimeFilter) -> [(date: Date, value: Double)] {
        // Filter PnL data based on timeframe
        let now = Date()
        let filteredData: [PnLEntry]
        
        switch timeframe {
        case .hour:
            filteredData = wallet.pnlData.filter {
                $0.date.timeIntervalSince(now) > -3600
            }
        case .day:
            filteredData = wallet.pnlData.filter {
                $0.date.timeIntervalSince(now) > -86400
            }
        case .week:
            filteredData = wallet.pnlData.filter {
                $0.date.timeIntervalSince(now) > -604800
            }
        case .month:
            filteredData = wallet.pnlData.filter {
                $0.date.timeIntervalSince(now) > -2592000
            }
        case .year:
            filteredData = wallet.pnlData
        }
        
        return filteredData.map { (date: $0.date, value: $0.value) }
    }
    
    func getMarketSentiment() -> (bullish: Int, bearish: Int) {
        return (bullish: marketBullishPercentage, bearish: marketBearishPercentage)
    }
}

// MARK: - Wallet Search and Filtering

extension TradingWalletViewModel {
    
    func searchWallets(query: String) -> [TrackedWallet] {
        guard !query.isEmpty else { return trackedWallets }
        
        return trackedWallets.filter { wallet in
            wallet.label.lowercased().contains(query.lowercased()) ||
            wallet.address.lowercased().contains(query.lowercased()) ||
            wallet.chain.rawValue.lowercased().contains(query.lowercased())
        }
    }
    
    func filterWallets(by type: TrackingWalletType? = nil, minBalance: Double? = nil) -> [TrackedWallet] {
        var filtered = trackedWallets
        
        if let type = type {
            filtered = filtered.filter { $0.type == type }
        }
        
        if let minBalance = minBalance {
            filtered = filtered.filter { $0.balance >= minBalance }
        }
        
        return filtered
    }
    
    func getTopPerformingWallets(limit: Int = 3) -> [TrackedWallet] {
        return trackedWallets
            .sorted(by: { $0.pnlPercentage > $1.pnlPercentage })
            .prefix(limit)
            .map { $0 }
    }
    
    func getMostActiveWallets(limit: Int = 3) -> [TrackedWallet] {
        return trackedWallets
            .sorted(by: { $0.transactions.count > $1.transactions.count })
            .prefix(limit)
            .map { $0 }
    }
}
