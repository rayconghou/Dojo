//
//  SecureSignInFlowView.swift
//  Dojo
//
//  Created by Raymond Hou on 4/13/25.
//

import Foundation
import SwiftUI

struct SecureSignInFlowView: View {
    @EnvironmentObject var securityViewModel: SecureSignInFlowViewModel
    
    @State private var userProfile : UserProfileViewModel
    
    init (userProfile: UserProfileViewModel) {
        self.userProfile = userProfile
    }

    var body: some View {
        NavigationStack {
            if !securityViewModel.authenticated {
                onboardingFlow
            } else {
                HomePageView(userProfile: userProfile)
            }
        }
    }

    @ViewBuilder
    private var onboardingFlow: some View {
        switch securityViewModel.currentStep {
        case .createPin:
            CreatePINView(viewModel: securityViewModel)
        case .confirmPin:
            ConfirmPINView(viewModel: securityViewModel)
        case .setupComplete:
            SetupCompleteView(viewModel: securityViewModel)
        }
    }
}

//
//  SecureSignInModel.swift
//  Dojo
//
//  Created by Raymond Hou on 4/13/25.
//

import Foundation
import SwiftUI
import LocalAuthentication
import Combine

class SecureSignInFlowViewModel: ObservableObject {
    // MARK: Onboarding / Authentication
    @Published var pin: String = ""
    @Published var confirmPin: String = ""
    @Published var showPin: Bool = false
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
        case setupComplete
    }
    
    init() {
        // Authentication checks
        if let storedPin = KeychainHelper.read(forKey: "userPin") {
            self.pin = storedPin
            self.currentStep = .confirmPin
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
                    validatePins()
                }
            }
        default:
            break
        }
    }
    
    func deleteLastDigit() {
        switch currentStep {
        case .createPin:
            if !pin.isEmpty {
                pin.removeLast()
            }
        case .confirmPin:
            if !confirmPin.isEmpty {
                confirmPin.removeLast()
            }
        default:
            break
        }
    }
    
    private func validatePins() {
        if pin == confirmPin {
            KeychainHelper.save(pin, forKey: "userPin")
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation(.spring(response: 0.3)) {
                    self.authenticated = true
                    self.currentStep = .setupComplete
                }
            }
        } else {
            // mismatch => shake dots
            withAnimation(.spring(response: 0.3)) {
                pinError = true
            }
            confirmPin = ""
            
            // Reset error state after a short delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                withAnimation {
                    self.pinError = false
                }
            }
        }
    }
    
    // MARK: Biometric Flow
    func startBiometricSetup() {
        withAnimation {
            isScanningFace = true
        }

        // Simulate face scanning
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.biometricEnabled = true
            withAnimation {
                self.isScanningFace = false
            }

            if let storedPin = KeychainHelper.read(forKey: "userPin") {
                self.authenticated = true
            } else {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    withAnimation(.spring(response: 0.3)) {
                        self.currentStep = .setupComplete
                    }
                }
            }
        }
    }
    
    func completeSetup() {
        // The user has completely set up their wallet
        withAnimation(.spring(response: 0.3)) {
            self.authenticated = true
        }
    }
}

// MARK: - KeychainHelper

struct KeychainHelper {
    
    static func save(_ value: String, forKey key: String) {
        if let data = value.data(using: .utf8) {
            let query: [String: Any] = [
                kSecClass as String: kSecClassGenericPassword,
                kSecAttrAccount as String: key,
                kSecValueData as String: data
            ]
            
            // Delete any existing entry
            SecItemDelete(query as CFDictionary)
            
            // Add new entry
            SecItemAdd(query as CFDictionary, nil)
        }
    }
    
    static func read(forKey key: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        if status == errSecSuccess, let data = result as? Data, let string = String(data: data, encoding: .utf8) {
            return string
        }
        
        return nil
    }
    
    static func delete(forKey key: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ]
        
        SecItemDelete(query as CFDictionary)
    }
}
