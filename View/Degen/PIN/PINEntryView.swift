//
//  PINEntryView.swift
//  Dojo
//
//  Created by Raymond Hou on 3/31/25.
//

import Foundation
import SwiftUI
import LocalAuthentication

struct PINEntryView: View {
    @ObservedObject var authManager = AuthManager.shared
    @ObservedObject var viewModel: SecureSignInFlowViewModel
    @State private var biometricAttempted = false
    
    var body: some View {
        ZStack {
            // Dark background with NormalSplashBackground
            Color(red: 0.02, green: 0.03, blue: 0.08) // #050715
                .ignoresSafeArea()
            
            // NormalSplashBackground asset
            Image("NormalSplashBackground")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .ignoresSafeArea()
            
            VStack {
                // Status bar area
                
                Spacer().frame(height: 60)
                
                // Profile section
                VStack(spacing: 20) {
                    // Profile picture
                    if let userProfile = authManager.userProfile, let image = userProfile.profilePic {
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 100, height: 100)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
                            )
                        // Greeting text
                        Text("Good evening,\n" + userProfile.username)
                            .font(.system(size: 28, weight: .medium))
                            .foregroundColor(.white)
                    } else {
//                        Image("Profile")
//                            .resizable()
//                            .aspectRatio(contentMode: .fill)
//                            .frame(width: 100, height: 100)
//                            .clipShape(RoundedRectangle(cornerRadius: 12))
//                            .overlay(
//                                RoundedRectangle(cornerRadius: 12)
//                                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
//                            )
                    }
                }
                .modifier(ShakeEffect(animatableData: viewModel.pinError ? 1 : 0))
                .frame(height: 190)
                
                Spacer().frame(height: 50)
                
                // PIN Dots
                HStack(spacing: 16) {
                    ForEach(0..<6, id: \.self) { index in
                        PINEntryDot(
                            isFilled: index < viewModel.pin.count,
                            error: viewModel.pinError
                        )
                    }
                }
                
                Spacer().frame(height: 50)
                
                // Number pad
                VStack(spacing: 12) {
                    // Row 1: 1, 2, 3
                    HStack(spacing: 16) {
                        NumberPadButton(number: "1") { viewModel.appendPin(digit: "1") }
                        NumberPadButton(number: "2") { viewModel.appendPin(digit: "2") }
                        NumberPadButton(number: "3") { viewModel.appendPin(digit: "3") }
                    }
                    
                    // Row 2: 4, 5, 6
                    HStack(spacing: 16) {
                        NumberPadButton(number: "4") { viewModel.appendPin(digit: "4") }
                        NumberPadButton(number: "5") { viewModel.appendPin(digit: "5") }
                        NumberPadButton(number: "6") { viewModel.appendPin(digit: "6") }
                    }
                    
                    // Row 3: 7, 8, 9
                    HStack(spacing: 16) {
                        NumberPadButton(number: "7") { viewModel.appendPin(digit: "7") }
                        NumberPadButton(number: "8") { viewModel.appendPin(digit: "8") }
                        NumberPadButton(number: "9") { viewModel.appendPin(digit: "9") }
                    }
                    
                    // Row 4: Face ID, 0, Delete
                    HStack(spacing: 16) {
                        // Face ID button
                        Button(action: { runBiometricAuthentication() }) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color(red: 0.08, green: 0.09, blue: 0.16)) // #141628
                                    .frame(width: 100, height: 60)
                                
                                Image(systemName: "faceid")
                                    .font(.system(size: 24))
                                    .foregroundColor(.white)
                            }
                        }
                        .buttonStyle(ScaleButtonStyle())
                        
                        NumberPadButton(number: "0") { viewModel.appendPin(digit: "0") }
                        
                        // Delete button
                        Button(action: { 
                            viewModel.deleteLastDigit()
                        }) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color(red: 0.08, green: 0.09, blue: 0.16)) // #141628
                                    .frame(width: 100, height: 60)
                                
                                Image(systemName: "delete.left")
                                    .font(.system(size: 24))
                                    .foregroundColor(.white)
                            }
                        }
                        .buttonStyle(ScaleButtonStyle())
                    }
                }
                .padding(.bottom, 10)
                
                // Forgot passcode link
                Button("Forgot your passcode?") {
                    // TODO: Implement Firebase forgot password functionality
                    // This should integrate with Firebase Auth to send password reset email
                    // Handle forgot passcode
                }
                .font(.system(size: 16, weight: .regular))
                .foregroundColor(.white)
                .padding(.bottom, 40)
            }
        }
        .statusBarHidden(true)
        .onAppear {
            // Clear any existing PIN when entering this view
            viewModel.clearPin()
            
            if !biometricAttempted {
                biometricAttempted = true
                runBiometricAuthentication()
            }
        }
    }
    
    /// Automatically trigger biometric authentication
    private func runBiometricAuthentication() {
        if BiometricAuthManager.shared.canUseBiometricAuthentication() {
            BiometricAuthManager.shared.authenticateWithBiometrics { success, error in
                if success {
                    DispatchQueue.main.async {
                        viewModel.biometricVerified = true
                        viewModel.authenticated = true
                    }
                } else {
                    print("Biometric authentication failed: \(error?.localizedDescription ?? "Unknown error")")
                }
            }
        } else {
            print("Biometric authentication not available.")
        }
    }
}

struct PINEntryDot: View {
    var isFilled: Bool
    var error: Bool
    
    var body: some View {
        Circle()
            .fill(isFilled ? Color.white : Color(red: 0.29, green: 0.29, blue: 0.29)) // #4A4A4A
            .frame(width: 12, height: 12)
            .scaleEffect(isFilled ? 1.0 : 1.0)
            .animation(.spring(response: 0.2), value: isFilled)
            .modifier(ShakeEffect(animatableData: error ? 1 : 0))
    }
}

struct NumberPadButton: View {
    let number: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(red: 0.08, green: 0.09, blue: 0.16)) // #141628
                    .frame(width: 100, height: 60)
                
                Text(number)
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.white)
            }
        }
        .buttonStyle(ScaleButtonStyle())
    }
}
