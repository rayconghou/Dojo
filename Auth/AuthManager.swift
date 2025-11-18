import Foundation
import FirebaseAuth
import AWSSQS
import SwiftUI

enum AuthError: Error {
    case noCurrentUserAfterCreatingUser
    case userWithoutEmail
    case triedToSetLoggedInWithoutUser
}

class AuthManager: ObservableObject {
    @Published var hasUserProfile = false
    @Published var isLoggedIn = false {
        didSet {
            if (isLoggedIn) {
                if Auth.auth().currentUser == nil {
                    print("Error: \(AuthError.triedToSetLoggedInWithoutUser)")
                }
            }
        }
    }
    
    var profilePic: UIImage?;
    
    static let shared = AuthManager()
    static let aws_region = "us-east-2"
    
    var userProfile: UserProfileViewModel? {
        didSet {
    //        TEMP
            if let unwrapped_user_profile = userProfile {
                FeedModel.otherUserHavingFeed = FeedModel(user_profile: unwrapped_user_profile, feed_key: "main")
            }
            
            DispatchQueue.main.async {
                self.hasUserProfile = self.userProfile != nil
            }
        }
    }

    private init() {
        if let unwrappedCurrentUser = Auth.auth().currentUser {
            logInUser(user: unwrappedCurrentUser)
        }
    }
    
    func signUp(email: String, password: String, username: String, completion: @escaping (Result<Void, Error>) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let error = error {
                completion(.failure(error))
            } else {
                print("Auth signed in")
                if let user = Auth.auth().currentUser {
                    self.userProfile = UserProfileViewModel(firebase_uid: user.uid, email: email, username: username)
                    self.logInUser(user: user)
                    completion(.success(()))
                } else {
                    completion(.failure(AuthError.noCurrentUserAfterCreatingUser))
                }
            }
        }
    }
    
    func signIn(email: String, password: String, completion: @escaping (Result<Void, Error>) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            if let error = error {
                completion(.failure(error))
            } else {
                if let user = self.getCurrentUser() {
                    self.logInUser(user: user)
                    completion(.success(()))
                }
            }
        }
    }

    func signOut() {
        do {
            try Auth.auth().signOut()
            userProfile = nil
            self.isLoggedIn = false
        } catch {
            print("Sign-out failed:", error)
        }
    }

    func getCurrentUser() -> User? {
        return Auth.auth().currentUser
    }
    
    func logInUser(user: User) {
        self.isLoggedIn = true
        
        // Start connecting
        if let url = URL(string: "wss://6kmh7sue9j.execute-api.us-east-2.amazonaws.com/production/") {
            ContentView.webSocketManager.connect(url:  url, user: user)
        }
    }
}
