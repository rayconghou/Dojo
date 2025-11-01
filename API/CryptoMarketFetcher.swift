//
//  CryptoMarketViewModel.swift
//  Dojo
//
//  Created by Raymond Hou on 3/13/25.
//  Updated to fetch the full coin list with sparkline data from CoinGecko
//

import Foundation
import Combine
import SwiftUI

// MARK: - Coin Models

struct Coin: Codable, Identifiable {
    let id: String
    let symbol: String
    let name: String
    let image: String
    let current_price: Double
    let market_cap: Double?
    let market_cap_rank: Int?
    let price_change_percentage_24h: Double?
    let sparkline_in_7d: SparklineData?
    
    enum CodingKeys: String, CodingKey {
        case id
        case symbol
        case name
        case image
        case current_price = "current_price"
        case market_cap = "market_cap"
        case market_cap_rank = "market_cap_rank"
        case price_change_percentage_24h = "price_change_percentage_24h"
        case sparkline_in_7d = "sparkline_in_7d"
    }
}

struct CoinDetail: Codable, Identifiable {
    let id: String
    let name: String
    let symbol: String
    let description: [String: String]
    let links: CoinLinks?
}

struct CoinLinks: Codable {
    let homepage: [String]?
}

struct PriceHistoryEntry: Identifiable {
    let id = UUID()
    let date: String
    let price: Double
}

struct CoinDetailModalView: View {
    let coin: Coin
    @ObservedObject var marketVM: CryptoMarketViewModel
    @State private var selectedTab = 0
    @Environment(\.dismiss) private var dismiss
    
    // Hard-coded Bitcoin data for demo
    let bitcoinDescription = "Bitcoin is the first decentralized cryptocurrency, released as open-source software in 2009. It operates on a peer-to-peer network without central authority or banks. Transaction verification and network integrity are maintained by cryptography and recorded in a public distributed ledger called a blockchain."
    
    let marketStats = [
        ("Market Cap", "$1.2T"),
        ("24h Volume", "$48.2B"),
        ("Circulating Supply", "19.4M BTC"),
        ("Max Supply", "21M BTC"),
        ("All-Time High", "$69,000")
    ]
    
    // Mock price history data points
    let priceHistory: [PriceHistoryEntry] = [
        .init(date: "Apr 09", price: 71243.0),
        .init(date: "Apr 08", price: 70129.0),
        .init(date: "Apr 07", price: 68926.0),
        .init(date: "Apr 06", price: 67892.0),
        .init(date: "Apr 05", price: 69123.0),
        .init(date: "Apr 04", price: 68421.0),
        .init(date: "Apr 03", price: 66789.0)
    ]
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [Color.black, Color(hex: "121212")]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 0) {
                    // Header with coin info and chart
                    headerSection
                    
                    // Tab selection
                    tabSelectionView
                    
                    // Tab content
                    tabContentView
                }
            }
            
            // Floating action button
            VStack {
                Spacer()
                buyButton
            }
            .padding(.bottom, 16)
        }
        .navigationBarItems(leading: dismissButton)
        .onAppear {
            marketVM.fetchCoinDetail(id: coin.id)
        }
    }
    
    // MARK: - UI Components
    
    private var dismissButton: some View {
        Button(action: {
            dismiss()
        }) {
            Image(systemName: "xmark")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.white)
                .padding(8)
                .background(Color.gray.opacity(0.3))
                .clipShape(Circle())
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: 16) {
            HStack(alignment: .center) {
                // Coin icon
                AsyncImage(url: URL(string: coin.image)) { image in
                    image
                        .resizable()
                        .frame(width: 48, height: 48)
                        .clipShape(Circle())
                } placeholder: {
                    Circle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 48, height: 48)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(coin.name)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text(coin.symbol.uppercased())
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                // Watchlist button
                Button(action: {}) {
                    Image(systemName: "star")
                        .font(.system(size: 20))
                        .foregroundColor(.gray)
                }
            }
            .padding(.horizontal)
            
            // Price section
            VStack(alignment: .leading, spacing: 8) {
                Text("$\(coin.current_price, specifier: "%.2f")")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.white)
                
                HStack(spacing: 4) {
                    Image(systemName: coin.price_change_percentage_24h ?? 0 >= 0 ? "arrow.up.right" : "arrow.down.right")
                        .font(.caption)
                        .foregroundColor(coin.price_change_percentage_24h ?? 0 >= 0 ? .green : .red)
                    
                    Text("\(coin.price_change_percentage_24h ?? 0, specifier: "%.2f")% (24h)")
                        .font(.subheadline)
                        .foregroundColor(coin.price_change_percentage_24h ?? 0 >= 0 ? .green : .red)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal)
            
            // Price chart
            ZStack {
                // Sparkline chart visualization
                if let sparklineData = coin.sparkline_in_7d?.price, !sparklineData.isEmpty {
                    MockSparklineChartView(dataPoints: sparklineData, lineColor: coin.price_change_percentage_24h ?? 0 >= 0 ? .green : .red)
                        .frame(height: 200)
                } else {
                    // Fallback chart for demo purposes
                    MockChartView(isPositive: coin.price_change_percentage_24h ?? 0 >= 0)
                        .frame(height: 200)
                }
            }
            .padding(.top, 8)
            
            // Time period selection
            HStack(spacing: 16) {
                ForEach(["1H", "1D", "1W", "1M", "1Y", "All"], id: \.self) { period in
                    Button(action: {}) {
                        Text(period)
                            .font(.system(size: 14, weight: period == "1W" ? .bold : .regular))
                            .foregroundColor(period == "1W" ? .white : .gray)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 12)
                            .background(period == "1W" ? Color.blue.opacity(0.2) : Color.clear)
                            .cornerRadius(8)
                    }
                }
            }
            .padding(.top, 8)
        }
        .padding(.top, 16)
        .padding(.bottom, 24)
    }
    
    private var tabSelectionView: some View {
        HStack(spacing: 0) {
            ForEach(["Overview", "News", "Stats", "About"], id: \.self) { tab in
                let index = ["Overview", "News", "Stats", "About"].firstIndex(of: tab) ?? 0
                
                Button(action: {
                    withAnimation {
                        selectedTab = index
                    }
                }) {
                    VStack(spacing: 8) {
                        Text(tab)
                            .font(.system(size: 16, weight: selectedTab == index ? .semibold : .regular))
                            .foregroundColor(selectedTab == index ? .white : .gray)
                        
                        Rectangle()
                            .fill(selectedTab == index ? Color.blue : Color.clear)
                            .frame(height: 3)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .padding(.horizontal)
    }
    
    private var tabContentView: some View {
        VStack {
            switch selectedTab {
            case 0:
                overviewTab
            case 1:
                newsTab
            case 2:
                statsTab
            case 3:
                aboutTab
            default:
                overviewTab
            }
        }
        .padding(.top, 16)
        .padding(.bottom, 80) // Space for the bottom button
    }
    
    private var overviewTab: some View {
        VStack(spacing: 24) {
            // Price history
            VStack(alignment: .leading, spacing: 16) {
                Text("Price History")
                    .font(.headline)
                    .foregroundColor(.white)
                
                VStack(spacing: 16) {
                    ForEach(priceHistory) { entry in
                        HStack {
                            Text(entry.date)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            
                            Spacer()
                            
                            Text("$\(entry.price, specifier: "%.2f")")
                                .font(.subheadline)
                                .foregroundColor(.white)
                        }
                        Divider()
                            .background(Color.gray.opacity(0.3))
                    }
                }
            }
            .padding(.horizontal)
            
            // Market stats highlights
            VStack(alignment: .leading, spacing: 16) {
                Text("Market Stats")
                    .font(.headline)
                    .foregroundColor(.white)
                
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                    ForEach(marketStats.prefix(4), id: \.0) { stat in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(stat.0)
                                .font(.caption)
                                .foregroundColor(.gray)
                            
                            Text(stat.1)
                                .font(.subheadline)
                                .foregroundColor(.white)
                        }
                    }
                }
            }
            .padding(.horizontal)
            
            // Description preview
            VStack(alignment: .leading, spacing: 8) {
                Text("About")
                    .font(.headline)
                    .foregroundColor(.white)
                
                Text(bitcoinDescription.prefix(150) + "...")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .lineLimit(3)
                
                Button(action: {
                    selectedTab = 3 // Switch to About tab
                }) {
                    Text("Read more")
                        .font(.caption)
                        .foregroundColor(.blue)
                }
                .padding(.top, 4)
            }
            .padding(.horizontal)
        }
    }
    
    private var newsTab: some View {
        VStack(spacing: 16) {
            ForEach(1...5, id: \.self) { _ in
                newsCard
            }
        }
        .padding(.horizontal)
    }
    
    private var newsCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("CryptoNews")
                    .font(.caption)
                    .foregroundColor(.gray)
                
                Spacer()
                
                Text("2h ago")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Text("Bitcoin Surges Past $70,000 as Institutional Demand Continues to Rise")
                .font(.headline)
                .foregroundColor(.white)
                .lineLimit(2)
            
            Text("Bitcoin has reached new highs as more companies add the cryptocurrency to their balance sheets, signaling growing mainstream adoption...")
                .font(.subheadline)
                .foregroundColor(.gray)
                .lineLimit(2)
        }
        .padding(16)
        .background(Color(hex: "1A1A1A"))
        .cornerRadius(12)
    }
    
    private var statsTab: some View {
        VStack(spacing: 24) {
            // Market stats
            VStack(alignment: .leading, spacing: 16) {
                Text("Market Stats")
                    .font(.headline)
                    .foregroundColor(.white)
                
                ForEach(marketStats, id: \.0) { stat in
                    HStack {
                        Text(stat.0)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        
                        Spacer()
                        
                        Text(stat.1)
                            .font(.subheadline)
                            .foregroundColor(.white)
                    }
                    Divider()
                        .background(Color.gray.opacity(0.3))
                }
            }
            .padding(.horizontal)
            
            // Trading activity
            VStack(alignment: .leading, spacing: 16) {
                Text("Trading Activity")
                    .font(.headline)
                    .foregroundColor(.white)
                
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("52w Low")
                            .font(.caption)
                            .foregroundColor(.gray)
                        
                        Text("$24,800")
                            .font(.subheadline)
                            .foregroundColor(.white)
                    }
                    
                    Spacer()
                    
                    // Price range indicator
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 2)
                            .fill(Color.gray.opacity(0.3))
                            .frame(height: 4)
                        
                        RoundedRectangle(cornerRadius: 2)
                            .fill(Color.blue)
                            .frame(width: 200 * 0.85, height: 4) // 85% of the way from low to high
                        
                        Circle()
                            .fill(Color.blue)
                            .frame(width: 12, height: 12)
                            .offset(x: 200 * 0.85 - 6) // Center the circle on the indicator
                    }
                    .frame(width: 200)
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("52w High")
                            .font(.caption)
                            .foregroundColor(.gray)
                        
                        Text("$73,750")
                            .font(.subheadline)
                            .foregroundColor(.white)
                    }
                }
                
                // Volume
                HStack {
                    Text("Volume (24h)")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                    Spacer()
                    
                    Text("$48.2B")
                        .font(.subheadline)
                        .foregroundColor(.white)
                }
                Divider()
                    .background(Color.gray.opacity(0.3))
                
                // Popularity
                HStack {
                    Text("Popularity")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                    Spacer()
                    
                    Text("#1 Most held")
                        .font(.subheadline)
                        .foregroundColor(.white)
                }
                Divider()
                    .background(Color.gray.opacity(0.3))
            }
            .padding(.horizontal)
        }
    }
    
    private var aboutTab: some View {
        VStack(alignment: .leading, spacing: 24) {
            // Description
            VStack(alignment: .leading, spacing: 12) {
                Text("About \(coin.name)")
                    .font(.headline)
                    .foregroundColor(.white)
                
                Text(bitcoinDescription)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.horizontal)
            
            // Resources
            VStack(alignment: .leading, spacing: 12) {
                Text("Resources")
                    .font(.headline)
                    .foregroundColor(.white)
                
                VStack(spacing: 16) {
                    resourceLink(title: "Official Website", icon: "safari", url: "https://bitcoin.org")
                    resourceLink(title: "White Paper", icon: "doc.text", url: "https://bitcoin.org/bitcoin.pdf")
                    resourceLink(title: "Block Explorer", icon: "magnifyingglass", url: "https://blockstream.info")
                    resourceLink(title: "Source Code", icon: "chevron.left.slash.chevron.right", url: "https://github.com/bitcoin/bitcoin")
                }
            }
            .padding(.horizontal)
            
            // Team
            VStack(alignment: .leading, spacing: 12) {
                Text("Team")
                    .font(.headline)
                    .foregroundColor(.white)
                
                Text("Bitcoin was created by an anonymous person or group known as Satoshi Nakamoto in 2009.")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            .padding(.horizontal)
        }
    }
    
    private func resourceLink(title: String, icon: String, url: String) -> some View {
        HStack {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(.blue)
                .frame(width: 24, height: 24)
            
            Text(title)
                .font(.subheadline)
                .foregroundColor(.white)
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 14))
                .foregroundColor(.gray)
        }
        .padding(12)
        .background(Color(hex: "1A1A1A"))
        .cornerRadius(8)
    }
    
    private var buyButton: some View {
        Button(action: {}) {
            Text("Buy Bitcoin")
                .font(.headline)
                .foregroundColor(.white)
                .frame(height: 56)
                .frame(maxWidth: .infinity)
                .background(Color.blue)
                .cornerRadius(28)
                .padding(.horizontal, 24)
                .shadow(color: Color.blue.opacity(0.4), radius: 10, x: 0, y: 4)
        }
    }
}

// MARK: - Supporting Views

struct MockSparklineChartView: View {
    let dataPoints: [Double]
    let lineColor: Color
    
    var body: some View {
        GeometryReader { geometry in
            Path { path in
                let width = geometry.size.width
                let height = geometry.size.height
                
                // Find min and max for scaling
                guard let min = dataPoints.min(),
                      let max = dataPoints.max(),
                      min != max else {
                    return
                }
                
                let stepX = width / CGFloat(dataPoints.count - 1)
                let stepY = height / CGFloat(max - min)
                
                var points: [CGPoint] = []
                
                for (index, point) in dataPoints.enumerated() {
                    let x = CGFloat(index) * stepX
                    let y = height - CGFloat(point - min) * stepY
                    points.append(CGPoint(x: x, y: y))
                }
                
                // Start from the first point
                if let firstPoint = points.first {
                    path.move(to: firstPoint)
                }
                
                // Draw lines to all other points
                for point in points.dropFirst() {
                    path.addLine(to: point)
                }
            }
            .stroke(lineColor, style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
            
            // Add gradient fill
            LinearGradient(
                gradient: Gradient(colors: [lineColor.opacity(0.3), lineColor.opacity(0.01)]),
                startPoint: .top,
                endPoint: .bottom
            )
            .mask(
                Path { path in
                    let width = geometry.size.width
                    let height = geometry.size.height
                    
                    guard let min = dataPoints.min(),
                          let max = dataPoints.max(),
                          min != max else {
                        return
                    }
                    
                    let stepX = width / CGFloat(dataPoints.count - 1)
                    let stepY = height / CGFloat(max - min)
                    
                    var points: [CGPoint] = []
                    
                    for (index, point) in dataPoints.enumerated() {
                        let x = CGFloat(index) * stepX
                        let y = height - CGFloat(point - min) * stepY
                        points.append(CGPoint(x: x, y: y))
                    }
                    
                    // Start from the first point
                    if let firstPoint = points.first {
                        path.move(to: CGPoint(x: firstPoint.x, y: height))
                        path.addLine(to: firstPoint)
                    }
                    
                    // Draw lines to all other points
                    for point in points.dropFirst() {
                        path.addLine(to: point)
                    }
                    
                    // Close the path
                    if let lastPoint = points.last {
                        path.addLine(to: CGPoint(x: lastPoint.x, y: height))
                        path.closeSubpath()
                    }
                }
            )
        }
    }
}

struct MockChartView: View {
    let isPositive: Bool
    
    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let height = geometry.size.height
            
            Path { path in
                // Start at the left edge
                path.move(to: CGPoint(x: 0, y: height * 0.5))
                
                // First curve up
                path.addCurve(
                    to: CGPoint(x: width * 0.25, y: height * 0.4),
                    control1: CGPoint(x: width * 0.1, y: height * 0.5),
                    control2: CGPoint(x: width * 0.2, y: height * 0.3)
                )
                
                // Second curve down
                path.addCurve(
                    to: CGPoint(x: width * 0.5, y: height * 0.6),
                    control1: CGPoint(x: width * 0.3, y: height * 0.5),
                    control2: CGPoint(x: width * 0.4, y: height * 0.7)
                )
                
                // Final curve up or down based on price change
                if isPositive {
                    path.addCurve(
                        to: CGPoint(x: width, y: height * 0.2),
                        control1: CGPoint(x: width * 0.7, y: height * 0.4),
                        control2: CGPoint(x: width * 0.8, y: height * 0.3)
                    )
                } else {
                    path.addCurve(
                        to: CGPoint(x: width, y: height * 0.7),
                        control1: CGPoint(x: width * 0.7, y: height * 0.5),
                        control2: CGPoint(x: width * 0.8, y: height * 0.8)
                    )
                }
            }
            .stroke(isPositive ? Color.green : Color.red, style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
            
            // Add gradient fill
            LinearGradient(
                gradient: Gradient(colors: [
                    (isPositive ? Color.green : Color.red).opacity(0.3),
                    (isPositive ? Color.green : Color.red).opacity(0.01)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .mask(
                Path { path in
                    // Start at the bottom left
                    path.move(to: CGPoint(x: 0, y: height))
                    
                    // Line to the start of the curve
                    path.addLine(to: CGPoint(x: 0, y: height * 0.5))
                    
                    // First curve up
                    path.addCurve(
                        to: CGPoint(x: width * 0.25, y: height * 0.4),
                        control1: CGPoint(x: width * 0.1, y: height * 0.5),
                        control2: CGPoint(x: width * 0.2, y: height * 0.3)
                    )
                    
                    // Second curve down
                    path.addCurve(
                        to: CGPoint(x: width * 0.5, y: height * 0.6),
                        control1: CGPoint(x: width * 0.3, y: height * 0.5),
                        control2: CGPoint(x: width * 0.4, y: height * 0.7)
                    )
                    
                    // Final curve up or down based on price change
                    if isPositive {
                        path.addCurve(
                            to: CGPoint(x: width, y: height * 0.2),
                            control1: CGPoint(x: width * 0.7, y: height * 0.4),
                            control2: CGPoint(x: width * 0.8, y: height * 0.3)
                        )
                    } else {
                        path.addCurve(
                            to: CGPoint(x: width, y: height * 0.7),
                            control1: CGPoint(x: width * 0.7, y: height * 0.5),
                            control2: CGPoint(x: width * 0.8, y: height * 0.8)
                        )
                    }
                    
                    // Line to bottom right and close
                    path.addLine(to: CGPoint(x: width, y: height))
                    path.closeSubpath()
                }
            )
        }
    }
}


struct SparklineData: Codable {
    let price: [Double]
}


// MARK: - CryptoMarketViewModel

class CryptoMarketViewModel: ObservableObject {
    @Published var coins: [Coin] = []
    
    private var cancellables = Set<AnyCancellable>()
    private var fetchTimer = Timer.publish(every: 10, on: .main, in: .common).autoconnect()
    @Published var selectedCoinDetail: CoinDetail?
    
    init() {
        fetchData()
        fetchTimer
            .sink { [weak self] _ in
                self?.fetchData()
            }
            .store(in: &cancellables)
    }
    
    func fetchData() {
        
        guard let url = URL(string: "https://api.coingecko.com/api/v3/coins/markets?vs_currency=usd&order=market_cap_desc&per_page=250&page=1&sparkline=true") else {
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error fetching market data:", error)
                return
            }
            guard let data = data else { return }
            
            do {
                let decoded = try JSONDecoder().decode([Coin].self, from: data)
                DispatchQueue.main.async {
                    self.coins = decoded
                }
            } catch {
                print("Decoding error:", error)
            }
        }.resume()
    }
    
    func fetchCoinDetail(id: String) {
        DispatchQueue.main.async {
            self.selectedCoinDetail = nil
        }

        let url = URL(string: "https://api.coingecko.com/api/v3/coins/\(id)")!
            
        URLSession.shared.dataTask(with: url) { data, _, _ in
            if let data = data {
                if let decoded = try? JSONDecoder().decode(CoinDetail.self, from: data) {
                    DispatchQueue.main.async {
                        self.selectedCoinDetail = decoded
                    }
                } else {
                    print("Failed to decode detail for coin ID: \(id)")
                }
            } else {
                print("Failed to fetch data for coin ID: \(id)")
            }
        }.resume()
    }

}
