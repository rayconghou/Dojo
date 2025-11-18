//
//  PortfolioViewModel.swift
//  Dojo
//
//  Created by Raymond Hou on 3/11/25.
//

import Foundation
import SwiftUI

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
            PersonalWallet(type: .primary, balance: "10,543.27", change: "+2.5%", isPositive: true, logo: "briefcase.fill", logoColor: .blue),
            PersonalWallet(type: .secondary, balance: "5,321.89", change: "-1.2%", isPositive: false, logo: "banknote", logoColor: .green),
            PersonalWallet(type: .savings, balance: "2,150.50", change: "+0.8%", isPositive: true, logo: "building.columns.fill", logoColor: .purple),
            PersonalWallet(type: .trading, balance: "8,750.00", change: "+5.2%", isPositive: true, logo: "chart.line.uptrend.xyaxis", logoColor: .orange)
        ]
        
        // Set default selected wallet
        if let firstWallet = wallets.first {
            selectedWalletId = firstWallet.id.uuidString
        }
    }
    
    private func setupPaymentMethods() {
        paymentMethods = [
            PaymentMethod(type: .bank, name: "Chase Bank", lastFour: "4582", logo: "building.columns.fill", logoColor: .blue),
            PaymentMethod(type: .card, name: "Visa Debit", lastFour: "7629", logo: "creditcard.fill", logoColor: .blue),
            PaymentMethod(type: .card, name: "Mastercard", lastFour: "1284", logo: "creditcard.fill", logoColor: .red),
            PaymentMethod(type: .applePay, name: "Apple Pay", lastFour: "****", logo: "applelogo", logoColor: .black)
        ]
    }
    
    func addWallet(name: String, type: PersonalWalletType) {
        let newWallet = PersonalWallet(type: type, balance: "0.00", change: "0.0%", isPositive: true, logo: "briefcase.fill", logoColor: .blue)
        wallets.append(newWallet)
    }
    
    func removeWallet(at indexSet: IndexSet) {
        wallets.remove(atOffsets: indexSet)
        
        // If selected wallet was removed, select the first wallet
        if !wallets.contains(where: { $0.id.uuidString == selectedWalletId }) {
            selectedWalletId = wallets.first?.id.uuidString ?? ""
        }
    }
    
    func fetchData() {
        guard let url = URL(string: "https://api.coingecko.com/api/v3/coins/markets?vs_currency=usd&order=market_cap_desc&per_page=250&page=1&sparkline=false&price_change_percentage=24h") else {
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                // Handle error appropriately in production
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
                // Handle decoding error appropriately in production
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
