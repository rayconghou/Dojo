import SwiftUI

struct DegenPortfolioView: View {
    @StateObject private var viewModel = DegenPortfolioViewModel()
    @State private var selectedAssetTab: AssetTab = .all
    @State private var showBuyScreen = false
    @EnvironmentObject var authManager: AuthManager
    
    enum AssetTab: String, CaseIterable {
        case all = "ALL"
        case gainers = "GAINERS"
        case losers = "LOSERS"
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // STATIC HEADER ELEMENTS (don't scroll)
            // Degen Header Bar
            DegenHeaderBar()
            
            // SCROLLABLE CONTENT BELOW HEADERS
            ScrollView {
                VStack(spacing: 0) {
                    // ZStack to layer everything together - background image and content
                    ZStack(alignment: .top) {
                        // DegenPortfolioBackground - background layer
                        Image("DegenPortfolioBackground")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxWidth: .infinity)
                            .offset(y: -20) // Less negative offset to add more space above background
                        
                        // Portfolio content - layered on top of background
                        VStack(spacing: 0) {
                            // Portfolio Value Header Section
                            portfolioValueHeaderView
                            
                            // Add spacing to push P&L bars below the cat
                            Spacer()
                                .frame(height: 250) // Space to show the cat fully
                            
                            // P&L Summary Section
                            pnlSummaryView
                            
                            // Add spacing between P&L and My Assets
                            Spacer()
                                .frame(height: 40)
                            
                            // My Assets Section
                            myAssetsView
                        }
                    }
                    
                    // Add spacing for floating buttons
                    Spacer()
                        .frame(height: 80)
                }
            }
        }
        .overlay(
            // Floating Buy/Sell buttons positioned directly above tab bar
            VStack {
                Spacer()
                
                HStack(spacing: 12) {
                    // BUY button (left)
                    Button(action: {
                        showBuyScreen = true
                    }) {
                        Text("BUY")
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
                    
                    // SELL button (right)
                    Button(action: {
                        // TODO: Implement sell action
                        print("SELL tapped")
                    }) {
                        Text("SELL")
                            .font(.custom("Korosu", size: 18))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(
                                        LinearGradient(
                                            gradient: Gradient(stops: [
                                                .init(color: Color(hex: "130825"), location: 0.0),
                                                .init(color: Color(hex: "4F2FB6"), location: 1.0)
                                            ]),
                                            startPoint: .top,
                                            endPoint: .bottom
                                        )
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color(hex: "22172F"), lineWidth: 1.5)
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color.white.opacity(0.2), lineWidth: 1.5)
                                    )
                                    .shadow(color: Color(hex: "4F2FB6").opacity(0.3), radius: 4, x: 0, y: 2)
                            )
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 10) // Position directly above tab bar
            }
        )
        .background(Color(hex: "0C0519"))
        .onAppear {
            viewModel.loadPortfolioData()
        }
        .fullScreenCover(isPresented: $showBuyScreen) {
            BuyScreenView(coin: nil, asset: nil)
        }
    }
    
    var portfolioValueHeaderView: some View {
        VStack(spacing: 16) {
            // PORTFOLIO VALUE Title with purple gradient
            Text("PORTFOLIO VALUE")
                .font(.custom("Korosu", size: 20))
                .foregroundStyle(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(hex: "FBCFFF"),
                            Color(hex: "B16EFF"),
                            Color(hex: "F7B0FE")
                        ]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .shadow(color: .black, radius: 2, x: 1, y: 1)
            
            // Portfolio value information positioned right below title
            VStack(spacing: 12) {
                // Main value with dollar sign
                HStack(spacing: 12) {
                    // Golden coin icon with glow (matching DegenHeaderBar design)
                    ZStack {
                        // Glow effect
                        Circle()
                            .fill(Color(hex: "FFBE02"))
                            .frame(width: 28, height: 28)
                            .blur(radius: 4)
                            .opacity(0.6)
                        
                        // Main coin icon
                        Circle()
                            .fill(Color(hex: "FFBE02"))
                            .frame(width: 32, height: 32)
                        
                        Text("$")
                            .font(.custom("Satoshi-Bold", size: 16))
                            .foregroundColor(.white)
                    }
                    
                    // Portfolio value
                    Text(viewModel.portfolioValue)
                        .font(.custom("The Last Shuriken", size: 32))
                        .foregroundColor(.white)
                        .shadow(color: .black, radius: 2, x: 1, y: 1)
                }
                
                // Performance Metrics - on same line
                HStack(spacing: 8) {
                    // Absolute change
                    Text(viewModel.absoluteChange)
                        .font(.custom("The Last Shuriken", size: 16))
                        .foregroundColor(.white)
                    
                    // Percentage change with arrow
                    HStack(spacing: 4) {
                        Text(viewModel.percentageChange)
                            .font(.custom("Satoshi-Bold", size: 16))
                            .foregroundColor(.green)
                        
                        Image(systemName: "arrowtriangle.up.fill")
                            .font(.system(size: 8))
                            .foregroundColor(.green)
                    }
                }
            }
            
        }
        .padding(.vertical, 24)
        .padding(.horizontal, 20)
        .padding(.top, 8)
    }
    
    var pnlSummaryView: some View {
        // Container for all P&L bars with equal padding
        VStack(spacing: 12) {
            // Unrealized P&L (Positive - Green)
            pnlBarView(
                title: "Unrealized P&L",
                value: viewModel.unrealizedPnL,
                isPositive: true
            )
            
            // Realized P&L (Negative - Red)
            pnlBarView(
                title: "Realized P&L",
                value: viewModel.realizedPnL,
                isPositive: false
            )
            
            // Total P&L (Positive - Green)
            pnlBarView(
                title: "Total P&L",
                value: viewModel.totalPnL,
                isPositive: true
            )
        }
        .padding(16) // Equal padding on all sides
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(hex: "0C0519"))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color(hex: "22172F"), lineWidth: 1.5)
                )
        )
        .padding(.horizontal, 20)
        .padding(.top, 16)
    }
    
    // Helper function to create P&L bar with correct colors
    private func pnlBarView(title: String, value: String, isPositive: Bool) -> some View {
        HStack {
            Text(title)
                .font(.custom("Satoshi-Medium", size: 16))
                .foregroundColor(.white)
            
            Spacer()
            
            HStack(spacing: 4) {
                Text(value)
                        .font(.custom("The Last Shuriken", size: 16))
                    .foregroundColor(isPositive ? Color(hex: "13E15A") : Color(hex: "F34747"))
                
                // Golden coin icon with glow (matching DegenHeaderBar design)
                ZStack {
                    // Glow effect
                    Circle()
                        .fill(Color(hex: "FFBE02"))
                        .frame(width: 20, height: 20)
                        .blur(radius: 3)
                        .opacity(0.6)
                    
                    // Main coin icon
                    Circle()
                        .fill(Color(hex: "FFBE02"))
                        .frame(width: 16, height: 16)
                    
                    Text("$")
                        .font(.custom("Satoshi-Bold", size: 8))
                        .foregroundColor(.white)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(
                    LinearGradient(
                        gradient: Gradient(stops: [
                            .init(color: isPositive ? Color(hex: "13E15A").opacity(0.05) : Color(hex: "F34747").opacity(0.05), location: 0.0),
                            .init(color: isPositive ? Color(hex: "13E15A").opacity(0.15) : Color(hex: "F34747").opacity(0.15), location: 1.0)
                        ]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(isPositive ? Color(hex: "13E15A").opacity(0.15) : Color(hex: "F34747").opacity(0.15), lineWidth: 1.5)
                )
        )
    }
    
    var myAssetsView: some View {
        VStack(spacing: 16) {
            // MY ASSETS Title with purple gradient
            Text("MY ASSETS")
                .font(.custom("Korosu", size: 20))
                .foregroundStyle(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(hex: "FBCFFF"),
                            Color(hex: "B16EFF"),
                            Color(hex: "F7B0FE")
                        ]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .shadow(color: .black, radius: 2, x: 1, y: 1)
            
            // Container for segmented picker and asset list
            VStack(spacing: 16) {
                // Asset Tabs
                HStack(spacing: 0) {
                    ForEach(AssetTab.allCases, id: \.self) { tab in
                        Button(action: {
                            selectedAssetTab = tab
                        }) {
                            Text(tab.rawValue)
                                .font(.custom("Korosu", size: 15))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 35)
                                .background(
                                    selectedAssetTab == tab ?
                                    LinearGradient(
                                        gradient: Gradient(colors: [Color(hex: "4F2FB6"), Color(hex: "F7B0FE")]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    ) :
                                    LinearGradient(
                                        gradient: Gradient(colors: [Color(hex: "1A1C2E"), Color(hex: "1A1C2E")]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .cornerRadius(10, corners: tab == .all ? [.topLeft, .bottomLeft] : 
                                             tab == .losers ? [.topRight, .bottomRight] : [])
                        }
                    }
                }
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [Color(hex: "4F2FB6"), Color(hex: "F7B0FE")]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color(hex: "22172F"), lineWidth: 1.5)
                )
                
                // Asset List
                VStack(spacing: 12) {
                    ForEach(viewModel.assets) { asset in
                        DegenAssetRow(asset: asset)
                    }
                }
            }
            .padding(16) // Equal padding on all sides
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(hex: "0C0519"))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color(hex: "22172F"), lineWidth: 1.5)
                    )
            )
        }
        .padding(.horizontal, 20)
        .padding(.top, 16)
    }
}

// MARK: - Degen Asset Row Component
struct DegenAssetRow: View {
    let asset: DegenPortfolioAsset
    
    var body: some View {
        HStack(spacing: 12) {
            // Token Icon
            AsyncImage(url: URL(string: asset.iconURL ?? "")) { image in
                image
                    .resizable()
                    .scaledToFit()
                    .frame(width: 32, height: 32)
            } placeholder: {
                // Fallback icon with token symbol
                Text(asset.symbol.prefix(1))
                    .font(.custom("Satoshi-Bold", size: 16))
                    .foregroundColor(.white)
                    .frame(width: 32, height: 32)
            }
            .frame(width: 40, height: 40)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(asset.backgroundColor)
            )
            .clipShape(Circle())
            
            // Token Info
            VStack(alignment: .leading, spacing: 2) {
                Text(asset.name)
                    .font(.custom("Satoshi-Bold", size: 16))
                    .foregroundColor(.white)
                
                Text(asset.amount)
                    .font(.custom("Satoshi-Medium", size: 14))
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            // Value and Change
            VStack(alignment: .trailing, spacing: 4) {
                Text(asset.value)
                    .font(.custom("The Last Shuriken", size: 16))
                    .foregroundColor(.white)
                
                Text(asset.changePercentage)
                    .font(.custom("Satoshi-Medium", size: 14))
                    .foregroundColor(asset.isPositive ? .green : .red)
            }
            
            // Golden coin icon with glow (matching DegenHeaderBar design)
            ZStack {
                // Glow effect
                Circle()
                    .fill(Color(hex: "FFBE02"))
                    .frame(width: 20, height: 20)
                    .blur(radius: 3)
                    .opacity(0.6)
                
                // Main coin icon
                Circle()
                    .fill(Color(hex: "FFBE02"))
                    .frame(width: 16, height: 16)
                
                Text("$")
                    .font(.custom("Satoshi-Bold", size: 8))
                    .foregroundColor(.white)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
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
    }
}

// MARK: - Degen Portfolio Asset Model
struct DegenPortfolioAsset: Identifiable {
    let id = UUID()
    let name: String
    let symbol: String
    let amount: String
    let value: String
    let changePercentage: String
    let isPositive: Bool
    let backgroundColor: Color
    let iconURL: String?
}

// MARK: - ViewModel
class DegenPortfolioViewModel: ObservableObject {
    @Published var portfolioValue: String = "$4,237.36"
    @Published var absoluteChange: String = "+ $1,046.95"
    @Published var percentageChange: String = "26.25%"
    @Published var unrealizedPnL: String = "+ $2,870.59"
    @Published var realizedPnL: String = "- $191.37"
    @Published var totalPnL: String = "+ $2,679.21"
    @Published var assets: [DegenPortfolioAsset] = []
    
    func loadPortfolioData() {
        // Mock data matching the image
        assets = [
            DegenPortfolioAsset(
                name: "Bitcoin",
                symbol: "BTC",
                amount: "0.0006 BTC",
                value: "$2.02",
                changePercentage: "▲ 13.45%",
                isPositive: true,
                backgroundColor: Color(red: 1.0, green: 0.58, blue: 0.0), // Bitcoin orange
                iconURL: "https://assets.coingecko.com/coins/images/1/large/bitcoin.png"
            ),
            DegenPortfolioAsset(
                name: "Ethereum",
                symbol: "ETH",
                amount: "1.2 ETH",
                value: "$1,634.60",
                changePercentage: "▼ 1.32%",
                isPositive: false,
                backgroundColor: Color(red: 0.46, green: 0.48, blue: 0.9), // Ethereum blue
                iconURL: "https://assets.coingecko.com/coins/images/279/large/ethereum.png"
            ),
            DegenPortfolioAsset(
                name: "Tether",
                symbol: "USDT",
                amount: "0.0006 USDT",
                value: "$2.02",
                changePercentage: "▲ 13.45%",
                isPositive: true,
                backgroundColor: Color(red: 0.0, green: 0.5, blue: 0.8), // Tether teal
                iconURL: "https://assets.coingecko.com/coins/images/325/large/Tether.png"
            )
        ]
    }
}

// MARK: - Preview
struct DegenPortfolioView_Previews: PreviewProvider {
    static var previews: some View {
        DegenPortfolioView()
            .environmentObject(AuthManager.shared)
    }
}
