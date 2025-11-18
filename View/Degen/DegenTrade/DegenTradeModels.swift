//
//  DegenTradeModels.swift
//  Dojo
//
//  Created by Raymond Hou on 3/31/25.
//

import Foundation
import Combine
import SwiftUI

// MARK: - Models

enum Chain: String, CaseIterable {
    case sol = "solana"
    case eth = "ethereum"
    case base = "base"
    case bsc = "binance"
    
    var displayName: String {
        switch self {
        case .sol: return "Solana"
        case .eth: return "Ethereum"
        case .base: return "Base"
        case .bsc: return "BNB Chain"
        }
    }
    
    var iconName: String {
        switch self {
        case .sol: return "SOLVector"
        case .eth: return "ETHVector"
        case .base: return "BaseVector"
        case .bsc: return "BNBVector"
        }
    }
    
    var symbol: String {
        switch self {
        case .sol: return "SOL"
        case .eth: return "ETH"
        case .base: return "ETH"
        case .bsc: return "BNB"
        }
    }
    
    var platformID: String {
        switch self {
        case .sol: return "pump.fun"
        case .eth: return "extreme-degen"
        case .base: return "virtuals-clanker"
        case .bsc: return "four.meme"
        }
    }
    
    var explorerBaseURL: String {
        switch self {
        case .sol: return "https://solscan.io/token/"
        case .eth: return "https://etherscan.io/token/"
        case .base: return "https://basescan.org/token/"
        case .bsc: return "https://bscscan.com/token/"
        }
    }
    
    var dexScreenerURL: String {
        return "https://dexscreener.com/\(self.rawValue)"
    }
}

struct Token: Identifiable {
    var id: String
    var name: String
    var symbol: String
    var iconURL: String
    var price: Double
    var priceChangePercentage: Double
    var volume24h: Double
    var marketCap: Double?
    var totalSupply: Double?
    var contractAddress: String
    var chain: Chain
    var isNew: Bool
    var launchTime: Date
    var pairAddress: String?
    
    var priceFormatted: String {
        if price < 0.000001 {
            // Convert to micro (μ) - multiply by 1,000,000
            let microValue = price * 1_000_000
            return String(format: "$%.2fμ", microValue)
        } else if price < 0.00001 {
            // Convert to micro (μ) - multiply by 1,000,000
            let microValue = price * 1_000_000
            return String(format: "$%.1fμ", microValue)
        } else if price < 0.0001 {
            // Convert to micro (μ) - multiply by 1,000,000
            let microValue = price * 1_000_000
            return String(format: "$%.0fμ", microValue)
        } else if price < 0.001 {
            // Show as regular decimal with more precision
            return String(format: "$%.6f", price)
        } else if price < 0.01 {
            return String(format: "$%.5f", price)
        } else if price < 1 {
            return String(format: "$%.4f", price)
        } else {
            return String(format: "$%.2f", price)
        }
    }
    
    init(id: String, name: String, symbol: String, iconURL: String, price: Double, priceChangePercentage: Double, volume24h: Double, marketCap: Double? = nil, totalSupply: Double? = nil, contractAddress: String, chain: Chain, isNew: Bool, launchTime: Date, pairAddress: String? = nil) {
        self.id = id
        self.name = name
        self.symbol = symbol
        self.iconURL = iconURL
        self.price = price
        self.priceChangePercentage = priceChangePercentage
        self.volume24h = volume24h
        self.marketCap = marketCap
        self.totalSupply = totalSupply
        self.contractAddress = contractAddress
        self.chain = chain
        self.isNew = isNew
        self.launchTime = launchTime
        self.pairAddress = pairAddress
    }
}

// MARK: - API Service

class TokenAPIService {
    func fetchTokens(for chain: Chain) async throws -> [Token] {
        // In a real app, you would implement actual API calls
        // For now, we'll return mock data
        return try await getMockTokens(for: chain)
    }
    
    private func getMockTokens(for chain: Chain) async throws -> [Token] {
        // Simulate network request
        try await Task.sleep(nanoseconds: 1_500_000_000)
        
        let currentDate = Date()
        let oneHourAgo = currentDate.addingTimeInterval(-3600)
        let sixHoursAgo = currentDate.addingTimeInterval(-21600)
        let oneDayAgo = currentDate.addingTimeInterval(-86400)
        
        switch chain {
        case .sol:
            return [
                Token(id: "sol1", name: "Pump Protocol", symbol: "PUMP", iconURL: "https://example.com/pump.png", price: 0.00000234, priceChangePercentage: 124.5, volume24h: 1200000, marketCap: 5000000, totalSupply: 1000000000, contractAddress: "FGyKuCJghqwx8dQFwJesNxND3LoNMKksH2TDjHcbJxPa", chain: .sol, isNew: true, launchTime: oneHourAgo, pairAddress: "pump_sol_pair1"),
                Token(id: "sol2", name: "Solana Degen", symbol: "SDEGEN", iconURL: "https://example.com/sdegen.png", price: 0.0000456, priceChangePercentage: 45.2, volume24h: 750000, marketCap: 2500000, totalSupply: 500000000, contractAddress: "GXDWxq8nCYsT4xVhHfdJKL6hJqcmeNPEEzVL1SYKNNv2", chain: .sol, isNew: true, launchTime: sixHoursAgo, pairAddress: "pump_sol_pair2"),
                Token(id: "sol3", name: "Solana Moon", symbol: "SMOON", iconURL: "https://example.com/smoon.png", price: 0.000000078, priceChangePercentage: -12.3, volume24h: 350000, marketCap: 1200000, totalSupply: 10000000000, contractAddress: "HUmRLpbWG6mK5ckH7QA9YFXDeWzq4MZJQsi8Dg1pFsme", chain: .sol, isNew: false, launchTime: oneDayAgo, pairAddress: "pump_sol_pair3")
            ]
        case .eth:
            return [
                Token(id: "eth1", name: "Extreme Degen", symbol: "XDEGEN", iconURL: "https://example.com/xdegen.png", price: 0.00000567, priceChangePercentage: 89.3, volume24h: 1800000, marketCap: 8000000, totalSupply: 500000000, contractAddress: "0x7af963cf6d228e564e2a0aa0ddbf06210b38615d", chain: .eth, isNew: true, launchTime: oneHourAgo, pairAddress: "extreme_degen_pair1"),
                Token(id: "eth2", name: "Ethereum Rocket", symbol: "EROCKET", iconURL: "https://example.com/erocket.png", price: 0.0000123, priceChangePercentage: 56.7, volume24h: 950000, marketCap: 4500000, totalSupply: 250000000, contractAddress: "0x2b591e99afe9f32eaa6214f7b7629768c40eeb39", chain: .eth, isNew: true, launchTime: sixHoursAgo, pairAddress: "extreme_degen_pair2")
            ]
        case .base:
            return [
                Token(id: "base1", name: "Virtuals Protocol", symbol: "VIRT", iconURL: "https://example.com/virt.png", price: 0.0000345, priceChangePercentage: 67.8, volume24h: 1500000, marketCap: 7000000, totalSupply: 800000000, contractAddress: "0x1f9840a85d5af5bf1d1762f925bdaddc4201f984", chain: .base, isNew: true, launchTime: oneHourAgo, pairAddress: "virtuals_base_pair1"),
                Token(id: "base2", name: "Clanker Finance", symbol: "CLANK", iconURL: "https://example.com/clank.png", price: 0.00000789, priceChangePercentage: 125.4, volume24h: 2200000, marketCap: 9000000, totalSupply: 1000000000, contractAddress: "0xbb4cdb9cbd36b01bd1cbaebf2de08d9173bc095c", chain: .base, isNew: true, launchTime: sixHoursAgo, pairAddress: "clanker_base_pair1"),
                Token(id: "base3", name: "Base Bull", symbol: "BBULL", iconURL: "https://example.com/bbull.png", price: 0.0000567, priceChangePercentage: -8.9, volume24h: 850000, marketCap: 3500000, totalSupply: 500000000, contractAddress: "0x6b175474e89094c44da98b954eedeac495271d0f", chain: .base, isNew: false, launchTime: oneDayAgo, pairAddress: "virtuals_base_pair2")
            ]
        case .bsc:
            return [
                Token(id: "bsc1", name: "Four Meme", symbol: "4MEME", iconURL: "https://example.com/4meme.png", price: 0.00000123, priceChangePercentage: 234.5, volume24h: 3500000, marketCap: 12000000, totalSupply: 2000000000, contractAddress: "0x8ac76a51cc950d9822d68b83fe1ad97b32cd580d", chain: .bsc, isNew: true, launchTime: oneHourAgo, pairAddress: "four_meme_pair1"),
                Token(id: "bsc2", name: "BNB APE", symbol: "BAPE", iconURL: "https://example.com/bape.png", price: 0.0000456, priceChangePercentage: 67.8, volume24h: 1800000, marketCap: 7500000, totalSupply: 800000000, contractAddress: "0x55d398326f99059ff775485246999027b3197955", chain: .bsc, isNew: true, launchTime: sixHoursAgo, pairAddress: "four_meme_pair2"),
                Token(id: "bsc3", name: "Binance FOMO", symbol: "BFOMO", iconURL: "https://example.com/bfomo.png", price: 0.00000567, priceChangePercentage: 89.7, volume24h: 2500000, marketCap: 9500000, totalSupply: 1500000000, contractAddress: "0x7130d2a12b9bcbfae4f2634d864a1ee1ce3ead9c", chain: .bsc, isNew: false, launchTime: oneDayAgo, pairAddress: "four_meme_pair3")
            ]
        }
    }
    
    func getBridgeQuote(fromChain: Chain, toChain: Chain, amount: String) async throws -> (estimatedGas: String, estimatedReceiveAmount: String) {
        // Simulate network request
        try await Task.sleep(nanoseconds: 1_000_000_000)
        
        // In a real app, this would call Li.Fi or a similar bridging API
        let amountDouble = Double(amount) ?? 0
        let estimatedGas = String(format: "%.2f", (15...30).randomElement()!)
        let estimatedReceiveAmount = String(format: "%.6f", amountDouble * 0.995) // 0.5% fee
        
        return (estimatedGas, estimatedReceiveAmount)
    }
    
    func executeBridge(fromChain: Chain, toChain: Chain, amount: String) async throws -> Bool {
        // Simulate network request
        try await Task.sleep(nanoseconds: 2_000_000_000)
        
        // In a real app, this would call Li.Fi or a similar bridging API
        // Return success or failure
        return true
    }
    
    func getContractInfo(chain: Chain, contractAddress: String) async throws -> [String: Any] {
        // Simulate network request
        try await Task.sleep(nanoseconds: 1_000_000_000)
        
        // In a real app, this would call the blockchain explorer API
        return [
            "name": "Example Token",
            "symbol": "EXTKN",
            "totalSupply": 1000000000,
            "decimals": 18,
            "holders": 1234
        ]
    }
    
    func getDexScreenerData(chain: Chain, pairAddress: String) async throws -> [String: Any] {
        // Simulate network request
        try await Task.sleep(nanoseconds: 1_000_000_000)
        
        // In a real app, this would call the DexScreener API
        return [
            "price": 0.0000123,
            "priceChange24h": 45.6,
            "volume24h": 1500000,
            "liquidity": 500000,
            "fdv": 12000000
        ]
    }
}

// MARK: - View Model

class DegenTradeViewModel: ObservableObject {
    private let apiService = TokenAPIService()
    private var cancellables = Set<AnyCancellable>()
    
    // Token list state
    @Published var tokens: [Token] = []
    @Published var filteredTokens: [Token] = []
    @Published var selectedToken: Token?
    @Published var isLoading = false
    @Published var error: Error?
    
    // Bridge state
    @Published var fromChain: Chain = .sol
    @Published var toChain: Chain = .bsc
    @Published var bridgeAmount: String = ""
    @Published var estimatedGas: String = "0.00"
    @Published var estimatedReceiveAmount: String = "0.00"
    @Published var isBridgeLoading = false
    @Published var bridgeError: Error?
    @Published var bridgeSuccess = false
    
    var canBridge: Bool {
        let amount = Double(bridgeAmount) ?? 0
        return fromChain != toChain && amount > 0 && !isBridgeLoading
    }
    
    init() {
        // Setup bridge amount change publisher
        $bridgeAmount
            .debounce(for: .seconds(0.5), scheduler: RunLoop.main)
            .removeDuplicates()
            .filter { !$0.isEmpty }
            .sink { [weak self] amount in
                self?.updateBridgeQuote()
            }
            .store(in: &cancellables)
    }
    
    func fetchTokens(for chain: Chain) {
        isLoading = true
        error = nil
        
        Task {
            do {
                let fetchedTokens = try await apiService.fetchTokens(for: chain)
                await MainActor.run {
                    self.tokens = fetchedTokens
                    self.filteredTokens = fetchedTokens
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.error = error
                    self.isLoading = false
                }
            }
        }
    }
    
    func filterTokens(_ searchText: String) {
        if searchText.isEmpty {
            filteredTokens = tokens
        } else {
            filteredTokens = tokens.filter { token in
                token.name.lowercased().contains(searchText.lowercased()) ||
                token.symbol.lowercased().contains(searchText.lowercased()) ||
                token.contractAddress.lowercased().contains(searchText.lowercased())
            }
        }
    }
    
    func updateBridgeQuote() {
        guard canBridge else {
            estimatedGas = "0.00"
            estimatedReceiveAmount = "0.00"
            return
        }
        
        isBridgeLoading = true
        bridgeError = nil
        
        Task {
            do {
                let quote = try await apiService.getBridgeQuote(
                    fromChain: fromChain,
                    toChain: toChain,
                    amount: bridgeAmount
                )
                
                await MainActor.run {
                    self.estimatedGas = quote.estimatedGas
                    self.estimatedReceiveAmount = quote.estimatedReceiveAmount
                    self.isBridgeLoading = false
                }
            } catch {
                await MainActor.run {
                    self.bridgeError = error
                    self.isBridgeLoading = false
                }
            }
        }
    }
    
    func executeBridge() {
        guard canBridge else { return }
        
        isBridgeLoading = true
        bridgeError = nil
        bridgeSuccess = false
        
        Task {
            do {
                let success = try await apiService.executeBridge(
                    fromChain: fromChain,
                    toChain: toChain,
                    amount: bridgeAmount
                )
                
                await MainActor.run {
                    self.bridgeSuccess = success
                    self.isBridgeLoading = false
                }
            } catch {
                await MainActor.run {
                    self.bridgeError = error
                    self.isBridgeLoading = false
                }
            }
        }
    }
    
    func setMaxBridgeAmount() {
        // In a real app, this would fetch the user's balance for the selected token
        bridgeAmount = "0.5"
        updateBridgeQuote()
    }
    
    func openDexScreener(for token: Token) {
        guard let pairAddress = token.pairAddress else { return }
        let urlString = "\(token.chain.dexScreenerURL)/\(pairAddress)"
        
        if let url = URL(string: urlString) {
            UIApplication.shared.open(url)
        }
    }
    
    func openExplorer(for token: Token) {
        let urlString = "\(token.chain.explorerBaseURL)\(token.contractAddress)"
        
        if let url = URL(string: urlString) {
            UIApplication.shared.open(url)
        }
    }
}
