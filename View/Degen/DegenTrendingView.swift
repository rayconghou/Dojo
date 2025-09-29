//
//  DegenTrendingView.swift
//  Dojo
//
//  Created by Raymond Hou on 3/31/25.
//

import SwiftUI

enum VerificationFilter: String, CaseIterable {
    case verified = "Verified"
    case unverified = "Unverified"
}

struct DegenTrendingView: View {
    @StateObject var degenVM = DegenTrendingViewModel()

    @State private var searchText = ""
    @State private var selectedFilter: VerificationFilter = .verified
    @State private var verifiedTokenSet: Set<String> = []
    
    @State private var selectedToken: DexScreenerTokenProfile? = nil  // For modal

    var filteredTokens: [DexScreenerTokenProfile] {
        degenVM.latestTokens.filter { token in
            let matchesVerification: Bool = {
                switch selectedFilter {
                case .verified: return verifiedTokenSet.contains(token.tokenAddress)
                case .unverified: return !verifiedTokenSet.contains(token.tokenAddress)
                }
            }()

            let matchesSearch = searchText.isEmpty ||
                token.tokenAddress.localizedCaseInsensitiveContains(searchText) ||
                token.chainId.localizedCaseInsensitiveContains(searchText) ||
                (token.description?.localizedCaseInsensitiveContains(searchText) ?? false)

            return matchesVerification && matchesSearch
        }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Toggle Bar
                Picker("Filter", selection: $selectedFilter) {
                    ForEach(VerificationFilter.allCases, id: \ .self) { filter in
                        Text(filter.rawValue)
                            .tag(filter)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal, 16)
                .padding(.top, 12)
                .background(Color.black)

                // Search Bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)

                    TextField("Search new tokens...", text: $searchText)
                        .foregroundColor(.white)

                    if !searchText.isEmpty {
                        Button {
                            searchText = ""
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.gray)
                        }
                    }
                }
                .padding(.vertical, 8)
                .padding(.horizontal, 12)
                .background(Color(white: 0.15))
                .cornerRadius(8)
                .padding(.horizontal, 16)

                // Token List
                ScrollView {
                    LazyVStack(spacing: 8) {
                        ForEach(filteredTokens) { token in
                            DegenTokenRow(token: token)
                                .listRowInsets(EdgeInsets())
                                .onTapGesture {
                                    selectedToken = token  // Show modal when tapped
                                }
                        }
                    }
                    .padding(16)
                }
                .background(Color.black)

                if let errorMsg = degenVM.errorMessage {
                    Text(errorMsg)
                        .foregroundColor(.red)
                        .padding()
                }
            }
            .navigationTitle("Trending")
            .background(Color.black.edgesIgnoringSafeArea(.all))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack(spacing: 16) {
                        Button(action: {}) {
                            Image(systemName: "bell")
                                .foregroundColor(.white)
                        }
                        Button(action: {}) {
                            Image(systemName: "info.circle")
                                .foregroundColor(.white)
                        }
                    }
                }
            }
            .onAppear {
                fetchVerifiedTokenSet()
                Task { await degenVM.fetchLatestTokens() } // fetch trending tokens here
            }
            .sheet(item: $selectedToken) { token in
                TokenDetailModal(token: token) {
                    selectedToken = nil
                }
            }
        }
    }

    private func fetchVerifiedTokenSet() {
        guard let url = URL(string: "https://lite-api.jup.ag/tokens/v1/tagged/verified") else { return }
        Task {
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                if let tokens = try? JSONDecoder().decode([DexScreenerTokenProfile].self, from: data) {
                    let verifiedAddresses = tokens.map { $0.tokenAddress }
                    await MainActor.run {
                        self.verifiedTokenSet = Set(verifiedAddresses)
                    }
                }
            } catch {
                print("Failed to fetch verified tokens: \(error)")
            }
        }
    }
}

struct DegenTokenRow: View {
    let token: DexScreenerTokenProfile

    var body: some View {
        HStack(spacing: 12) {
            // Token Icon
            AsyncImage(url: URL(string: token.icon ?? "")) { phase in
                switch phase {
                case .empty:
                    ProgressView()
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFit()
                case .failure:
                    Image(systemName: "exclamationmark.triangle.fill")
                        .resizable()
                        .scaledToFit()
                @unknown default:
                    EmptyView()
                }
            }
            .frame(width: 24, height: 24)
            .clipShape(Circle())

            // Info: chain, address, or description
            VStack(alignment: .leading, spacing: 2) {
                Text(token.tokenAddress.prefix(8) + "...")
                    .font(.subheadline)
                    .foregroundColor(.white)
                Text(token.chainId.uppercased())
                    .font(.caption2)
                    .foregroundColor(.gray)
            }

            Spacer()

            // Possibly show a short snippet of the description (for “degen hype”)
            if let desc = token.description, !desc.isEmpty {
                Text(desc)
                    .font(.caption)
                    .foregroundColor(.white)
                    .lineLimit(1)
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 8)
        .background(Color(white: 0.1))
        .cornerRadius(8)
    }
}

struct TokenDetailModal: View {
    let token: DexScreenerTokenProfile
    let dismiss: () -> Void  // Add this closure

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                AsyncImage(url: URL(string: token.icon ?? "")) { phase in
                    switch phase {
                    case .empty: ProgressView()
                    case .success(let img): img.resizable().scaledToFit()
                    case .failure: Image(systemName: "exclamationmark.triangle.fill")
                    @unknown default: EmptyView()
                    }
                }
                .frame(width: 100, height: 100)
                .clipShape(Circle())

                Text(token.tokenAddress)
                    .font(.headline)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)

                if let desc = token.description {
                    Text(desc)
                        .font(.body)
                        .padding()
                }

                VStack(spacing: 12) {
                    if let website = token.websiteURL {
                        Link(destination: website) {
                            Label("Website", systemImage: "globe")
                                .foregroundColor(.blue)
                        }
                    }
                    if let twitter = token.twitterURL {
                        Link(destination: twitter) {
                            Label("Twitter", systemImage: "bird")
                                .foregroundColor(.blue)
                        }
                    }
                    if let telegram = token.telegramURL {
                        Link(destination: telegram) {
                            Label("Telegram", systemImage: "paperplane")
                                .foregroundColor(.blue)
                        }
                    }
                }
                Spacer()
            }
            .padding()
            .navigationTitle("Token Details")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                        // Modal dismissal handled by .sheet environment
                        // Dismiss by setting selectedToken = nil in parent
                        // This button can call a closure if you pass one, or rely on default swipe down
                        
                    }
                }
            }
        }
    }
}


struct DegenTrendingView_Previews: PreviewProvider {
    static var previews: some View {
        DegenTrendingView()
            .preferredColorScheme(.dark)
    }
}
