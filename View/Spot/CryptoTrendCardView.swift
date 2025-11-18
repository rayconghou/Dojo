//
//  CryptoTrendCardView.swift
//  Dojo
//
//  Created by Raymond Hou on 3/11/25.
//

import Foundation
import SwiftUI


struct CryptoTrendCard: View {
    let rank: Int
    let name: String
    let symbol: String
    let imageUrl: String
    let price: Double
    /// This is the 24h change in percent (e.g. -3.12 means -3.12%)
    let change: Double
    /// Array of price points (ideally last 24 hours)
    let sparkline: [Double]
    
    var body: some View {
        ZStack {
            // Halo glow effect that fades to nothing at bottom of chart
            RoundedRectangle(cornerRadius: 15)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            (change >= 0 ? Color.green : Color.red).opacity(0.06),
                            (change >= 0 ? Color.green : Color.red).opacity(0.04),
                            (change >= 0 ? Color.green : Color.red).opacity(0.025),
                            (change >= 0 ? Color.green : Color.red).opacity(0.015),
                            (change >= 0 ? Color.green : Color.red).opacity(0.008),
                            (change >= 0 ? Color.green : Color.red).opacity(0.004),
                            (change >= 0 ? Color.green : Color.red).opacity(0.002),
                            (change >= 0 ? Color.green : Color.red).opacity(0.001),
                            Color.clear
                        ]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .blur(radius: 6)
                .offset(y: 2)
                .frame(height: 100) // Extend to bottom of chart area
            
            // Background
            Color(hex: "141628")
                .cornerRadius(15)
            
            VStack(spacing: 0) {
                // Top section: Coin info and price
                HStack(spacing: 12) {
                    // Left side: Rank, Logo, Name/Symbol
                    HStack(spacing: 12) {
                        // Ranking
                        Text("#\(rank)")
                            .font(.custom("Satoshi-Black", size: 14))
                            .foregroundColor(.gray)
                        
                        // Async coin image with consistent rounded square format
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
                                .fill(backgroundColorForSymbol(symbol))
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(name)
                                .font(.custom("Satoshi-Black", size: 16))
                                .foregroundColor(.white)
                            Text(symbol.uppercased())
                                .font(.custom("Satoshi-Black", size: 14))
                                .foregroundColor(.gray)
                        }
                    }
                    
                    Spacer()
                    
                    // Right side: Price and Change
                    VStack(alignment: .trailing, spacing: 4) {
                        Text(price.asFormattedCurrency)
                            .font(.custom("Satoshi-Black", size: 16))
                            .foregroundColor(.white)
                        
                        HStack(spacing: 4) {
                            // Triangle indicator instead of arrow
                            Image(systemName: change >= 0 ? "triangle.fill" : "triangle.fill")
                                .resizable()
                                .foregroundColor(change >= 0 ? .green : .red)
                                .frame(width: 8, height: 8)
                                .rotationEffect(.degrees(change >= 0 ? 0 : 180))
                            
                            Text(String(format: "%.2f%%", abs(change)))
                                .font(.custom("Satoshi-Black", size: 14))
                                .foregroundColor(change >= 0 ? .green : .red)
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 15)
                .padding(.bottom, 10)
                
                // Spacer to push sparkline to bottom
                Spacer()
                
                // Bottom section: Full-width sparkline chart positioned at bottom
                SparklineChartView(data: sparkline, isPositive: change >= 0)
                    .frame(height: 50)
                    .padding(.horizontal, 20) // Match the card's horizontal padding
                    .padding(.bottom, 15) // Keep some padding from the very bottom edge
            }
        }
        .frame(height: 123) // Updated to match Figma specifications
    }
}

// A simple sparkline chart that scales the data to the view's height
struct SparklineChartView: View {
    let data: [Double]
    let isPositive: Bool
    
    var body: some View {
        GeometryReader { geometry in
            if let minValue = data.min(), let maxValue = data.max(), minValue != maxValue {
                // Use the actual data without excessive extrapolation
                let normalizedData = data.map { ($0 - minValue) / (maxValue - minValue) }
                let step = geometry.size.width / CGFloat(normalizedData.count - 1)
                
                ZStack {
                    // Glowing effect (gradient fill below the line)
                    Path { path in
                        path.move(to: CGPoint(x: 0, y: geometry.size.height))
                        path.addLine(to: CGPoint(x: 0, y: geometry.size.height * (1 - normalizedData.first!)))
                        
                        for i in normalizedData.indices {
                            let x = CGFloat(i) * step
                            let y = geometry.size.height * (1 - normalizedData[i])
                            path.addLine(to: CGPoint(x: x, y: y))
                        }
                        
                        path.addLine(to: CGPoint(x: geometry.size.width, y: geometry.size.height))
                        path.closeSubpath()
                    }
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                (isPositive ? Color.green : Color.red).opacity(0.3),
                                (isPositive ? Color.green : Color.red).opacity(0.05)
                            ]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    
                    // Main chart line
                    Path { path in
                        path.move(to: CGPoint(x: 0, y: geometry.size.height * (1 - normalizedData.first!)))
                        for i in normalizedData.indices {
                            let x = CGFloat(i) * step
                            let y = geometry.size.height * (1 - normalizedData[i])
                            path.addLine(to: CGPoint(x: x, y: y))
                        }
                    }
                    .stroke(isPositive ? Color.green : Color.red, lineWidth: 1.5)
                    .opacity(0.9)
                }
            } else {
                // Fallback flat line if data is constant or empty
                Path { path in
                    path.move(to: CGPoint(x: 0, y: geometry.size.height / 2))
                    path.addLine(to: CGPoint(x: geometry.size.width, y: geometry.size.height / 2))
                }
                .stroke(isPositive ? Color.green : Color.red, lineWidth: 1.5)
                .opacity(0.8)
            }
        }
    }
}


struct CryptoTrendCard_Previews: PreviewProvider {
    static var previews: some View {
        CryptoTrendCard(
            rank: 1,
            name: "Bitcoin",
            symbol: "btc",
            imageUrl: "https://assets.coingecko.com/coins/images/1/large/bitcoin.png",
            price: 117176.16,
            change: 1.12,
            sparkline: [100, 102, 98, 105, 110, 108, 115, 112, 120, 118, 125, 122, 130, 128, 135, 132, 140, 138, 145, 142, 150, 148, 155, 152]
        )
        .previewLayout(.sizeThatFits)
        .preferredColorScheme(.dark)
    }
}
