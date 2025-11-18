//
//  BuyScreenView.swift
//  Dojo
//
//  Created by Raymond Hou on 3/11/25.
//

import Foundation
import SwiftUI
import WebKit

// MARK: - Buy Screen View
struct BuyScreenView: View {
    let coin: Coin?
    let asset: PortfolioAssetData?
    @Environment(\.dismiss) private var dismiss
    @State private var selectedAmount: Double = 0.0
    @State private var selectedPaymentMethod: PaymentMethod = PaymentMethod(id: "card1", name: "Visa Debit", type: .card, details: "**** 7629", iconName: "creditcard.fill")
    @State private var showTransakWebView = false
    @State private var isProcessing = false
    @State private var showSuccess = false
    
    // Payment methods
    private let paymentMethods = [
        PaymentMethod(id: "bank1", name: "Chase Bank", type: .bank, details: "**** 4582", iconName: "building.columns.fill"),
        PaymentMethod(id: "card1", name: "Visa Debit", type: .card, details: "**** 7629", iconName: "creditcard.fill"),
        PaymentMethod(id: "card2", name: "Mastercard", type: .card, details: "**** 1284", iconName: "creditcard.fill"),
        PaymentMethod(id: "apple", name: "Apple Pay", type: .card, details: "Touch ID", iconName: "applelogo")
    ]
    
    // Quick amount options
    private let quickAmounts: [Double] = [25, 50, 100, 250, 500, 1000]
    
    var body: some View {
        ZStack {
            // Background
            Color(hex: "050715")
                .ignoresSafeArea(.all)
            
            if showSuccess {
                successView
            } else if showTransakWebView {
                transakWebView
            } else {
                mainBuyView
            }
        }
        .navigationBarHidden(true)
    }
    
    // MARK: - Main Buy View
    private var mainBuyView: some View {
        VStack(spacing: 0) {
            // Header
            headerView
            
            // Content
            ScrollView {
                VStack(spacing: 24) {
                    // Research Question Section
                    researchQuestionSection
                    
                    // Formal Proposal Section
                    formalProposalSection
                    
                    // Amount Selection
                    amountSelectionSection
                    
                    // Payment Method Selection
                    paymentMethodSection
                    
                    // Buy Button
                    buyButtonSection
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
            }
        }
    }
    
    // MARK: - Header View
    private var headerView: some View {
        HStack {
            Button(action: {
                dismiss()
            }) {
                Image(systemName: "xmark")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.white)
                    .frame(width: 32, height: 32)
                    .background(Color(hex: "141628"))
                    .clipShape(Circle())
            }
            
            Spacer()
            
            Text("Buy \(coin?.symbol.uppercased() ?? asset?.symbol.uppercased() ?? "Crypto")")
                .font(.custom("Satoshi-Bold", size: 18))
                .foregroundColor(.white)
            
            Spacer()
            
            // Placeholder for balance
            Text("$0.00")
                .font(.custom("Satoshi-Medium", size: 14))
                .foregroundColor(.gray)
                .frame(width: 60)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(Color(hex: "050715"))
    }
    
    // MARK: - Research Question Section
    private var researchQuestionSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Research Question")
                .font(.custom("Satoshi-Bold", size: 20))
                .foregroundColor(.white)
            
            Text("How can we build a system to interact with large bodies of unstructured data with natural language?")
                .font(.custom("Satoshi-Regular", size: 16))
                .foregroundColor(.white)
                .lineSpacing(4)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(hex: "141628"))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
    }
    
    // MARK: - Formal Proposal Section
    private var formalProposalSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Formal Proposal")
                .font(.custom("Satoshi-Bold", size: 20))
                .foregroundColor(.white)
            
            VStack(alignment: .leading, spacing: 12) {
                Text("In the era of the internet it has become common to work with large amounts of unstructured and unorganized data. As more and more data is produced, it has rapidly become unfeasible to parse this data without technological shortcuts like keyword matching. However, most of these techniques are unwieldy and fail to capture any sort of context or deeper meaning. To this end, we want to work to create a new type of system to rapidly digest unstructured data and allow users to communicate with it via natural language.")
                    .font(.custom("Satoshi-Regular", size: 14))
                    .foregroundColor(.white)
                    .lineSpacing(3)
                
                Text("This project aims to create a system that allows users to upload a large body of unstructured text and then query it with natural language. We want to incorporate the broad domain knowledge of a fine tuned LLM with more modular attachments like a vector data base and knowledge graph connected to the LLM via a MCP server. Furthermore, as this is a learning project, we aim to explore various other methods of processing and representing text data, and well as how to efficiently build and implement the ones mentioned above.")
                    .font(.custom("Satoshi-Regular", size: 14))
                    .foregroundColor(.white)
                    .lineSpacing(3)
                
                Text("We plan to start with discussing retrieval augmented generation and fine tuning LLMs before moving deeper into techniques for extracting data into knowledge graphs. Throughout the project we will explore model context protocol (MCP) and work towards actively integrating the tools we create with a LLM to test and improve them.")
                    .font(.custom("Satoshi-Regular", size: 14))
                    .foregroundColor(.white)
                    .lineSpacing(3)
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(hex: "141628"))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
    }
    
    // MARK: - Amount Selection Section
    private var amountSelectionSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Amount")
                .font(.custom("Satoshi-Bold", size: 18))
                .foregroundColor(.white)
            
            // Amount Input
            HStack {
                Text("$")
                    .font(.custom("Satoshi-Bold", size: 24))
                    .foregroundColor(.white)
                
                TextField("0.00", value: $selectedAmount, format: .currency(code: "USD"))
                    .font(.custom("Satoshi-Bold", size: 24))
                    .keyboardType(.decimalPad)
                    .foregroundColor(.white)
                    .textFieldStyle(PlainTextFieldStyle())
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(hex: "1A1C2E"))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                    )
            )
            
            // Quick Amount Buttons
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 12) {
                ForEach(quickAmounts, id: \.self) { amount in
                    Button(action: {
                        selectedAmount = amount
                    }) {
                        Text("$\(Int(amount))")
                            .font(.custom("Satoshi-Medium", size: 14))
                            .foregroundColor(selectedAmount == amount ? .white : .gray)
                            .frame(maxWidth: .infinity)
                            .frame(height: 40)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(selectedAmount == amount ? Color(hex: "4F2FB6") : Color(hex: "1A1C2E"))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(selectedAmount == amount ? Color(hex: "4F2FB6") : Color.white.opacity(0.2), lineWidth: 1)
                                    )
                            )
                    }
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(hex: "141628"))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
    }
    
    // MARK: - Payment Method Section
    private var paymentMethodSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Payment Method")
                .font(.custom("Satoshi-Bold", size: 18))
                .foregroundColor(.white)
            
            VStack(spacing: 12) {
                ForEach(paymentMethods) { method in
                    Button(action: {
                        selectedPaymentMethod = method
                    }) {
                        HStack(spacing: 12) {
                            Image(systemName: method.iconName)
                                .font(.system(size: 20))
                                .foregroundColor(method.type.color)
                                .frame(width: 24)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(method.name)
                                    .font(.custom("Satoshi-Medium", size: 16))
                                    .foregroundColor(.white)
                                
                                Text(method.detailsFormatted)
                                    .font(.custom("Satoshi-Regular", size: 14))
                                    .foregroundColor(.gray)
                            }
                            
                            Spacer()
                            
                            if selectedPaymentMethod.id == method.id {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 20))
                                    .foregroundColor(.green)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(selectedPaymentMethod.id == method.id ? Color(hex: "4F2FB6").opacity(0.2) : Color(hex: "1A1C2E"))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(selectedPaymentMethod.id == method.id ? Color(hex: "4F2FB6") : Color.white.opacity(0.2), lineWidth: 1)
                                )
                        )
                    }
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(hex: "141628"))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
    }
    
    // MARK: - Buy Button Section
    private var buyButtonSection: some View {
        VStack(spacing: 16) {
            // Summary
            HStack {
                Text("You're buying")
                    .font(.custom("Satoshi-Medium", size: 16))
                    .foregroundColor(.gray)
                
                Spacer()
                
                Text("$\(selectedAmount, specifier: "%.2f")")
                    .font(.custom("Satoshi-Bold", size: 16))
                    .foregroundColor(.white)
            }
            
            // Buy Button
            Button(action: {
                if selectedAmount > 0 {
                    isProcessing = true
                    // Simulate processing delay
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        isProcessing = false
                        showTransakWebView = true
                    }
                }
            }) {
                HStack {
                    if isProcessing {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(0.8)
                    } else {
                        Text("Continue to Payment")
                            .font(.custom("Satoshi-Bold", size: 18))
                            .foregroundColor(.white)
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(
                    RoundedRectangle(cornerRadius: 28)
                        .fill(
                            selectedAmount > 0 ? 
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color(hex: "4F2FB6"),
                                    Color(hex: "9746F6"),
                                    Color(hex: "F7B0FE")
                                ]),
                                startPoint: .leading,
                                endPoint: .trailing
                            ) :
                            LinearGradient(
                                gradient: Gradient(colors: [Color.gray]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                )
            }
            .disabled(selectedAmount <= 0 || isProcessing)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(hex: "141628"))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
    }
    
    // MARK: - Transak Web View
    private var transakWebView: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Button(action: {
                    showTransakWebView = false
                }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.white)
                        .frame(width: 32, height: 32)
                        .background(Color(hex: "141628"))
                        .clipShape(Circle())
                }
                
                Spacer()
                
                Text("Complete Purchase")
                    .font(.custom("Satoshi-Bold", size: 18))
                    .foregroundColor(.white)
                
                Spacer()
                
                Button(action: {
                    showTransakWebView = false
                    showSuccess = true
                }) {
                    Image(systemName: "checkmark")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.white)
                        .frame(width: 32, height: 32)
                        .background(Color(hex: "4F2FB6"))
                        .clipShape(Circle())
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(Color(hex: "050715"))
            
            // Transak WebView
            TransakWebView(
                amount: selectedAmount,
                coinSymbol: coin?.symbol ?? asset?.symbol ?? "BTC"
            )
        }
    }
    
    // MARK: - Success View
    private var successView: some View {
        VStack(spacing: 32) {
            Spacer()
            
            // Success Icon
            ZStack {
                Circle()
                    .fill(Color.green.opacity(0.2))
                    .frame(width: 100, height: 100)
                
                Image(systemName: "checkmark")
                    .font(.system(size: 40, weight: .bold))
                    .foregroundColor(.green)
            }
            
            VStack(spacing: 16) {
                Text("Purchase Successful!")
                    .font(.custom("Satoshi-Bold", size: 24))
                    .foregroundColor(.white)
                
                Text("You've successfully purchased $\(selectedAmount, specifier: "%.2f") worth of \(coin?.symbol.uppercased() ?? asset?.symbol.uppercased() ?? "crypto")")
                    .font(.custom("Satoshi-Regular", size: 16))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
            }
            
            Spacer()
            
            // Done Button
            Button(action: {
                dismiss()
            }) {
                Text("Done")
                    .font(.custom("Satoshi-Bold", size: 18))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(
                        RoundedRectangle(cornerRadius: 28)
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color(hex: "4F2FB6"),
                                        Color(hex: "9746F6"),
                                        Color(hex: "F7B0FE")
                                    ]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                    )
            }
            .padding(.horizontal, 20)
        }
        .padding(.vertical, 40)
    }
}

// MARK: - Transak Web View
struct TransakWebView: View {
    let amount: Double
    let coinSymbol: String
    
    var body: some View {
        WebView(
            url: URL(string: "https://global-stg.transak.com?apiKey=27a00627-5f45-4ff6-a65e-b5cf06928992&environment=STAGING&productsAvailed=BUY&themeColor=#1E1E1E&hideMenu=true&defaultFiatCurrency=USD&cryptoCurrencyCode=\(coinSymbol.uppercased())&fiatAmount=\(Int(amount))")!
        )
        .edgesIgnoringSafeArea(.all)
    }
}

// MARK: - WebView Component
// MARK: - WebView for Transak Integration (using existing WebView from BuyCryptoView)

// MARK: - Payment Method Models (using existing definitions from PortfolioView)

// MARK: - Preview
struct BuyScreenView_Previews: PreviewProvider {
    static var previews: some View {
        BuyScreenView(coin: nil, asset: nil)
            .preferredColorScheme(.dark)
    }
}
