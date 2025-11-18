//
//  CreatePINView.swift
//  Dojo
//
//  Created by Raymond Hou on 3/31/25.
//

import Foundation
import SwiftUI

struct CreatePINView: View {
    @ObservedObject var viewModel: SecureSignInFlowViewModel
    
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
                    Text("Create Your PIN")
                        .font(.custom("Satoshi-Bold", size: 24))
                        .foregroundColor(.white)
                        .padding(.top, 20)
                    
                    Text("Choose a secure 6-digit PIN to protect your assets")
                        .font(.custom("Satoshi-Bold", size: 16))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                        .padding(.top, 8)
                
                Spacer().frame(height: 40)
                
                // PIN Dots
                HStack(spacing: 16) {
                    ForEach(0..<6, id: \.self) { index in
                        PINEntryDot(isFilled: index < viewModel.pin.count, error: false)
                    }
                }
                
                Spacer().frame(height: 40)
                
                numberPad
                    .padding(.bottom, 40)
        }
        .padding()
        .statusBarHidden(true)
        .onAppear {
            // TEMP: Just went against this: "Clear any existing PIN when entering this view"
//            viewModel.clearPin()
        }
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

