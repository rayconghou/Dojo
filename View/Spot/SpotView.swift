//
//  SpotView.swift
//  Dojo
//
//  Created by Raymond Hou on 3/11/25.
//  Updated for full market view and futuristic UI
//

import SwiftUI
import Foundation

enum SortOption: String, CaseIterable {
    case rank = "Rank"
    case marketCap = "Market Cap"
}

struct SpotView: View {
    @Binding var hideHamburger: Bool
    var hamburgerAction: () -> Void
    @State private var selectedCoin: Coin? = nil
    @State private var scrollOffset: CGFloat = 0
    @State private var searchText = ""
    
    @StateObject var marketVM = CryptoMarketViewModel()
    @State private var sortOption: SortOption = .rank
    
    // Sorted and filtered coins based on selected option and search text
    var filteredCoins: [Coin] {
        let sorted: [Coin]
        switch sortOption {
        case .rank:
            sorted = marketVM.coins.sorted { ($0.market_cap_rank ?? 9999) < ($1.market_cap_rank ?? 9999) }
        case .marketCap:
            sorted = marketVM.coins.sorted { ($0.market_cap ?? 0) > ($1.market_cap ?? 0) }
        }
        
        if searchText.isEmpty {
            return sorted
        } else {
            return sorted.filter {
                $0.name.localizedCaseInsensitiveContains(searchText) ||
                $0.symbol.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
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
                
                // Spot Tokens Title
                HStack {
                    Text("Spot Tokens")
                        .font(.custom("Satoshi-Bold", size: 28))
                        .foregroundColor(.white)
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 15)
                
                // Search Bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    
                    TextField("Search tokens", text: $searchText)
                        .foregroundColor(.white)
                    
                    if !searchText.isEmpty {
                        Button(action: {
                            searchText = ""
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.gray)
                        }
                    }
                }
                .padding(.vertical, 10)
                .padding(.horizontal, 20)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color(hex: "141628"))
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.white.opacity(0.1), lineWidth: 1)
                        )
                )
                .padding(.horizontal, 16)
                .padding(.bottom, 20)
                
                // Tokens List
                if marketVM.coins.isEmpty {
                    VStack(spacing: 20) {
                        ProgressView()
                            .scaleEffect(1.5)
                            .tint(.white)
                        Text("Loading market data...")
                            .font(.custom("Satoshi-Bold", size: 16))
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ScrollView {
                        LazyVStack(spacing: 24) {
                            ForEach(filteredCoins) { coin in
                                CryptoTrendCard(
                                    rank: coin.market_cap_rank ?? 0,
                                    name: coin.name,
                                    symbol: coin.symbol,
                                    imageUrl: coin.image,
                                    price: coin.current_price,
                                    change: coin.price_change_percentage_24h ?? 0,
                                    sparkline: coin.sparkline_in_7d?.price.last24Hours ?? coin.sparkline_in_7d?.price ?? []
                                )
                                .onTapGesture {
                                    selectedCoin = coin
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 16)
                    }
                }
                
                Spacer()
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
            .sheet(item: $selectedCoin) { (coin: Coin) in
                CoinDetailModalView(coin: coin, marketVM: marketVM)
            }
            .onAppear {
                marketVM.fetchData()
            }
    }
}

// Helper extension to extract the last 24 hours worth of sparkline data.
// Assumes the sparkline contains at least 24 points; otherwise returns the full array.
extension Array where Element == Double {
    var last24Hours: [Double] {
        if self.count >= 24 {
            return Array(self.suffix(24))
        } else {
            return self
        }
    }
}

struct OffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}


// Preview (make sure to bind hideHamburger to a constant for previewing)
struct SpotView_Previews: PreviewProvider {
    @State static var hideHamburger = false
    static var previews: some View {
        SpotView(hideHamburger: $hideHamburger, hamburgerAction: {})
            .preferredColorScheme(ColorScheme.dark)
    }
}
