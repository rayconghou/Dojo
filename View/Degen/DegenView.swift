//
//  DegenView.swift
//  Dojo
//
//  Created by Raymond Hou on 3/11/25.
//

import Foundation
import SwiftUI

// MARK: - DegenView Main Structure
struct DegenView: View {
    @Binding var isEnabled: Bool
    @State private var hideHamburger = false
    @State private var selectedTab: DegenTab = .trending
    
    // Enum to define Degen Tabs
    enum DegenTab {
        case trending
        case indexes
        case trade
        case portfolio
        case walletTracker
    }
    
    var body: some View {
        ZStack {
            // Dark background with casino-like vibe
            Color.black.edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 0) {
                // Top Header
                DegenHeaderBar()
                
                // Main Content Based on Selected Tab
                mainContentView
                
                // Bottom Navigation Bar
                bottomNavigationBar
            }
        }
    }
    
    
    // MARK: - Main Content View
    private var mainContentView: some View {
        Group {
            switch selectedTab {
            case .trending:
//                DegenTrendingView()
                SpotView(hideHamburger: $hideHamburger)
            case .indexes:
//                DegenIndexesView()
                IndexesView()
            case .trade:
                DegenTradeView()
            case .portfolio:
                DegenPortfolioView()
            case .walletTracker:
                WalletSocialMediaTrackerView()
            }
        }
        .transition(.asymmetric(insertion: .move(edge: .trailing),
                                removal: .move(edge: .leading)))
        .animation(.default, value: selectedTab)
    }
    
    // MARK: - Bottom Navigation Bar
    private var bottomNavigationBar: some View {
        HStack(spacing: 30) {
            tabBarItem(tab: .trending, icon: "flame", label: "Trending")
            tabBarItem(tab: .indexes, icon: "chart.bar", label: "Indexes")
            tabBarItem(tab: .trade, icon: "arrow.triangle.2.circlepath", label: "Trade")
            tabBarItem(tab: .portfolio, icon: "briefcase", label: "Portfolio")
            tabBarItem(tab: .walletTracker, icon: "wallet.pass", label: "Wallet")
        }
        .padding()
        .background(Color.gray.opacity(0.1))
    }
    
    // MARK: - Tab Bar Item Helper
    private func tabBarItem(tab: DegenTab, icon: String, label: String) -> some View {
        VStack {
            Image(systemName: icon)
                .foregroundColor(selectedTab == tab ? .orange : .white.opacity(0.6))
                .font(.system(size: 20))
            
                Text(label)
                    .font(.custom("Satoshi-Bold", size: 16))
                .foregroundColor(selectedTab == tab ? .orange : .white.opacity(0.6))
        }
        .onTapGesture {
            selectedTab = tab
        }
    }
}


// MARK: - Preview
struct DegenView_Previews: PreviewProvider {
    static var previews: some View {
        DegenView(isEnabled: .constant(true))
    }
}
