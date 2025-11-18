//
//  Tweets.swift
//  Dojo
//
//  Created by Raymond Hou on 4/9/25.
//

import Foundation
import SwiftUI

/// Twitter-like card for sentiment analysis
struct TweetCard: View {
    var asset: DegenAsset
    var influencerType: SentimentFilterSelector.SentimentFilter
    
    // Sample data
    private var influencerName: String {
        switch influencerType {
        case .celebrities:
            return ["Elon Musk", "Mark Cuban", "Cathie Wood", "Chamath Palihapitiya", "Tim Draper"].randomElement()!
        case .whales:
            return ["Whale_Trader", "DefiGiant", "CryptoWhale", "TokenMaster", "BlockchainMonster"].randomElement()!
        case .trending:
            return ["@\(asset.symbol)Fan", "CryptoInsider", "MarketWatcher", "TradingPro", "FinanceGuru"].randomElement()!
        }
    }
    
    private var username: String {
        "@\(influencerName.replacingOccurrences(of: " ", with: ""))"
    }
    
    private var tweetTime: String {
        let times = ["2m", "15m", "32m", "1h", "3h", "5h"]
        return times.randomElement()!
    }
    
    private var tweetContent: String {
        let bullishTweets = [
            "$\(asset.symbol) looking really strong today. Technical indicators suggest possible breakout soon. #bullish",
            "Just increased my position in $\(asset.symbol). The fundamentals are better than ever. Long term hold.",
            "The team behind $\(asset.symbol) just announced a major partnership. This is huge news! 🚀",
            "$\(asset.symbol) chart forming a classic cup and handle. Expecting major movement in the next few days.",
            "Been following $\(asset.symbol) for months. This is the accumulation phase before the next leg up."
        ]
        
        let bearishTweets = [
            "Not liking what I'm seeing with $\(asset.symbol). Volume dropping off, might be time to take profits.",
            "$\(asset.symbol) showing weakness at key resistance levels. Proceed with caution.",
            "Just reduced my exposure to $\(asset.symbol). Risk/reward ratio isn't favorable right now.",
            "The latest news about $\(asset.symbol) is concerning. Might test support levels soon.",
            "$\(asset.symbol) technicals looking bearish on the 4h chart. Watch closely."
        ]
        
        return asset.sentiment > 50 ? bullishTweets.randomElement()! : bearishTweets.randomElement()!
    }
    
    private var engagementNumbers: (likes: Int, retweets: Int) {
        let magnitude = influencerType == .celebrities ? 1000 : 100
        return (
            likes: Int.random(in: 1...40) * magnitude,
            retweets: Int.random(in: 1...15) * magnitude
        )
    }
    
    private var sentimentIcon: String {
        asset.sentiment > 65 ? "arrow.up.circle.fill" :
            (asset.sentiment < 35 ? "arrow.down.circle.fill" : "minus.circle.fill")
    }
    
    private var sentimentColor: Color {
        asset.sentiment > 65 ? .green :
            (asset.sentiment < 35 ? .red : .orange)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header with influencer info
            HStack(spacing: 12) {
                // Profile pic placeholder
                ZStack {
                    Circle()
                        .fill(Color(hex: "2C1F41"))
                        .frame(width: 48, height: 48)
                        .overlay(
                            Circle()
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: [Color.black.opacity(0.3), Color.gray.opacity(0.1)]),
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                        )
                        .overlay(
                            Circle()
                                .stroke(Color(hex: "3C2D44"), lineWidth: 1)
                        )
                    
                    Text(String(influencerName.prefix(1)))
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 6) {
                        Text(influencerName)
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                        
                        if influencerType == .celebrities || influencerType == .whales {
                            Image("TwitterVerified")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 16, height: 16)
                        }
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.white.opacity(0.6))
                    }
                    
                    HStack(spacing: 4) {
                        Text(username)
                            .font(.system(size: 14, weight: .regular))
                            .foregroundColor(.white.opacity(0.7))
                        
                        Text("•")
                            .font(.system(size: 14, weight: .regular))
                            .foregroundColor(.white.opacity(0.7))
                        
                        Text(tweetTime)
                            .font(.system(size: 14, weight: .regular))
                            .foregroundColor(.white.opacity(0.7))
                    }
                }
            }
            
            // Asset tags
            HStack(spacing: 8) {
                Text("$\(asset.symbol)")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color(hex: "FBCFFF"),
                                Color(hex: "B16EFF"),
                                Color(hex: "F7B0FE")
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color(hex: "2C1F41"))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color(hex: "3C2D44"), lineWidth: 1)
                    )
                
                Spacer()
            }
            
            // Tweet content
            Text(tweetContent)
                .font(.system(size: 15, weight: .regular))
                .foregroundColor(.white)
                .lineSpacing(2)
            
            // Tweet engagement stats
            HStack(spacing: 16) {
                // Likes bubble
                HStack(spacing: 6) {
                    Image("Heart")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 14, height: 14)
                        .foregroundColor(.white)
                    
                    Text("\(engagementNumbers.likes)")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(hex: "2C1F41"))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color(hex: "3C2D44"), lineWidth: 1)
                )
                
                // Comments bubble
                HStack(spacing: 6) {
                    Image("Comment")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 14, height: 14)
                        .foregroundColor(.white)
                    
                    Text("\(engagementNumbers.retweets)")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(hex: "2C1F41"))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color(hex: "3C2D44"), lineWidth: 1)
                )
                
                // Reposts bubble
                HStack(spacing: 6) {
                    Image("Retweet")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 14, height: 14)
                        .foregroundColor(.white)
                    
                    Text("\(Int.random(in: 1...20) * 1000)")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(hex: "2C1F41"))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color(hex: "3C2D44"), lineWidth: 1)
                )
                
                Spacer()
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
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
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color(hex: "3C2D44"), lineWidth: 1)
        )
    }
}

/// Sentiment bubble component (keep the existing one with slight updates)
struct SentimentBubble: View {
    var sentiment: Int
    
    var color: Color {
        if sentiment > 70 {
            return Color.green
        } else if sentiment > 50 {
            return Color.blue
        } else if sentiment > 30 {
            return Color.orange
        } else {
            return Color.red
        }
    }
    
    var body: some View {
        ZStack {
            Circle()
                .fill(color.opacity(0.2))
            
            Circle()
                .stroke(color, lineWidth: 2)
            
            Text("\(sentiment)%")
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(color)
        }
    }
}

/// Custom segment picker for Trending/Celebrities/Whales
struct SentimentFilterSelector: View {
    @Binding var selectedFilter: SentimentFilter
    
    enum SentimentFilter: String, CaseIterable {
        case trending = "TRENDING"
        case celebrities = "CELEBRITIES"
        case whales = "WHALES"
    }
    
    var body: some View {
        HStack(spacing: 0) {
            // TRENDING Button
            Button(action: {
                selectedFilter = .trending
            }) {
                Text("TRENDING")
                    .font(.custom("Korosu", size: 15))
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 40)
                    .background(
                        selectedFilter == .trending ?
                        LinearGradient(
                            gradient: Gradient(colors: [Color(hex: "4F2FB6"), Color(hex: "F7B0FE")]),
                            startPoint: .leading,
                            endPoint: .trailing
                        ) :
                        LinearGradient(
                            gradient: Gradient(colors: [Color.clear, Color.clear]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(8, corners: [.topLeft, .bottomLeft])
            }
            
            // CELEBRITIES Button
            Button(action: {
                selectedFilter = .celebrities
            }) {
                Text("CELEBRITIES")
                    .font(.custom("Korosu", size: 15))
                    .fontWeight(.regular)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 40)
                    .background(
                        selectedFilter == .celebrities ?
                        LinearGradient(
                            gradient: Gradient(colors: [Color(hex: "4F2FB6"), Color(hex: "F7B0FE")]),
                            startPoint: .leading,
                            endPoint: .trailing
                        ) :
                        LinearGradient(
                            gradient: Gradient(colors: [Color.clear, Color.clear]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
            }
            
            // WHALES Button
            Button(action: {
                selectedFilter = .whales
            }) {
                Text("WHALES")
                    .font(.custom("Korosu", size: 15))
                    .fontWeight(.regular)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 40)
                    .background(
                        selectedFilter == .whales ?
                        LinearGradient(
                            gradient: Gradient(colors: [Color(hex: "4F2FB6"), Color(hex: "F7B0FE")]),
                            startPoint: .leading,
                            endPoint: .trailing
                        ) :
                        LinearGradient(
                            gradient: Gradient(colors: [Color.clear, Color.clear]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(8, corners: [.topRight, .bottomRight])
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(hex: "1A0B2E").opacity(0.8))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color(hex: "4A148C").opacity(0.6), lineWidth: 1)
        )
    }
}

/// The sentiment analysis view showing Twitter trends
struct SentimentAnalysisView: View {
    @ObservedObject var viewModel: TradingWalletViewModel
    @Binding var selectedAsset: DegenAsset?
    @Binding var selectedFilter: SentimentFilterSelector.SentimentFilter
    
    var body: some View {
        VStack(spacing: 0) {
            // Asset filter chip row
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    AssetFilterChip(
                        title: "All Assets",
                        isSelected: selectedAsset == nil,
                        action: {
                            withAnimation {
                                selectedAsset = nil
                            }
                        }
                    )
                    
                    ForEach(viewModel.assets) { asset in
                        AssetFilterChip(
                            title: asset.symbol,
                            isSelected: selectedAsset == asset,
                            action: {
                                withAnimation {
                                    if selectedAsset == asset {
                                        selectedAsset = nil
                                    } else {
                                        selectedAsset = asset
                                    }
                                }
                            }
                        )
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
            }
            
            // Sentiment tweets
            ScrollView {
                LazyVStack(spacing: 16) {
                    if let asset = selectedAsset {
                        // Show tweets for selected asset
                        ForEach(0..<5) { _ in
                            TweetCard(
                                asset: asset,
                                influencerType: selectedFilter
                            )
                        }
                    } else {
                        // Show tweets for all assets
                        ForEach(viewModel.assets) { asset in
                            TweetCard(
                                asset: asset,
                                influencerType: selectedFilter
                            )
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 24)
            }
        }
    }
}
