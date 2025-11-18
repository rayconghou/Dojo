//
//  ConfirmPINView.swift
//  Dojo
//
//  Created by Raymond Hou on 3/31/25.
//

import Foundation
import SwiftUI
import LocalAuthentication

struct ConfirmPINView: View {
    @ObservedObject var viewModel: SecureSignInFlowViewModel
    @State private var biometricAttempted = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Dark background with NormalSplashBackground
                Color(red: 0.02, green: 0.03, blue: 0.08) // #050715
                    .ignoresSafeArea()
                
                // NormalSplashBackground asset
                Image("NormalSplashBackground")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    Spacer()
                    
                    // Profile picture at the top center
                    Image("Profile")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 100, height: 100)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.white.opacity(0.2), lineWidth: 1)
                        )
                    
                    // Title text
                    Text("Confirm Your PIN")
                        .font(.custom("Satoshi-Bold", size: 24))
                        .foregroundColor(.white)
                        .padding(.top, 20)
                    
                    Text("Enter your 6-digit PIN again to confirm")
                        .font(.custom("Satoshi-Bold", size: 16))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                        .padding(.top, 8)
                    
                    Spacer().frame(height: 40)
                    
                    // PIN Dots
                    HStack(spacing: 16) {
                        ForEach(0..<6, id: \.self) { index in
                            PINEntryDot(
                                isFilled: index < viewModel.confirmPin.count,
                                error: viewModel.pinError
                            )
                        }
                    }
                    
                    Spacer().frame(height: 40)
                    
                    numberPad
                        .padding(.bottom, 40)
        }
        .padding()
        .statusBarHidden(true)
        .onAppear {
            // Clear confirmPin when entering this view, but keep the original pin
            viewModel.confirmPin = ""
            viewModel.pinError = false
            
            if !biometricAttempted {
                biometricAttempted = true
                runBiometricAuthentication()
            }
        }
    }
        }
    }
    
    /// Automatically trigger biometric authentication
        private func runBiometricAuthentication() {
        if BiometricAuthManager.shared.canUseBiometricAuthentication() {
            BiometricAuthManager.shared.authenticateWithBiometrics { success, error in
                if success {
                    DispatchQueue.main.async {
                        // You may want to mark biometric as verified in your view model.
                        viewModel.biometricVerified = true
                        // Since biometric confirms the identity, you could automatically
                        // move to the next step in your onboarding flow.
                        viewModel.authenticated = true
                    }
                } else {
                    // Optionally you can alert the user or simply log the error.
                    print("Biometric authentication failed: \(error?.localizedDescription ?? "Unknown error")")
                }
            }
        } else {
            print("Biometric authentication not available.")
        }
    }
    
    var numberPad: some View {
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
                       Button(action: {
                           // Handle Face ID authentication
                       }) {
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
    }
}
