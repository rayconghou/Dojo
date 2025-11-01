//
//  PostsFetcher.swift
//  Dojo
//
//  Created by Hugh on 10/31/25.
//

import Foundation
import Combine

struct Post: Codable, Identifiable {
    let id: Int
    let poster_uid: String
    let preceding_post_id: Int?
    let text: String
    let created_at: Date
    
    enum CodingKeys: String, CodingKey {
        case id = "post_id"
        case poster_uid
        case preceding_post_id
        case text
        case created_at
    }
}

// MARK: - PostsViewModel

class PostsViewModel: ObservableObject {
    static let shared = PostsViewModel()
    
    @Published var posts: [Post] = []
    
    private var cancellables = Set<AnyCancellable>()
    private var fetchTimer = Timer.publish(every: 10, on: .main, in: .common).autoconnect()
    @Published var selectedCoinDetail: CoinDetail?
    
    init() {
//        TEMP: In future, will fetch everytime we set new posts view
//        fetchData()
//        fetchTimer
//            .sink { [weak self] _ in
//                self?.fetchData()
//            }
//            .store(in: &cancellables)
    }
    
    // TEMP will need paramaters to describe which posts to get
    func fetchData() {
//        TEMP, just getting one post right now
        ContentView.webSocketManager.send(message: "{\"action\": \"getPost\", \"message_type\":\"getPost\", \"post_id\":\"\(7)\"}")
        ContentView.webSocketManager.send(message: "{\"action\": \"getPost\", \"message_type\":\"getPost\", \"post_id\":\"\(4)\"}")
    }
    
//    func fetchPostReplies(id: String) {
//        
//        // REST HAS NOT BEEN EDITED
//
//        DispatchQueue.main.async {
//            self.selectedCoinDetail = nil
//        }
//
//        let url = URL(string: "https://api.coingecko.com/api/v3/coins/\(id)")!
//            
//        URLSession.shared.dataTask(with: url) { data, _, _ in
//            if let data = data {
//                if let decoded = try? JSONDecoder().decode(CoinDetail.self, from: data) {
//                    DispatchQueue.main.async {
//                        self.selectedCoinDetail = decoded
//                    }
//                } else {
//                    print("Failed to decode detail for coin ID: \(id)")
//                }
//            } else {
//                print("Failed to fetch data for coin ID: \(id)")
//            }
//        }.resume()
//    }

}
