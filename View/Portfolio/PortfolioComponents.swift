//
//  PortfolioComponents.swift
//  Dojo
//
//  Created by Raymond Hou on 3/11/25.
//

import Foundation
import SwiftUI

// MARK: - Action Button Component

struct ActionButton: View {
    let icon: String
    let title: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(icon)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 24, height: 24)
                .foregroundColor(.blue)
            
            Text(title)
                .font(.custom("Satoshi-Medium", size: 12))
                .foregroundColor(.white)
        }
        .frame(width: 80, height: 80)
        .background(color)
        .cornerRadius(12)
    }
}

// MARK: - Asset Row Components

struct CustomAssetRow: View {
    let name: String
    let symbol: String
    let balance: String
    let value: String
    let change: String
    let isPositive: Bool
    let logo: String
    let logoColor: Color
    let imageUrl: String
    
    var body: some View {
        HStack(spacing: 12) {
            // Token Icon
            AsyncImage(url: URL(string: imageUrl)) { image in
                image
                    .resizable()
                    .scaledToFit()
                    .frame(width: 32, height: 32)
            } placeholder: {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 32, height: 32)
            }
                    .frame(width: 40, height: 40)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(portfolioBackgroundColorForSymbol(symbol))
            )
            .cornerRadius(8)
            
            // Asset Info
            VStack(alignment: .leading, spacing: 4) {
                Text(name)
                    .font(.custom("Satoshi-Medium", size: 16))
                    .foregroundColor(.white)
                
                Text(symbol)
                    .font(.custom("Satoshi-Regular", size: 14))
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            // Value and Change
            VStack(alignment: .trailing, spacing: 4) {
                Text(value)
                    .font(.custom("Satoshi-Medium", size: 16))
                    .foregroundColor(.white)
                
                HStack(spacing: 4) {
                    Image(systemName: "triangle.fill")
                        .font(.system(size: 8))
                        .foregroundColor(isPositive ? .green : .red)
                        .rotationEffect(.degrees(isPositive ? 0 : 180))
                    
                    Text(change)
                        .font(.custom("Satoshi-Medium", size: 14))
                        .foregroundColor(isPositive ? .green : .red)
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
    }
}

struct FavoriteAssetRow: View {
    let name: String
    let symbol: String
    let value: String
    let change: String
    let isPositive: Bool
    let logo: String
    let logoColor: Color
    let imageUrl: String
    
    var body: some View {
        HStack(spacing: 12) {
            // Token Icon
            AsyncImage(url: URL(string: imageUrl)) { image in
                image
                    .resizable()
                    .scaledToFit()
                    .frame(width: 32, height: 32)
            } placeholder: {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 32, height: 32)
            }
            .frame(width: 40, height: 40)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(portfolioBackgroundColorForSymbol(symbol))
            )
            .cornerRadius(8)
            
            // Asset Info
            VStack(alignment: .leading, spacing: 4) {
                Text(name)
                    .font(.custom("Satoshi-Medium", size: 16))
                    .foregroundColor(.white)
                
                Text(symbol)
                    .font(.custom("Satoshi-Regular", size: 14))
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            // Value and Change
            VStack(alignment: .trailing, spacing: 4) {
                Text(value)
                    .font(.custom("Satoshi-Medium", size: 16))
                    .foregroundColor(.white)
                
                HStack(spacing: 4) {
                    Image(systemName: "triangle.fill")
                        .font(.system(size: 8))
                        .foregroundColor(isPositive ? .green : .red)
                        .rotationEffect(.degrees(isPositive ? 0 : 180))
                    
                    Text(change)
                        .font(.custom("Satoshi-Medium", size: 14))
                        .foregroundColor(isPositive ? .green : .red)
                }
            }
            
            // Star Icon
            Image(systemName: "star.fill")
                .font(.system(size: 12))
                .foregroundColor(.yellow)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
    }
}

// MARK: - News Card Component

struct PortfolioNewsCard: View {
    let newsItem: NewsItem
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // News Image - Left third
            if let imageUrl = newsItem.imageUrl, !imageUrl.isEmpty {
                Image(imageUrl)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 100, height: 132)
                    .cornerRadius(12)
                    .clipped()
            } else {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 100, height: 132)
            }
            
            // News Content - Right two thirds
            VStack(alignment: .leading, spacing: 8) {
                // Title with 3 lines
                Text(newsItem.title)
                    .font(.custom("Satoshi-Bold", size: 16))
                    .foregroundColor(.white)
                    .lineLimit(3)
                    .multilineTextAlignment(.leading)
                
                // Description with ellipsis
                Text(newsItem.description)
                    .font(.custom("Satoshi-Medium", size: 12))
                    .foregroundColor(.gray)
                    .lineLimit(1)
                    .truncationMode(.tail)
                
                Spacer()
                
                // Time and Views in separate shadowed boxes
                HStack(spacing: 8) {
                    // Time box
                    HStack(spacing: 4) {
                        Image(systemName: "clock")
                            .font(.system(size: 10))
                            .foregroundColor(.gray)
                        Text(formatNewsDate(newsItem.publishedAt))
                            .font(.custom("Satoshi-Medium", size: 10))
                            .foregroundColor(.gray)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color.black.opacity(0.3))
                            .shadow(color: .black.opacity(0.2), radius: 2, x: 0, y: 1)
                    )
                    
                    // Views box
                    HStack(spacing: 4) {
                        Image(systemName: "eye")
                            .font(.system(size: 10))
                            .foregroundColor(.gray)
                        Text("1.2K")
                            .font(.custom("Satoshi-Medium", size: 10))
                            .foregroundColor(.gray)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color.black.opacity(0.3))
                            .shadow(color: .black.opacity(0.2), radius: 2, x: 0, y: 1)
                    )
                    
                    Spacer()
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(20)
        .background(Color(hex: "141628"))
        .cornerRadius(20)
    }
}

// MARK: - Wallet Components

struct WalletSelectorView: View {
    @ObservedObject var viewModel = PortfolioViewModel()
    @State private var showWalletSheet = false
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Select Wallet")
                    .font(.custom("Satoshi-Bold", size: 18))
                    .foregroundColor(.white)
                
                Spacer()
                
                Button("Manage") {
                    showWalletSheet = true
                }
                .font(.custom("Satoshi-Medium", size: 14))
                .foregroundColor(.blue)
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(viewModel.wallets) { wallet in
                        WalletCard(
                            wallet: wallet,
                            isSelected: wallet.id.uuidString == viewModel.selectedWalletId
                        )
                        .onTapGesture {
                            viewModel.selectedWalletId = wallet.id.uuidString
                        }
                    }
                }
                .padding(.horizontal, 20)
            }
        }
        .sheet(isPresented: $showWalletSheet) {
            WalletListView()
        }
    }
}

struct WalletCard: View {
    let wallet: PersonalWallet
    let isSelected: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Image(systemName: wallet.logo)
                    .font(.system(size: 16))
                    .foregroundColor(wallet.logoColor)
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 16))
                        .foregroundColor(.green)
                }
            }
            
            Text(wallet.type.rawValue)
                .font(.custom("Satoshi-Medium", size: 14))
                .foregroundColor(.white)
            
            Text(wallet.balance)
                .font(.custom("Satoshi-Bold", size: 16))
                .foregroundColor(.white)
            
            Text(wallet.change)
                .font(.custom("Satoshi-Medium", size: 12))
                .foregroundColor(wallet.isPositive ? .green : .red)
        }
        .padding(16)
        .frame(width: 140, height: 100)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(isSelected ? Color.blue.opacity(0.2) : Color(hex: "141628"))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 1)
                )
        )
    }
}

struct WalletListView: View {
    @ObservedObject var viewModel = PortfolioViewModel()
    @Environment(\.presentationMode) var presentationMode
    @State private var showAddWalletSheet = false
    
    var body: some View {
        NavigationView {
            VStack {
                List {
                    ForEach(viewModel.wallets) { wallet in
                        WalletListRow(
                            wallet: wallet,
                            isSelected: wallet.id.uuidString == viewModel.selectedWalletId
                        )
                        .onTapGesture {
                            viewModel.selectedWalletId = wallet.id.uuidString
                        }
                    }
                    .onDelete(perform: viewModel.removeWallet)
                }
                .listStyle(PlainListStyle())
                
                Button("Add New Wallet") {
                    showAddWalletSheet = true
                }
                .font(.custom("Satoshi-Medium", size: 16))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .cornerRadius(12)
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
            .navigationTitle("Wallets")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("Done") {
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }
        .sheet(isPresented: $showAddWalletSheet) {
            AddWalletView()
        }
    }
}

struct WalletListRow: View {
    let wallet: PersonalWallet
    let isSelected: Bool
    
    var body: some View {
        HStack {
            Image(systemName: wallet.logo)
                .font(.system(size: 20))
                .foregroundColor(wallet.logoColor)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(wallet.type.rawValue)
                    .font(.custom("Satoshi-Medium", size: 16))
                    .foregroundColor(.white)
                
                Text(wallet.balance)
                    .font(.custom("Satoshi-Regular", size: 14))
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            if isSelected {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 20))
                    .foregroundColor(.green)
            }
        }
        .padding(.vertical, 8)
    }
}

struct AddWalletView: View {
    @ObservedObject var viewModel = PortfolioViewModel()
    @Environment(\.presentationMode) var presentationMode
    @State private var name = ""
    @State private var walletType: PersonalWalletType = .primary
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Wallet Name")
                        .font(.custom("Satoshi-Medium", size: 16))
                        .foregroundColor(.white)
                    
                    TextField("Enter wallet name", text: $name)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Wallet Type")
                        .font(.custom("Satoshi-Medium", size: 16))
                        .foregroundColor(.white)
                    
                    Picker("Wallet Type", selection: $walletType) {
                        ForEach(PersonalWalletType.allCases, id: \.self) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                
                Spacer()
                
                Button("Add Wallet") {
                    viewModel.addWallet(name: name, type: walletType)
                    presentationMode.wrappedValue.dismiss()
                }
                .font(.custom("Satoshi-Medium", size: 16))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .cornerRadius(12)
            }
            .padding(20)
            .navigationTitle("Add Wallet")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }
    }
}

struct WalletManagementView: View {
    let isDeposit: Bool
    @ObservedObject var viewModel = PortfolioViewModel()
    @Environment(\.presentationMode) var presentationMode
    @State private var amount = ""
    @State private var selectedPaymentMethod: PaymentMethod?
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(isDeposit ? "Deposit Amount" : "Withdraw Amount")
                        .font(.custom("Satoshi-Medium", size: 16))
                        .foregroundColor(.white)
                    
                    TextField("Enter amount", text: $amount)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.decimalPad)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Payment Method")
                        .font(.custom("Satoshi-Medium", size: 16))
                        .foregroundColor(.white)
                    
                    ForEach(viewModel.paymentMethods) { method in
                        PaymentMethodRow(
                            method: method,
                            isSelected: selectedPaymentMethod?.id == method.id
                        )
                        .onTapGesture {
                            selectedPaymentMethod = method
                        }
                    }
                }
                
                Spacer()
                
                Button(isDeposit ? "Deposit" : "Withdraw") {
                    // Handle deposit/withdraw logic
                    presentationMode.wrappedValue.dismiss()
                }
                .font(.custom("Satoshi-Medium", size: 16))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .cornerRadius(12)
            }
            .padding(20)
            .navigationTitle(isDeposit ? "Deposit" : "Withdraw")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }
    }
}

struct PaymentMethodRow: View {
    let method: PaymentMethod
    let isSelected: Bool
    
    var body: some View {
        HStack {
            Image(systemName: method.logo)
                .font(.system(size: 20))
                .foregroundColor(method.logoColor)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(method.name)
                    .font(.custom("Satoshi-Medium", size: 16))
                    .foregroundColor(.white)
                
                Text("**** \(method.lastFour)")
                    .font(.custom("Satoshi-Regular", size: 14))
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            if isSelected {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 20))
                    .foregroundColor(.green)
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(isSelected ? Color.blue.opacity(0.2) : Color(hex: "141628"))
        )
    }
}

// MARK: - Helper Functions

private func portfolioBackgroundColorForSymbol(_ symbol: String) -> Color {
    switch symbol.lowercased() {
    case "eth":
        return Color(red: 0.4, green: 0.5, blue: 0.7) // Grayish blue
    case "sol":
        return .black
    case "btc":
        return .orange
    case "usdt":
        return .green
    case "ada":
        return .blue
    default:
        return .gray
    }
}

private func formatNewsDate(_ dateString: String) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
    
    if let date = formatter.date(from: dateString) {
        formatter.dateFormat = "MMM d, yyyy"
        return formatter.string(from: date)
    }
    
    return dateString
}
