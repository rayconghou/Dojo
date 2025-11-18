//
//  DegenTradeView.swift
//  Dojo
//
//  Created by Raymond Hou on 3/31/25.
//

import SwiftUI
import Combine

struct DegenTradeView: View {
    // Environment
    @Environment(\.colorScheme) var colorScheme
    
    // View model
    @StateObject private var viewModel = DegenTradeViewModel()
    
    // UI States
    @State private var selectedChain: Chain = .sol
    @State private var showBridgeModal = false
    @State private var searchText = ""
    @State private var isRefreshing = false
    
    // UI Colors
    var backgroundColor: Color {
        colorScheme == .dark ? Color.black : Color(hex: "0A0E17")
    }
    
    var accentColor: Color {
        switch selectedChain {
        case .sol: return Color(hex: "14F195")
        case .eth: return Color(hex: "627EEA")
        case .base: return Color(hex: "0052FF")
        case .bsc: return Color(hex: "F3BA2F")
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // STATIC HEADER ELEMENTS (don't scroll)
                // Degen Header Bar
                DegenHeaderBar()
                
                // SCROLLABLE CONTENT BELOW HEADERS
                ScrollView {
                    VStack(spacing: 0) {
                        // ZStack to layer everything together - cat, trade header, and token list
                        ZStack(alignment: .top) {
                            // Cat image - background layer
                            Image("DegenTradeBackground")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(maxWidth: .infinity)
                                .offset(y: -20) // Less negative offset to add more space above cat
                            
                            // Trade Header - layered on top of cat
                            VStack(spacing: 12) {
                                // TRADE Title
                                Text("TRADE")
                                    .font(.custom("Korosu", size: 24))
                                    .foregroundColor(.white)
                                    .shadow(color: .black, radius: 2, x: 1, y: 1)
                                
                                // Search Bar
                                HStack {
                                    Image(systemName: "magnifyingglass")
                                        .foregroundColor(.gray)
                                        .font(.system(size: 16))

                                    TextField("Search tokens...", text: $searchText)
                                        .foregroundColor(.white)
                                        .font(.custom("Satoshi-Bold", size: 14))
                                        .onChange(of: searchText) { _ in
                                            viewModel.filterTokens(searchText)
                                        }

                                    if !searchText.isEmpty {
                                        Button {
                                            searchText = ""
                                        } label: {
                                            Image(systemName: "xmark.circle.fill")
                                                .foregroundColor(.gray)
                                                .font(.system(size: 24))
                                        }
                                    }
                                }
                                .padding(.vertical, 12)
                                .padding(.horizontal, 16)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
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
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(Color(hex: "22172F"), lineWidth: 1.5)
                                    )
                                )
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 16)
                            .background(
                                ZStack {
                                    // DegenHeader asset - using GeometryReader for precise positioning
                                    GeometryReader { geometry in
                                        Image("DegenHeader")
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .frame(width: geometry.size.width * 1.5, height: geometry.size.height * 1.5) // Make larger than container
                                            .scaleEffect(x: 1, y: 1) // Keep original orientation
                                            .offset(x: -geometry.size.width * 0.25, y: -geometry.size.height * 0.25) // Position to show top-right glow
                                            .clipped()
                                    }
                                }
                            )
                            .cornerRadius(12)
                            .padding(.horizontal, 20)
                            .padding(.top, 8)
                            
                            // Chain Selector - Separate component
                            VStack(spacing: 0) {
                                Spacer()
                                    .frame(height: 400) // Increased spacing to add more space below cat
                                
                                // Chain Selector Container
                chainSelectorView
                                    .padding(.horizontal, 20)
                                    .padding(.top, 8)
                
                                // Token List Container - Separate component
                                VStack(spacing: 0) {
                                    LazyVStack(spacing: 16) {
                if viewModel.isLoading {
                    loadingView
                                        } else if viewModel.filteredTokens.isEmpty {
                    emptyStateView
                } else {
                                            ForEach(viewModel.filteredTokens) { token in
                                                TradeTokenRow(token: token, accentColor: accentColor)
                                                    .onTapGesture {
                                                        viewModel.selectedToken = token
                                                    }
                                            }
                                        }
                                    }
                                    .padding(.horizontal, 16)
                                    .padding(.top, 16)
                                    .padding(.bottom, 16)
                                }
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(Color(hex: "0C0519"))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 16)
                                                .stroke(Color(hex: "22172F"), lineWidth: 1.5)
                                        )
                                )
                                .padding(.horizontal, 20)
                                .padding(.top, 8)
                            }
                        } // Close the ZStack
                        
                        // Add spacing for floating buttons
                        Spacer()
                            .frame(height: 80)
                    }
                }
            }
            .navigationTitle("Trade")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack(spacing: 16) {
                        Button(action: {}) {
                            Image(systemName: "bell")
                                .foregroundColor(.white)
                                .font(.system(size: 16))
                        }
                        Button(action: {}) {
                            Image(systemName: "info.circle")
                                .foregroundColor(.white)
                                .font(.system(size: 16))
                        }
                    }
                }
            }
            .onAppear {
                viewModel.fetchTokens(for: selectedChain)
                showBridgeModal = false
            }
            .background(Color(hex: "0C0519"))
            .overlay(
                // Floating TRADE button positioned directly above tab bar
            VStack {
                    Spacer()
                    
                    Button(action: {
                        // TODO: Implement trade action
                        print("TRADE tapped")
                    }) {
                        Text("TRADE")
                            .font(.custom("Korosu", size: 18))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(
                                ZStack {
                                    // Glow effect with blur
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(
                                            LinearGradient(
                                                gradient: Gradient(stops: [
                                                    .init(color: Color(hex: "4F2FB6"), location: 0.0),
                                                    .init(color: Color(hex: "9746F6"), location: 0.5),
                                                    .init(color: Color(hex: "F7B0FE"), location: 1.0)
                                                ]),
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            )
                                        )
                                        .blur(radius: 8)
                                        .opacity(0.8)
                                    
                                    // Main button with gradient
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(
                                            LinearGradient(
                                                gradient: Gradient(stops: [
                                                    .init(color: Color(hex: "4F2FB6"), location: 0.0),
                                                    .init(color: Color(hex: "9746F6"), location: 0.5),
                                                    .init(color: Color(hex: "F7B0FE"), location: 1.0)
                                                ]),
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            )
                                        )
                                        .shadow(color: Color(hex: "4F2FB6").opacity(0.8), radius: 12, x: 0, y: 0)
                                        .shadow(color: Color(hex: "9746F6").opacity(0.6), radius: 8, x: 0, y: 0)
                                        .shadow(color: Color(hex: "F7B0FE").opacity(0.4), radius: 4, x: 0, y: 0)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(Color.white.opacity(0.3), lineWidth: 1.5)
                                        )
                                }
                            )
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 10) // Position directly above tab bar
                }
            )
        }
    }
    
    // MARK: - Subviews
    
    var chainSelectorView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(Chain.allCases, id: \.self) { chain in
                    ChainButton(
                        chain: chain,
                        isSelected: selectedChain == chain,
                        accentColor: accentColor
                    )
                    .onTapGesture {
                        if selectedChain != chain {
                            selectedChain = chain
                            viewModel.fetchTokens(for: chain)
                        }
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 24)
        }
        .background(
            ZStack {
                // Background with specified color and transparency
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(hex: "0D051980"))
                
                // Outline
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color(hex: "22172F"), lineWidth: 1.5)
            }
        )
    }
    
    var loadingView: some View {
        VStack {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: Color(hex: "4F2FB6")))
                .scaleEffect(1.5)
                .padding(.top, 8)
            Text("Loading tokens...")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.gray)
                .padding(.top, 8)
            Spacer()
        }
    }
    
    var emptyStateView: some View {
        VStack {
            Spacer()
            Image(systemName: "magnifyingglass")
                .font(.system(size: 50))
                .foregroundColor(.gray)
            Text("No tokens found")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.gray)
                .padding(.top, 8)
            Text("Try a different search or chain")
                .font(.system(size: 14))
                .foregroundColor(.gray.opacity(0.7))
                .padding(.top, 4)
            Spacer()
        }
    }
    
    var bridgeModalView: some View {
        ZStack {
            Color.black.opacity(0.6)
                .ignoresSafeArea()
                .onTapGesture {
                    showBridgeModal = false
                }
            
            VStack(spacing: 20) {
                // Header
                HStack {
                Text("Bridge Assets")
                    .font(.custom("The Last Shuriken", size: 24))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Button(action: {
                        showBridgeModal = false
                    }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white)
                    }
                }
                
                // From chain selector
                BridgeChainSelector(
                    title: "From",
                    selectedChain: $viewModel.fromChain,
                    accentColor: accentColor
                )
                
                // Swap direction button
                Button(action: {
                    let temp = viewModel.fromChain
                    viewModel.fromChain = viewModel.toChain
                    viewModel.toChain = temp
                }) {
                    Image(systemName: "arrow.up.arrow.down")
                        .font(.system(size: 16, weight: .bold))
                        .padding(10)
                        .background(Color(hex: "171D2B"))
                        .foregroundColor(accentColor)
                        .clipShape(Circle())
                }
                .padding(.vertical, 5)
                
                // To chain selector
                BridgeChainSelector(
                    title: "To",
                    selectedChain: $viewModel.toChain,
                    accentColor: accentColor
                )
                
                // Amount input
                VStack(alignment: .leading, spacing: 8) {
                    Text("Amount")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.gray)
                    
                    HStack {
                        TextField("0.0", text: $viewModel.bridgeAmount)
                            .keyboardType(.decimalPad)
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        Button(action: {
                            // Set max amount
                            viewModel.setMaxBridgeAmount()
                        }) {
                            Text("MAX")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(accentColor)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
                                .background(accentColor.opacity(0.1))
                                .cornerRadius(6)
                        }
                    }
                    .padding()
                    .background(Color(hex: "171D2B"))
                    .cornerRadius(12)
                }
                
                // Bridge quote
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text("Estimated gas:")
                        Spacer()
                        Text("~$\(viewModel.estimatedGas)")
                    }
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
                    
                    HStack {
                        Text("You'll receive:")
                        Spacer()
                        Text("\(viewModel.estimatedReceiveAmount) \(viewModel.toChain.symbol)")
                            .fontWeight(.medium)
                    }
                    .font(.system(size: 14))
                    .foregroundColor(.white)
                }
                .padding()
                .background(Color(hex: "171D2B"))
                .cornerRadius(12)
                
                // Bridge button
                Button(action: {
                    viewModel.executeBridge()
                }) {
                Text("Bridge Now")
                    .font(.custom("The Last Shuriken", size: 18))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [accentColor, accentColor.opacity(0.8)]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(12)
                        .shadow(color: accentColor.opacity(0.3), radius: 10)
                }
                .disabled(!viewModel.canBridge)
                .opacity(viewModel.canBridge ? 1.0 : 0.6)
                
                // Li.Fi attribution
                Text("Powered by Li.Fi")
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
            }
            .padding(24)
            .background(Color(hex: "0F131F"))
            .cornerRadius(24)
            .shadow(color: Color.black.opacity(0.5), radius: 20)
            .padding(20)
        }
    }
}

// MARK: - Supporting Views

struct SearchBar: View {
    @Binding var text: String
    var placeholderText: String
    var backgroundColor: Color
    var textColor: Color
    var accentColor: Color
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(textColor.opacity(0.5))
            
            TextField(placeholderText, text: $text)
                .foregroundColor(textColor)
                .autocapitalization(.none)
                .disableAutocorrection(true)
            
            if !text.isEmpty {
                Button(action: {
                    text = ""
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(textColor.opacity(0.5))
                }
            }
        }
        .padding(10)
        .background(backgroundColor)
        .cornerRadius(10)
    }
}

struct ChainButton: View {
    var chain: Chain
    var isSelected: Bool
    var accentColor: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(chain.iconName)
                .resizable()
                .scaledToFit()
                .frame(width: 30, height: 30)
                .foregroundColor(isSelected ? .white : .gray)
                .padding(15)
                .background(
                    isSelected ?
                    AnyView(LinearGradient(
                        gradient: Gradient(colors: [Color(hex: "4F2FB6"), Color(hex: "F7B0FE")]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )) :
                    AnyView(Color(hex: "1A1C2E"))
                )
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(
                            isSelected ? Color(hex: "EBB6FD") : Color(hex: "695F78"),
                            lineWidth: 1.5
                        )
                )
            
            Text(chain.displayName)
                .font(.custom("Satoshi-Bold", size: 14))
                .foregroundColor(isSelected ? .clear : .gray)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
                .fixedSize(horizontal: false, vertical: true)
                .background(
                    isSelected ?
                    LinearGradient(
                        gradient: Gradient(stops: [
                            .init(color: Color(hex: "FBCFFF"), location: 0.0),
                            .init(color: Color(hex: "B16EFF"), location: 0.5),
                            .init(color: Color(hex: "F7B0FE"), location: 1.0)
                        ]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .mask(Text(chain.displayName)
                        .font(.custom("Satoshi-Bold", size: 14))
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                        .fixedSize(horizontal: false, vertical: true))
                    : nil
                )
        }
        .frame(width: 70)
    }
}

struct TradeTokenRow: View {
    var token: Token
    var accentColor: Color
    
    var body: some View {
        HStack(spacing: 12) {
            // Token Icon - Very left
            TradeTokenIconView(token: token)

            // Token Info - Left aligned
            VStack(alignment: .leading, spacing: 2) {
                    Text(token.symbol)
                    .font(.custom("Satoshi-Bold", size: 16))
                        .foregroundColor(.white)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                        .fixedSize(horizontal: false, vertical: true)

                Text(token.name)
                    .font(.custom("Satoshi-Medium", size: 14))
                    .foregroundColor(.gray)
                    .lineLimit(1)
                    .truncationMode(.tail)
                    .minimumScaleFactor(0.7)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Spacer()
            
            // Dollar icon with glow - Centered in middle
            ZStack {
                // Glow effect
                Circle()
                    .fill(Color(hex: "FFBE02"))
                    .frame(width: 20, height: 20)
                    .blur(radius: 3)
                    .opacity(0.6)
                
                // Main icon - yellow circle with white dollar sign
                ZStack {
                    Circle()
                        .fill(Color(hex: "FFBE02"))
                        .frame(width: 25, height: 25)
                    
                    Text("$")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                }
            }

            // Price and Change - Right of dollar icon
            VStack(alignment: .leading, spacing: 4) {
                Text(token.priceFormatted)
                    .font(.custom("The Last Shuriken", size: 15))
                    .foregroundColor(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                    .fixedSize(horizontal: false, vertical: true)

                HStack(spacing: 4) {
                    Image(systemName: token.priceChangePercentage >= 0 ? "arrowtriangle.up.fill" : "arrowtriangle.down.fill")
                        .font(.system(size: 8))
                        .foregroundColor(token.priceChangePercentage >= 0 ? .green : .red)

                    Text("\(abs(token.priceChangePercentage), specifier: "%.2f")%")
                        .font(.custom("Satoshi-Medium", size: 12))
                        .foregroundColor(token.priceChangePercentage >= 0 ? .green : .red)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            
            // Action button - DegenSwap asset
            Button(action: {
                // Action to trade token
            }) {
                Image("DegenSwap")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 40, height: 40)
            }
        }
        .padding(.vertical, 12)
                    .padding(.horizontal, 16)
        .background(
            RoundedRectangle(cornerRadius: 12)
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
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color(hex: "22172F"), lineWidth: 1.5)
                )
        )
        .onTapGesture {
            // Handle token selection
            print("Selected \(token.symbol)")
        }
    }
}

struct TradeTokenIconView: View {
    let token: Token
    
    var body: some View {
        ZStack {
            // Background circle with gradient outline and shading
            Circle()
                .fill(Color(hex: "2C1F41"))
                .frame(width: 40, height: 40)
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
                        .stroke(
                            LinearGradient(
                                gradient: Gradient(stops: [
                                    .init(color: Color(hex: "4F2FB6"), location: 0.0),
                                    .init(color: Color(hex: "9746F6"), location: 0.5),
                                    .init(color: Color(hex: "F7B0FE"), location: 1.0)
                                ]),
                                startPoint: .leading,
                                endPoint: .trailing
                            ),
                            lineWidth: 1.5
                        )
                )
            
            // Token icon or fallback
            AsyncImage(url: URL(string: token.iconURL)) { image in
                image
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 24)
            } placeholder: {
                // Fallback icon with token symbol
                Text(token.symbol.prefix(1).uppercased())
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
            }
        }
    }
}

struct BridgeChainSelector: View {
    var title: String
    @Binding var selectedChain: Chain
    var accentColor: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.gray)
            
            Menu {
                ForEach(Chain.allCases, id: \.self) { chain in
                    Button(action: {
                        selectedChain = chain
                    }) {
                        HStack {
                            Image(chain.iconName)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 20, height: 20)
                            
                            Text(chain.displayName)
                            
                            Spacer()
                            
                            if selectedChain == chain {
                                Image(systemName: "checkmark")
                                    .foregroundColor(accentColor)
                            }
                        }
                    }
                }
            } label: {
                HStack {
                    Image(selectedChain.iconName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                    
                    Text(selectedChain.displayName)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.down")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                }
                .padding()
                .background(Color(hex: "171D2B"))
                .cornerRadius(12)
            }
        }
    }
}


// MARK: - Preview

struct DegenTradeView_Previews: PreviewProvider {
    static var previews: some View {
        DegenTradeView()
            .preferredColorScheme(.dark)
    }
}
