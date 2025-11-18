//
//  SecureSignInFlowViewModel.swift
//  Dojo
//
//  Created by Raymond Hou on 4/13/25.
//

import Foundation
import SwiftUI
import Combine
import Security

class SecureSignInFlowViewModel: ObservableObject {
    // MARK: Onboarding / Authentication
    @Published var pin: String = ""
    @Published var confirmPin: String = ""
    @Published var biometricEnabled: Bool = false
    
    @Published var pinVerified: Bool = false
    @Published var biometricVerified: Bool = false
    
    // If user wants to re-lock and re-ask for Face ID each time, you can use this:
    @Published var authenticated: Bool = false
    
    @Published var pinError: Bool = false
    @Published var isScanningFace: Bool = false
    
    // For demonstration, we show which step of the onboarding
    @Published var currentStep: OnboardingStep = .createPin
    
    // Cancellables for API requests
    private var cancellables = Set<AnyCancellable>()
    
    enum OnboardingStep {
        case createPin
        case confirmPin
        case pinEntry
        case setupComplete
    }
    
    init() {
        // Authentication checks
        if let storedPin = KeychainHelper.read(forKey: "userPin") {
            self.pin = storedPin
            self.currentStep = .pinEntry
        } else {
            self.currentStep = .createPin
        }
    }

    // MARK: PIN Flow
    func appendPin(digit: String) {
        switch currentStep {
        case .createPin:
            if pin.count < 6 {
                pin += digit
                if pin.count == 6 {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        withAnimation(.spring(response: 0.3)) {
                            self.currentStep = .confirmPin
                        }
                    }
                }
            }
        case .confirmPin:
            if confirmPin.count < 6 {
                confirmPin += digit
                if confirmPin.count == 6 {
                    if pin == confirmPin {
                        // Save PIN to Keychain
                        KeychainHelper.save(pin, forKey: "userPin")
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            withAnimation(.spring(response: 0.3)) {
                                self.currentStep = .setupComplete
                            }
                        }
                    } else {
                        // PINs don't match, reset
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            withAnimation(.spring(response: 0.3)) {
                                self.pin = ""
                                self.confirmPin = ""
                                self.currentStep = .createPin
                            }
                        }
                    }
                }
            }
        case .pinEntry:
            if pin.count < 6 {
                pin += digit
                if pin.count == 6 {
                    // Verify PIN
                    if let storedPin = KeychainHelper.read(forKey: "userPin"), pin == storedPin {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            withAnimation(.spring(response: 0.3)) {
                                self.authenticated = true
                            }
                        }
                    } else {
                        // Wrong PIN
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            withAnimation(.spring(response: 0.3)) {
                                self.pin = ""
                                self.pinError = true
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                                    self.pinError = false
                                }
                            }
                        }
                    }
                }
            }
        case .setupComplete:
            break
        }
    }
    
    func deletePin() {
        switch currentStep {
        case .createPin:
            if !pin.isEmpty {
                pin.removeLast()
            }
        case .confirmPin:
            if !confirmPin.isEmpty {
                confirmPin.removeLast()
            }
        case .pinEntry:
            if !pin.isEmpty {
                pin.removeLast()
            }
        case .setupComplete:
            break
        }
    }
    
    // MARK: Biometric Authentication
    func authenticateWithBiometrics() {
        isScanningFace = true
        
        // Simulate biometric authentication
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.isScanningFace = false
            // For demo purposes, always succeed
            self.authenticated = true
        }
    }
    
    // MARK: Sign Out
    func signOut() {
        authenticated = false
        currentStep = .pinEntry
        pin = ""
        confirmPin = ""
    }
}

