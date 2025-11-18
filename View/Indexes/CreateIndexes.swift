//
//  CreateIndexes.swift
//  Dojo
//
//  Created by Raymond Hou on 4/9/25.
//

import Foundation
import SwiftUI

// MARK: - Custom Index Creation Flow
struct CreateIndexView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedTab: IndexSourceTab
    @ObservedObject var leaderboardVM: LeaderboardViewModel
    @Binding var isPresented: Bool
    @State private var indexName = ""
    @State private var indexDescription = ""
    @State private var selectedCategory: IndexCategory = .all
    @State private var selectedCoins: [CoinIndex] = []
    @State private var searchText = ""
    @State private var currentStep = 0
    @State private var showingPreview = false
    @State private var isPublic = true
    @State private var assetAllocations: [String: Double] = [:]
    
    // Steps in the creation process
    let steps = ["Details", "Select Assets", "Allocation", "Preview"]
    
    var body: some View {
        ZStack {
            // Background - same as other screens
            Color(hex: "050715")
                .ignoresSafeArea(.all)
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "chevron.down")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.white)
                    }
                    
                    Spacer()
                    
                    Text("Index Creator")
                        .font(.custom("Satoshi-Bold", size: 24))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Color.clear
                        .frame(width: 18)
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 20)
                
                // Main content
                ScrollView {
                    switch currentStep {
                    case 0:
                        indexDetailsView
                    case 1:
                        coinSelectionView
                    case 2:
                        allocationView
                    case 3:
                        reviewView
                    default:
                        EmptyView()
                    }
                }
                
                // Bottom section
                VStack(spacing: 0) {
                    HStack(spacing: 16) {
                        if currentStep > 0 {
                            Button(action: {
                                withAnimation {
                                    currentStep -= 1
                                }
                            }) {
                                Text("Back")
                                    .font(.custom("Satoshi-Bold", size: 16))
                                    .foregroundColor(.black)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 16)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(Color.white)
                                    )
                            }
                        }
                        
                        Button(action: {
                            if currentStep < steps.count - 1 {
                                withAnimation {
                                    currentStep += 1
                                }
                            } else {
                                showingPreview = true
                            }
                        }) {
                            Text(currentStep < steps.count - 1 ? "Next Step" : "Create Index")
                                .font(.custom("Satoshi-Bold", size: 16))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(
                                            LinearGradient(
                                                gradient: Gradient(colors: [
                                                    Color(red: 0.2, green: 0.5, blue: 1.0),
                                                    Color(red: 0.1, green: 0.3, blue: 0.8)
                                                ]),
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                )
                        }
                        .disabled(!canProceedToNextStep)
                        .opacity(canProceedToNextStep ? 1.0 : 0.5)
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 16)
                    
                    HStack(spacing: 8) {
                        ForEach(0..<steps.count, id: \.self) { index in
                            Rectangle()
                                .fill(index <= currentStep ? Color.white : Color.gray.opacity(0.3))
                                .frame(height: 4)
                                .cornerRadius(2)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                }
            }
        }
    }
    
    // MARK: - Step 1: Index Details
    private var indexDetailsView: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Create a Custom Index")
                .font(.custom("Satoshi-Bold", size: 24))
                .foregroundColor(.white)
            
            Text("Start by giving your index a name and description that helps others understand your investment thesis.")
                .font(.custom("Satoshi-Bold", size: 16))
                .foregroundColor(.gray)
            
            Text("Name")
                .font(.custom("Satoshi-Bold", size: 16))
                .foregroundColor(.white)
            
            TextField("Index Name (e.g. AI Disruptors 2025)", text: $indexName)
                .font(.custom("Satoshi-Bold", size: 16))
                .foregroundColor(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(hex: "141628"))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.white.opacity(0.1), lineWidth: 1)
                        )
                )
            
            if currentStep == 0 && indexName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                Text("Index name is required")
                    .font(.custom("Satoshi-Bold", size: 12))
                    .foregroundColor(.red)
            }
            
            Text("Description")
                .font(.custom("Satoshi-Bold", size: 16))
                .foregroundColor(.white)
            
            TextField("Index Description (Optional)", text: $indexDescription)
                .font(.custom("Satoshi-Bold", size: 16))
                .foregroundColor(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(hex: "141628"))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.white.opacity(0.1), lineWidth: 1)
                        )
                )
            
            Text("Primary Category")
                .font(.custom("Satoshi-Bold", size: 16))
                .foregroundColor(.white)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                ForEach(IndexCategory.allCases, id: \.self) { category in
                    Button(action: {
                        selectedCategory = category
                    }) {
                        Text(category.rawValue)
                            .font(.custom("Satoshi-Bold", size: 14))
                            .foregroundColor(selectedCategory == category ? .black : .white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .frame(maxWidth: .infinity)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(selectedCategory == category ? Color.white : Color(hex: "141628"))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                                    )
                            )
                    }
                }
            }
            
            Text("Public Visibility")
                .font(.custom("Satoshi-Bold", size: 16))
                .foregroundColor(.white)
            
            HStack {
                Text("Public Indexes are visible to all users")
                    .font(.custom("Satoshi-Bold", size: 14))
                    .foregroundColor(.white)
                
                Spacer()
                
                Toggle("", isOn: $isPublic)
                    .toggleStyle(SwitchToggleStyle(tint: Color.blue))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(hex: "141628"))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                    )
            )
            
            Text("Index Picture")
                .font(.custom("Satoshi-Bold", size: 16))
                .foregroundColor(.white)
            
            HStack {
                Image(systemName: "person.circle")
                    .font(.system(size: 40))
                    .foregroundColor(.white)
                    .frame(width: 60, height: 60)
                    .background(Color.gray.opacity(0.2))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                
                Button(action: {
                    // TODO: Implement photo upload
                }) {
                    HStack {
                        Image(systemName: "arrow.up.circle")
                            .font(.system(size: 16))
                            .foregroundColor(.white)
                        
                        Text("Upload Photo")
                            .font(.custom("Satoshi-Bold", size: 14))
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(hex: "141628"))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
                            )
                    )
                }
                
                Spacer()
            }
        }
        .padding(.horizontal, 20)
    }
    
    // MARK: - Step 2: Select Assets
    private var coinSelectionView: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Select Assets")
                .font(.custom("Satoshi-Bold", size: 24))
                .foregroundColor(.white)
            
            Text("Choose up to 10 assets for your customs index.")
                .font(.custom("Satoshi-Bold", size: 16))
                .foregroundColor(.gray)
            
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                
                TextField("Search tokens", text: $searchText)
                    .font(.custom("Satoshi-Bold", size: 16))
                    .foregroundColor(.white)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(hex: "141628"))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                    )
            )
            
            LazyVStack(spacing: 12) {
                ForEach(mockCoins, id: \.symbol) { coin in
                    AssetSelectionCard(
                        coin: coin,
                        isSelected: selectedCoins.contains { $0.symbol == coin.symbol },
                        onToggle: {
                            if selectedCoins.contains(where: { $0.symbol == coin.symbol }) {
                                selectedCoins.removeAll { $0.symbol == coin.symbol }
                            } else if selectedCoins.count < 10 {
                                selectedCoins.append(coin)
                            }
                        }
                    )
                }
            }
            
            if currentStep == 1 && selectedCoins.isEmpty {
                Text("Please select at least one asset")
                    .font(.custom("Satoshi-Bold", size: 12))
                    .foregroundColor(.red)
            } else if currentStep == 1 && selectedCoins.count >= 10 {
                Text("Maximum 10 assets allowed")
                    .font(.custom("Satoshi-Bold", size: 12))
                    .foregroundColor(.orange)
            }
        }
        .padding(.horizontal, 20)
    }
    
    // MARK: - Step 3: Allocation
    private var allocationView: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Allocate your assets")
                .font(.custom("Satoshi-Bold", size: 24))
                .foregroundColor(.white)
            
            Text("Choose the percentage for each asset.")
                .font(.custom("Satoshi-Bold", size: 16))
                .foregroundColor(.gray)
            
            HStack {
                Image(systemName: "chart.pie")
                    .font(.system(size: 24))
                    .foregroundColor(.white)
                    .frame(width: 40, height: 40)
                    .background(Color.blue.opacity(0.2))
                    .clipShape(Circle())
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Total Allocated")
                        .font(.custom("Satoshi-Bold", size: 14))
                        .foregroundColor(.white)
                    
                    Text("\(Int(totalAllocation))%")
                        .font(.custom("Satoshi-Bold", size: 24))
                        .foregroundColor(.white)
                }
                
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(hex: "1A1C2E"))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                    )
            )
            
            if totalAllocation != 100 {
                HStack {
                    Image(systemName: "exclamationmark.triangle")
                        .foregroundColor(.red)
                    
                    Text("Please increase allocations to reach 100%")
                        .font(.custom("Satoshi-Bold", size: 14))
                        .foregroundColor(.white)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.red.opacity(0.2))
                )
            }
            
            Text("Asset Allocations")
                .font(.custom("Satoshi-Bold", size: 20))
                .foregroundColor(.white)
            
            LazyVStack(spacing: 12) {
                ForEach(selectedCoins, id: \.symbol) { coin in
                    AssetAllocationCard(
                        coin: coin,
                        allocation: assetAllocations[coin.symbol] ?? 0,
                        onAllocationChange: { newAllocation in
                            assetAllocations[coin.symbol] = newAllocation
                        },
                        onRemove: {
                            selectedCoins.removeAll { $0.symbol == coin.symbol }
                            assetAllocations.removeValue(forKey: coin.symbol)
                        }
                    )
                }
            }
        }
        .padding(.horizontal, 20)
    }
    
    // MARK: - Step 4: Review
    private var reviewView: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Preview Card")
                .font(.custom("Satoshi-Bold", size: 24))
                .foregroundColor(.white)
            
            HStack(spacing: 12) {
                Image("Profile")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 40, height: 40)
                    .clipShape(Circle())
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(indexName.isEmpty ? "AI James Select" : indexName)
                        .font(.custom("Satoshi-Bold", size: 16))
                        .foregroundColor(.white)
                    
                    Text("by @jameswang")
                        .font(.custom("Satoshi-Bold", size: 14))
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("▲ 0%")
                        .font(.custom("Satoshi-Bold", size: 16))
                        .foregroundColor(.green)
                    
                    Text("ROI")
                        .font(.custom("Satoshi-Bold", size: 14))
                        .foregroundColor(.gray)
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(hex: "141628"))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                    )
            )
            
            Text("Index Resume")
                .font(.custom("Satoshi-Bold", size: 20))
                .foregroundColor(.white)
            
            Text("Check all the settings of your index.")
                .font(.custom("Satoshi-Bold", size: 14))
                .foregroundColor(.gray)
            
            VStack(spacing: 12) {
                HStack {
                    Text("Name")
                        .font(.custom("Satoshi-Bold", size: 16))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Text(indexName.isEmpty ? "AI James Select" : indexName)
                        .font(.custom("Satoshi-Bold", size: 16))
                        .foregroundColor(.white)
                }
                
                HStack {
                    Text("Description")
                        .font(.custom("Satoshi-Bold", size: 16))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Text(indexDescription.isEmpty ? "The Best AI Meme Coins Selection of 2025" : indexDescription)
                        .font(.custom("Satoshi-Bold", size: 16))
                        .foregroundColor(.white)
                }
                
                HStack {
                    Text("Categories")
                        .font(.custom("Satoshi-Bold", size: 16))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    HStack(spacing: 8) {
                        Text("DeFi")
                            .font(.custom("Satoshi-Bold", size: 14))
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(Color(hex: "272A45"))
                            )
                        
                        Text("Gaming")
                            .font(.custom("Satoshi-Bold", size: 14))
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(Color(hex: "272A45"))
                            )
                    }
                }
                
                HStack {
                    Text("Visibility")
                        .font(.custom("Satoshi-Bold", size: 16))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("Public")
                            .font(.custom("Satoshi-Bold", size: 16))
                            .foregroundColor(.white)
                        
                        Text("Everyone can see your index")
                            .font(.custom("Satoshi-Bold", size: 14))
                            .foregroundColor(.gray)
                    }
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(hex: "141628"))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                    )
            )
            
            Text("Index Composition")
                .font(.custom("Satoshi-Bold", size: 20))
                .foregroundColor(.white)
            
            Text("Check all the assets allocations.")
                .font(.custom("Satoshi-Bold", size: 14))
                .foregroundColor(.gray)
            
            VStack(spacing: 12) {
                ForEach(selectedCoins, id: \.symbol) { coin in
                    HStack {
                        tokenIcon(for: coin.symbol)
                            .frame(width: 24, height: 24)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(coin.name)
                                .font(.custom("Satoshi-Bold", size: 18))
                                .foregroundColor(.white)
                            
                            Text(coin.symbol)
                                .font(.custom("Satoshi-Bold", size: 14))
                                .foregroundColor(.gray)
                        }
                        
                        Spacer()
                        
                        Text("\(Int(assetAllocations[coin.symbol] ?? 0))%")
                            .font(.custom("Satoshi-Bold", size: 18))
                            .foregroundColor(.white)
                    }
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(hex: "141628"))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                    )
            )
            
            Text("Projected Performance")
                .font(.custom("Satoshi-Bold", size: 20))
                .foregroundColor(.white)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                MetricCard(title: "Risk Rating", value: "Medium")
                MetricCard(title: "Est. Annual Return", value: "+12.4%")
                MetricCard(title: "Volatility", value: "Medium")
                MetricCard(title: "Sharpe Ratio", value: "1.32")
            }
        }
        .padding(.horizontal, 20)
    }
    
    // MARK: - Computed Properties
    private var totalAllocation: Double {
        assetAllocations.values.reduce(0, +)
    }
    
    private var canProceedToNextStep: Bool {
        switch currentStep {
        case 0: // Details step
            return !indexName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        case 1: // Select Assets step
            return !selectedCoins.isEmpty && selectedCoins.count <= 10
        case 2: // Allocation step
            return totalAllocation == 100.0 && !selectedCoins.isEmpty
        case 3: // Preview step
            return true // Always allow proceeding from preview
        default:
            return false
        }
    }
    
    private func tokenIcon(for symbol: String) -> some View {
        Group {
            switch symbol {
            case "BTC":
                ZStack {
                    Circle()
                        .fill(Color.orange)
                        .frame(width: 24, height: 24)
                    Text("₿")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                }
            case "ETH":
                ZStack {
                    Circle()
                        .fill(Color.blue)
                        .frame(width: 24, height: 24)
                    Text("Ξ")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                }
            case "XRP":
                ZStack {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.black)
                        .frame(width: 24, height: 24)
                    Text("X")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                }
            case "USDT":
                ZStack {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.green)
                        .frame(width: 24, height: 24)
                    Text("T")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                }
            case "SOL":
                ZStack {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.purple)
                        .frame(width: 24, height: 24)
                    Text("S")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                }
            case "USDC":
                ZStack {
                    Circle()
                        .fill(Color.blue)
                        .frame(width: 24, height: 24)
                    Text("$")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                }
            case "TRX":
                ZStack {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.red)
                        .frame(width: 24, height: 24)
                    Text("T")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white)
                }
            case "ADA":
                ZStack {
                    Circle()
                        .fill(Color.blue)
                        .frame(width: 24, height: 24)
                    Text("A")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                }
            default:
                ZStack {
                    Circle()
                        .fill(Color.gray)
                        .frame(width: 24, height: 24)
                    Text("?")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                }
            }
        }
    }
    
    private func coinColor(for symbol: String) -> Color {
        switch symbol {
        case "BTC": return .orange
        case "ETH": return .blue
        case "XRP": return .black
        case "USDT": return .green
        case "SOL": return .purple
        case "USDC": return .blue
        case "TRX": return .red
        case "ADA": return .blue
        default: return .gray
        }
    }
}

// MARK: - Asset Selection Card
struct AssetSelectionCard: View {
    let coin: CoinIndex
    let isSelected: Bool
    let onToggle: () -> Void
    
    var body: some View {
        Button(action: onToggle) {
            HStack(spacing: 12) {
                tokenIcon(for: coin.symbol)
                    .frame(width: 24, height: 24)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(coin.name)
                        .font(.custom("Satoshi-Bold", size: 16))
                        .foregroundColor(.white)
                    
                    Text(coin.symbol)
                        .font(.custom("Satoshi-Bold", size: 14))
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 2) {
                    Text(coin.price)
                        .font(.custom("Satoshi-Bold", size: 16))
                        .foregroundColor(.white)
                    
                    HStack(spacing: 4) {
                        Image(systemName: coin.change >= 0 ? "triangle.fill" : "triangle.fill")
                            .font(.system(size: 8))
                            .foregroundColor(coin.change >= 0 ? .green : .red)
                            .rotationEffect(.degrees(coin.change >= 0 ? 0 : 180))
                        
                        Text("\(coin.change >= 0 ? "+" : "")\(String(format: "%.2f", coin.change))%")
                            .font(.custom("Satoshi-Bold", size: 14))
                            .foregroundColor(coin.change >= 0 ? .green : .red)
                    }
                }
                
                Circle()
                    .fill(isSelected ? Color.blue : Color.clear)
                    .frame(width: 20, height: 20)
                    .overlay(
                        Circle()
                            .stroke(Color.white, lineWidth: 2)
                    )
            }
            .padding(16)
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
    
    private func tokenIcon(for symbol: String) -> some View {
        Group {
            switch symbol {
            case "BTC":
                ZStack {
                    Circle()
                        .fill(Color.orange)
                        .frame(width: 24, height: 24)
                    Text("₿")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                }
            case "ETH":
                ZStack {
                    Circle()
                        .fill(Color.blue)
                        .frame(width: 24, height: 24)
                    Text("Ξ")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                }
            case "XRP":
                ZStack {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.black)
                        .frame(width: 24, height: 24)
                    Text("X")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                }
            case "USDT":
                ZStack {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.green)
                        .frame(width: 24, height: 24)
                    Text("T")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                }
            case "SOL":
                ZStack {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.purple)
                        .frame(width: 24, height: 24)
                    Text("S")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                }
            case "USDC":
                ZStack {
                    Circle()
                        .fill(Color.blue)
                        .frame(width: 24, height: 24)
                    Text("$")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                }
            case "TRX":
                ZStack {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.red)
                        .frame(width: 24, height: 24)
                    Text("T")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white)
                }
            case "ADA":
                ZStack {
                    Circle()
                        .fill(Color.blue)
                        .frame(width: 24, height: 24)
                    Text("A")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                }
            default:
                ZStack {
                    Circle()
                        .fill(Color.gray)
                        .frame(width: 24, height: 24)
                    Text("?")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                }
            }
        }
    }
    
    private func coinColor(for symbol: String) -> Color {
        switch symbol {
        case "BTC": return .orange
        case "ETH": return .blue
        case "XRP": return .black
        case "USDT": return .green
        case "SOL": return .purple
        case "USDC": return .blue
        case "TRX": return .red
        case "ADA": return .blue
        default: return .gray
        }
    }
}

// MARK: - Asset Allocation Card
struct AssetAllocationCard: View {
    let coin: CoinIndex
    let allocation: Double
    let onAllocationChange: (Double) -> Void
    let onRemove: () -> Void
    
    @State private var isHoldingMinus = false
    @State private var isHoldingPlus = false
    @State private var holdTimer: Timer?
    
    var body: some View {
        HStack(spacing: 12) {
            tokenIcon(for: coin.symbol)
                .frame(width: 24, height: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(coin.name)
                    .font(.custom("Satoshi-Bold", size: 16))
                    .foregroundColor(.white)
                
                Text(coin.symbol)
                    .font(.custom("Satoshi-Bold", size: 14))
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            HStack(spacing: 8) {
                // Minus Button with hold functionality
                Button(action: {
                    if allocation > 0 {
                        onAllocationChange(allocation - 1)
                    }
                }) {
                    Image(systemName: "minus")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 32, height: 32)
                        .background(
                            Circle()
                                .fill(isHoldingMinus ? Color.red.opacity(0.6) : Color.gray.opacity(0.3))
                        )
                        .scaleEffect(isHoldingMinus ? 1.1 : 1.0)
                        .animation(.easeInOut(duration: 0.1), value: isHoldingMinus)
                }
                .onLongPressGesture(minimumDuration: 0.3, maximumDistance: 50) {
                    // Long press started
                    startHoldingMinus()
                } onPressingChanged: { pressing in
                    if !pressing {
                        // Long press ended
                        stopHolding()
                    }
                }
                .disabled(allocation <= 0)
                .opacity(allocation <= 0 ? 0.5 : 1.0)
                
                // Percentage display with more space
                Text("\(Int(allocation))%")
                    .font(.custom("Satoshi-Bold", size: 16))
                    .foregroundColor(.white)
                    .frame(minWidth: 50, maxWidth: 60)
                    .multilineTextAlignment(.center)
                    .animation(.easeInOut(duration: 0.2), value: allocation)
                
                // Plus Button with hold functionality
                Button(action: {
                    if allocation < 100 {
                        onAllocationChange(allocation + 1)
                    }
                }) {
                    Image(systemName: "plus")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 32, height: 32)
                        .background(
                            Circle()
                                .fill(isHoldingPlus ? Color.green.opacity(0.6) : Color.gray.opacity(0.3))
                        )
                        .scaleEffect(isHoldingPlus ? 1.1 : 1.0)
                        .animation(.easeInOut(duration: 0.1), value: isHoldingPlus)
                }
                .onLongPressGesture(minimumDuration: 0.3, maximumDistance: 50) {
                    // Long press started
                    startHoldingPlus()
                } onPressingChanged: { pressing in
                    if !pressing {
                        // Long press ended
                        stopHolding()
                    }
                }
                .disabled(allocation >= 100)
                .opacity(allocation >= 100 ? 0.5 : 1.0)
                
                // Spacer to push trash button to the right
                Spacer()
                    .frame(width: 8)
                
                Button(action: onRemove) {
                    Image(systemName: "trash")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.red)
                        .frame(width: 32, height: 32)
                        .background(Color.red.opacity(0.2))
                        .clipShape(Circle())
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(hex: "1A1C2E"))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
        .onDisappear {
            stopHolding()
        }
    }
    
    // MARK: - Hold Functionality
    
    private func startHoldingMinus() {
        isHoldingMinus = true
        isHoldingPlus = false
        
        // Haptic feedback when starting to hold
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
        
        startHoldTimer {
            if self.allocation > 0 {
                self.onAllocationChange(self.allocation - 1)
            } else {
                self.stopHolding()
            }
        }
    }
    
    private func startHoldingPlus() {
        isHoldingPlus = true
        isHoldingMinus = false
        
        // Haptic feedback when starting to hold
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
        
        startHoldTimer {
            if self.allocation < 100 {
                self.onAllocationChange(self.allocation + 1)
            } else {
                self.stopHolding()
            }
        }
    }
    
    private func startHoldTimer(action: @escaping () -> Void) {
        // Initial delay before starting rapid increments
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            guard self.isHoldingMinus || self.isHoldingPlus else { return }
            
            // Start rapid increments
            self.holdTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
                guard self.isHoldingMinus || self.isHoldingPlus else {
                    self.stopHolding()
                    return
                }
                action()
            }
        }
    }
    
    private func stopHolding() {
        isHoldingMinus = false
        isHoldingPlus = false
        holdTimer?.invalidate()
        holdTimer = nil
    }
    
    private func tokenIcon(for symbol: String) -> some View {
        Group {
            switch symbol {
            case "BTC":
                ZStack {
                    Circle()
                        .fill(Color.orange)
                        .frame(width: 24, height: 24)
                    Text("₿")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                }
            case "ETH":
                ZStack {
                    Circle()
                        .fill(Color.blue)
                        .frame(width: 24, height: 24)
                    Text("Ξ")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                }
            case "XRP":
                ZStack {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.black)
                        .frame(width: 24, height: 24)
                    Text("X")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                }
            case "USDT":
                ZStack {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.green)
                        .frame(width: 24, height: 24)
                    Text("T")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                }
            case "SOL":
                ZStack {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.purple)
                        .frame(width: 24, height: 24)
                    Text("S")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                }
            case "USDC":
                ZStack {
                    Circle()
                        .fill(Color.blue)
                        .frame(width: 24, height: 24)
                    Text("$")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                }
            case "TRX":
                ZStack {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.red)
                        .frame(width: 24, height: 24)
                    Text("T")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white)
                }
            case "ADA":
                ZStack {
                    Circle()
                        .fill(Color.blue)
                        .frame(width: 24, height: 24)
                    Text("A")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                }
            default:
                ZStack {
                    Circle()
                        .fill(Color.gray)
                        .frame(width: 24, height: 24)
                    Text("?")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                }
            }
        }
    }
    
    private func coinColor(for symbol: String) -> Color {
        switch symbol {
        case "BTC": return .orange
        case "ETH": return .blue
        case "XRP": return .black
        case "USDT": return .green
        case "SOL": return .purple
        case "USDC": return .blue
        case "TRX": return .red
        case "ADA": return .blue
        default: return .gray
        }
    }
}

// MARK: - Metric Card
struct MetricCard: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.custom("Satoshi-Bold", size: 14))
                .foregroundColor(.gray)
            
            Text(value)
                .font(.custom("Satoshi-Bold", size: 20))
                .foregroundColor(.white)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
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

// MARK: - Data Models
struct CoinIndex: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let symbol: String
    let price: String
    let change: Double
}

enum IndexCategory: String, CaseIterable {
    case all = "All"
    case defi = "DeFi"
    case meme = "Meme Coins"
    case gaming = "Gaming"
}

// MARK: - Mock Data
let mockCoins: [CoinIndex] = [
    CoinIndex(name: "Bitcoin", symbol: "BTC", price: "$117 176,16", change: -1.12),
    CoinIndex(name: "XRP", symbol: "XRP", price: "$1.00", change: 0.01),
    CoinIndex(name: "Ethereum", symbol: "ETH", price: "$14 153,00", change: -1.12),
    CoinIndex(name: "Tether", symbol: "USDT", price: "$12.23", change: 1.12),
    CoinIndex(name: "Solana", symbol: "SOL", price: "$12.23", change: 1.12),
    CoinIndex(name: "USDC", symbol: "USDC", price: "$14 153,00", change: -1.12),
    CoinIndex(name: "TRON", symbol: "TRX", price: "$1.00", change: 0.01),
    CoinIndex(name: "Cardano", symbol: "ADA", price: "$117 176,16", change: -1.12)
]