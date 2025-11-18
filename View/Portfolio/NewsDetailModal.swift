//
//  NewsDetailModal.swift
//  Dojo
//
//  Created by Raymond Hou on 4/9/25.
//

import SwiftUI
import Foundation

struct NewsDetailModal: View {
    let newsItem: NewsItem
    @Binding var isPresented: Bool
    @Binding var selectedNewsItem: NewsItem?
    @Binding var showNewsModal: Bool
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            // Background
            Color(hex: "050715")
                .ignoresSafeArea()
            
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(spacing: 0) {
                        // Top Navigation Bar
                        HStack {
                            Button(action: {
                                isPresented = false
                                dismiss()
                            }) {
                                HStack(spacing: 6) {
                                    Image(systemName: "chevron.down")
                                        .font(.system(size: 18, weight: .medium))
                                    Text("Back to Portfolio")
                                        .font(.custom("Satoshi-Bold", size: 18))
                                }
                                .foregroundColor(.white)
                            }
                            .buttonStyle(PlainButtonStyle())
                            
                            Spacer()
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                        .padding(.bottom, 16)
                        .id("top")
                    
                        // Main News Image
                        if let imageUrl = newsItem.imageUrl, !imageUrl.isEmpty {
                            Image(imageUrl)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(height: 250)
                                .clipped()
                                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                        }
                    
                        // Article Content
                        VStack(alignment: .leading, spacing: 20) {
                            // Metadata Blocks
                            HStack(spacing: 8) {
                                 // Author Block
                                 HStack(spacing: 8) {
                                     Image("Profile")
                                         .resizable()
                                         .aspectRatio(contentMode: .fill)
                                         .frame(width: 24, height: 24)
                                         .clipShape(Circle())
                                     
                                     Text("James Wang")
                                         .font(.custom("Satoshi-Medium", size: 14))
                                         .foregroundColor(.white)
                                         .lineLimit(1)
                                 }
                                 .frame(height: 40)
                                 .padding(.horizontal, 12)
                                 .background(Color(hex: "141628"))
                                 .cornerRadius(8)
                                
                                // Date Block
                                HStack(spacing: 4) {
                                    Image(systemName: "clock")
                                        .font(.system(size: 12))
                                        .foregroundColor(.gray)
                                    Text(formatNewsDate(newsItem.publishedAt))
                                        .font(.custom("Satoshi-Medium", size: 14))
                                        .foregroundColor(.white)
                                }
                                .frame(height: 40)
                                .padding(.horizontal, 12)
                                .background(Color(hex: "141628"))
                                .cornerRadius(8)
                                
                                // Views Block
                                HStack(spacing: 4) {
                                    Image(systemName: "eye")
                                        .font(.system(size: 12))
                                        .foregroundColor(.gray)
                                    Text("184 102")
                                        .font(.custom("Satoshi-Medium", size: 14))
                                        .foregroundColor(.white)
                                }
                                .frame(height: 40)
                                .padding(.horizontal, 12)
                                .background(Color(hex: "141628"))
                                .cornerRadius(8)
                            }
                            .padding(.horizontal, 20)
                            .padding(.top, 20)
                            
                            // Article Title
                            Text(newsItem.title)
                                .font(.custom("Satoshi-Bold", size: 24))
                                .foregroundColor(.white)
                                .lineLimit(nil)
                                .padding(.horizontal, 20)
                            
                            // Article Description
                            Text(newsItem.description)
                                .font(.custom("Satoshi-Regular", size: 16))
                                .foregroundColor(.white)
                                .lineLimit(nil)
                                .padding(.horizontal, 20)
                            
                            // Full Article Content
                            VStack(alignment: .leading, spacing: 16) {
                                ForEach(getArticleContent(for: newsItem), id: \.self) { paragraph in
                                    if paragraph.hasPrefix("**") && paragraph.hasSuffix("**") {
                                        // Bold heading
                                        Text(String(paragraph.dropFirst(2).dropLast(2)))
                                            .font(.custom("Satoshi-Bold", size: 18))
                                            .foregroundColor(.white)
                                            .lineLimit(nil)
                                    } else if paragraph.contains("$") && paragraph.contains("b") {
                                        // Statistics row
                                        HStack(spacing: 20) {
                                            ForEach(paragraph.components(separatedBy: " | "), id: \.self) { stat in
                                                Text(stat)
                                                    .font(.custom("Satoshi-Medium", size: 14))
                                                    .foregroundColor(stat.contains("+") ? .green : .white)
                                            }
                                        }
                                    } else if paragraph == "CHART" {
                                        // Embedded Chart Placeholder
                                        VStack(spacing: 12) {
                                            RoundedRectangle(cornerRadius: 12)
                                                .fill(Color.gray.opacity(0.2))
                                                .frame(height: 120)
                                                .overlay(
                                                    VStack {
                                                        Text("Market Data Visualization")
                                                            .font(.custom("Satoshi-Medium", size: 14))
                                                            .foregroundColor(.gray)
                                                    }
                                                )
                                        }
                                    } else {
                                        // Regular paragraph
                                        Text(paragraph)
                                            .font(.custom("Satoshi-Regular", size: 16))
                                            .foregroundColor(.white)
                                            .lineLimit(nil)
                                    }
                                }
                            }
                            .padding(.horizontal, 20)
                            
                            // Similar News Section
                            VStack(alignment: .leading, spacing: 16) {
                                Text("Similar News")
                                    .font(.custom("Satoshi-Bold", size: 20))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 20)
                                    .padding(.top, 40)
                                
                                VStack(spacing: 16) {
                                    ForEach(similarNews) { similarNewsItem in
                                        SimilarNewsCard(newsItem: similarNewsItem) {
                                            // Scroll to top first, then close current modal and open new one
                                            withAnimation(.easeInOut(duration: 0.2)) {
                                                proxy.scrollTo("top", anchor: .top)
                                            }
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                                withAnimation(.easeInOut(duration: 0.3)) {
                                                    isPresented = false
                                                    selectedNewsItem = similarNewsItem
                                                    showNewsModal = true
                                                }
                                            }
                                        }
                                    }
                                }
                                .padding(.horizontal, 20)
                            }
                            
                            // Back to Portfolio Button
                            Button(action: {
                                isPresented = false
                                dismiss()
                            }) {
                                HStack(spacing: 6) {
                                    Image(systemName: "chevron.down")
                                        .font(.system(size: 18, weight: .medium))
                                    Text("Back to Portfolio")
                                        .font(.custom("Satoshi-Bold", size: 18))
                                }
                                .foregroundColor(.white)
                            }
                            .buttonStyle(PlainButtonStyle())
                            .frame(maxWidth: .infinity)
                            .padding(.top, 20)
                            .padding(.bottom, 40)
                        }
                    }
                }
            }
        }
    }
}

// Helper functions
func formatNewsDate(_ dateString: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        
        if let date = formatter.date(from: dateString) {
            formatter.dateFormat = "MMM d, yyyy"
            return formatter.string(from: date)
        }
        
        return dateString
}

func getArticleContent(for newsItem: NewsItem) -> [String] {
        switch newsItem.imageUrl {
        case "TetherNews":
            return [
                "The stablecoin market keeps expanding, and if another $2,589 billion flows in next week, it'll cross the $270 billion threshold. As of Saturday, Aug. 2, 2025, fiat-pegged tokens collectively sit at $267.411 billion—up $13.537 billion since the start of July. Tether (USDT) still leads the pack, commanding 61.59% of the entire market.",
                "**USDe, USDf Steal the Spotlight With 62.55% and 103% Jumps in One Month**",
                "The latest figures reveal that the stablecoin economy expanded by 5.33% in July, with a $13.537 billion boost added over the course of the month. This growth was primarily driven by significant increases in Ethena's USDe and Falcon's USDf tokens, which saw remarkable 62.55% and 103% growth respectively.",
                "CHART",
                "$267.411b | +$2.396b | 61.59%",
                "Market leaders include USDT with $164.6 billion, USDC with $33.2 billion, and Ethena's USDe with $3.2 billion. The rapid growth of newer stablecoins like USDe and USDf demonstrates the evolving landscape of digital assets, with algorithmic stablecoins gaining significant traction among institutional investors."
            ]
        case "HackerNews":
            return [
                "A crypto wallet tied to a little-known Chinese mining company has been identified as the source of a massive Bitcoin theft that went undetected for nearly a decade. Arkham Intelligence revealed that the wallet, associated with LuBian Technology, contains over $3.5 billion worth of Bitcoin stolen from various exchanges and platforms.",
                "**The $3.5B LuBian Bitcoin Theft: A Decade-Long Mystery Unraveled**",
                "The investigation uncovered that LuBian Technology, a relatively obscure mining operation based in China, had been systematically draining Bitcoin from multiple cryptocurrency exchanges since 2015. The sophisticated operation involved creating thousands of wallet addresses and using advanced techniques to avoid detection.",
                "CHART",
                "$3.5b stolen | 9 years active | 2,847 wallets",
                "Security experts are calling this one of the largest and most sophisticated cryptocurrency thefts in history. The revelation has sent shockwaves through the crypto community, raising questions about exchange security and the effectiveness of current blockchain surveillance tools."
            ]
        case "GovernmentNews":
            return [
                "The U.S. Securities and Exchange Commission (SEC) has announced a nationwide tour to engage with small cryptocurrency startups and hear their concerns about regulatory compliance. The initiative, dubbed the 'Crypto Task Force Tour,' aims to bridge the gap between regulators and emerging blockchain companies.",
                "**SEC's Crypto Task Force Will Tour U.S. to Hear From Small Startups**",
                "The tour will visit major tech hubs including Silicon Valley, Austin, Miami, and New York, where SEC officials will conduct listening sessions with startup founders, developers, and legal experts. The goal is to better understand the challenges faced by smaller companies in navigating complex securities regulations.",
                "CHART",
                "15 cities | 200+ startups | 6 months",
                "This unprecedented outreach effort represents a significant shift in the SEC's approach to cryptocurrency regulation, moving from enforcement-heavy tactics to more collaborative engagement with the industry. Small startups have long complained about the lack of clear guidance and the high costs of compliance."
            ]
        case "SolNews":
            return [
                "Solana's strong run in July came to an abrupt halt as the cryptocurrency broke below the critical $165 support level. The decline was fueled by fading ETF hype and renewed concerns about Federal Reserve monetary policy, which has created headwinds for risk assets across the board.",
                "**Solana Price Breaks Below $165: ETF Hype Fades, Fed Fuels Decline**",
                "The cryptocurrency had been riding high on speculation about potential Solana ETF approvals, but recent comments from SEC officials have dampened expectations. Additionally, the Federal Reserve's hawkish stance on interest rates has created a challenging environment for high-growth assets like Solana.",
                "CHART",
                "$165 support | -12.5% weekly | $8.2b volume",
                "Technical analysts are now watching the $150 level as the next major support zone. The decline has also impacted Solana's DeFi ecosystem, with total value locked (TVL) dropping by approximately 8% over the past week as investors reassess risk in the current market environment."
            ]
        case "BearNews":
            return [
                "The crypto market took a sharp downturn today as Bitcoin and other major cryptocurrencies faced significant selling pressure. The decline was triggered by a combination of macroeconomic concerns, regulatory uncertainty, and profit-taking by institutional investors after recent gains.",
                "**Bitcoin and the Crypto Market Are in the Red Today, Here's Why**",
                "Bitcoin fell below $65,000 for the first time in two weeks, while Ethereum dropped to $3,200. The broader crypto market cap declined by over 5% in a single day, wiping out approximately $200 billion in market value across all digital assets.",
                "CHART",
                "-5.2% market cap | $200b lost | 24h volume",
                "Market analysts attribute the selloff to several factors: renewed concerns about inflation data, uncertainty surrounding upcoming Federal Reserve meetings, and profit-taking by large institutional holders who had accumulated positions during the recent rally. The fear and greed index has shifted from 'greed' to 'fear' territory for the first time in three weeks."
            ]
        default:
            return [
                "This is a comprehensive analysis of the current state of the cryptocurrency market and its implications for investors and industry participants. The article explores key trends, market dynamics, and future outlook for digital assets.",
                "**Market Analysis and Future Outlook**",
                "Recent developments in the cryptocurrency space have highlighted both opportunities and challenges for market participants. Understanding these dynamics is crucial for making informed investment decisions in this rapidly evolving sector.",
                "CHART",
                "Market data | Trends | Analysis",
                "The cryptocurrency market continues to mature, with increasing institutional adoption and regulatory clarity providing a more stable foundation for long-term growth. However, volatility remains a key characteristic that investors must navigate carefully."
            ]
        }
}

// Sample similar news data
let similarNews: [NewsItem] = [
        NewsItem(id: "2", title: "Arkham Says $3.5B LuBian Bitcoin Theft Went Undetected for Nearly...", description: "A crypto wallet tied to a little...", source: "The Block", url: "https://example.com", publishedAt: "2025-08-02T10:00:00Z", imageUrl: "HackerNews", relatedAssetId: "bitcoin"),
        NewsItem(id: "3", title: "SEC's Crypto Task Force Will Tour U.S. to Hear From Small Startups...", description: "The U.S. Securities and Exchange...", source: "Reuters", url: "https://example.com", publishedAt: "2025-08-01T10:00:00Z", imageUrl: "GovernmentNews", relatedAssetId: nil),
        NewsItem(id: "4", title: "Solana Price Breaks Below $165: ETF Hype Fades, Fed Fuels Decline", description: "Solana's strong run in July...", source: "Decrypt", url: "https://example.com", publishedAt: "2025-07-30T10:00:00Z", imageUrl: "SolNews", relatedAssetId: "solana"),
        NewsItem(id: "5", title: "Bitcoin and the crypto market are in the red today, here's why", description: "The crypto market took a sharp...", source: "CoinTelegraph", url: "https://example.com", publishedAt: "2025-07-28T10:00:00Z", imageUrl: "BearNews", relatedAssetId: "bitcoin")
]

struct SimilarNewsCard: View {
    let newsItem: NewsItem
    let onTap: () -> Void
    
    var body: some View {
        Button {
            onTap()
        } label: {
            HStack(alignment: .top, spacing: 12) {
                // News Image
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
                
                // News Content
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
        .buttonStyle(PlainButtonStyle())
    }
}


struct NewsDetailModal_Previews: PreviewProvider {
    static var previews: some View {
        NewsDetailModal(
            newsItem: NewsItem(
                id: "1",
                title: "Stablecoin Explosion: Over $13.5B Added in July as Market Nears $270B Milestone",
                description: "The latest figures reveal that the stablecoin economy expanded by 5.33% in July",
                source: "CoinDesk",
                url: "https://example.com",
                publishedAt: "2025-08-03T10:00:00Z",
                imageUrl: "TetherNews",
                relatedAssetId: "tether"
            ),
            isPresented: .constant(true),
            selectedNewsItem: .constant(nil),
            showNewsModal: .constant(true)
        )
        .preferredColorScheme(.dark)
    }
}
