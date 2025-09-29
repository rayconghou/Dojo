import Foundation
import SwiftUI

struct AuthView: View {
    @State private var email = ""
    @State private var username = ""
    @State private var password = ""
    @State private var message = ""
    @State private var loading = false
    @State private var isNewUser = false

    var body: some View {
        VStack(spacing: 24) {
            Text(isNewUser ? "Create Account" : "Sign In to Dojo")
                .font(.title)
                .bold()

            TextField("Enter your email", text: $email)
                .autocapitalization(.none)
                .keyboardType(.emailAddress)
                .padding()
                .background(Color.gray.opacity(0.15))
                .cornerRadius(8)
                .padding(.horizontal)

            SecureField("Enter your password", text: $password)
                .padding()
                .background(Color.gray.opacity(0.15))
                .cornerRadius(8)
                .padding(.horizontal)
            
            if isNewUser {
                TextField("Enter your name", text: $username)
                    .autocapitalization(.none)
                    .padding()
                    .background(Color.gray.opacity(0.15))
                    .cornerRadius(8)
                    .padding(.horizontal)
            }

            Button(action: {
                loading = true
                
                func reactToResult(result: Result<Void, Error>) {
                    loading = false
                    switch result {
                    case .success:
//                        authViewModel.isLoggedIn = true
                        break
                    case .failure(let error):
                        message = "Error: \(error.localizedDescription)"
                    }
                }
                
                if isNewUser {
                    AuthManager.shared.signUp(email: email, password: password, username: username) {result in
                        let userProfile = UserProfileViewModel(email: email, username: username)
                        
                        AuthManager.shared.userProfile = userProfile
                        switch result {
                        case .success:
                            break
                        case .failure:
                            AuthManager.shared.userProfile = nil
                        }
                        reactToResult(result: result)
                    }
                } else {
                    AuthManager.shared.signIn(email: email, password: password) {result in
                        reactToResult(result: result)
                    }
                }
            }) {
                Text(isNewUser ? "Create Account" : "Sign In")
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            .padding(.horizontal)
            .disabled(email.isEmpty || password.isEmpty || loading)

            Button(action: {
                isNewUser.toggle()
            }) {
                Text(isNewUser ? "Already have an account? Sign In" : "Don't have an account? Sign Up")
                    .font(.footnote)
                    .foregroundColor(.blue)
            }

            if !message.isEmpty {
                Text(message)
                    .foregroundColor(.gray)
                    .padding()
            }

            Spacer()
        }
        .padding(.top, 100)
    }

    private func handleResult(_ result: Result<Void, Error>) {
        switch result {
        case .success:
            message = isNewUser ? "Account created!" : "Signed in!"
        case .failure(let error):
            message = "Error: \(error.localizedDescription)"
        }
    }
}
