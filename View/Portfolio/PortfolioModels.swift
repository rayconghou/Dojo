//
//  PortfolioModels.swift
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

enum Timeframe: String, CaseIterable {
    case day = "24H"
    case week = "1W"
    case month = "1M"
    case year = "1Y"
    case all = "ALL"
}

enum PersonalWalletType: String, CaseIterable {
    case primary = "Primary Wallet"
    case secondary = "Secondary Wallet"
    case savings = "Savings Wallet"
    case trading = "Trading Wallet"
    case bank = "Bank Account"
}

struct PersonalWallet: Identifiable {
    let id = UUID()
    let type: PersonalWalletType
    let balance: String
    let change: String
    let isPositive: Bool
    let logo: String
    let logoColor: Color
}

enum PaymentMethodType: String, CaseIterable {
    case bank = "Bank Account"
    case card = "Credit Card"
    case applePay = "Apple Pay"
    case paypal = "PayPal"
}

struct PaymentMethod: Identifiable {
    let id = UUID()
    let type: PaymentMethodType
    let name: String
    let lastFour: String
    let logo: String
    let logoColor: Color
}

struct PortfolioCoin: Codable {
    let id: String
    let symbol: String
    let name: String
    let image: String
    let currentPrice: Double
    let marketCap: Double
    let totalVolume: Double
    let priceChange24h: Double
    let priceChangePercentage24h: Double
    let marketCapChange24h: Double
    let marketCapChangePercentage24h: Double
    let circulatingSupply: Double
    let totalSupply: Double
    let ath: Double
    let athChangePercentage: Double
    let athDate: String
    let atl: Double
    let atlChangePercentage: Double
    let atlDate: String
    let lastUpdated: String
}

// MARK: - Additional Models (referenced from other files)

// Note: AssetHolding is defined in Models/Asset.swift

// Note: PortfolioAsset is defined in Models/Asset.swift

// Note: Coin and SparklineData are defined in API/CryptoMarketFetcher.swift
