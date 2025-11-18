//
//  DegenHeaderBar.swift
//  Dojo
//
//  Created by Raymond Hou on 3/25/25.
//

import SwiftUI

struct DegenHeaderBar: View {
    @State private var showSidebar = false
    
    var body: some View {
        HStack {
            Spacer()
            
            HStack(spacing: 12) {
                // Profile Picture
                Image("Profile")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 50, height: 50)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color(hex: "4F2FB6"), Color(hex: "F7B0FE")]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1.5
                            )
                    )
                    .shadow(color: Color(hex: "4F2FB6").opacity(0.3), radius: 4, x: 0, y: 2)
                
                // Level Badge - Compact 50px height, jam-packed
                VStack(alignment: .leading, spacing: 1) {
                    // Text row - LVL, 7, and progress numbers
                    HStack(spacing: 2) {
                        Text("LVL")
                            .font(.custom("Satoshi-Bold", size: 10))
                            .foregroundColor(.white)
                            .lineLimit(1)
                        
                        Text("7")
                            .font(.custom("The Last Shuriken", size: 18))
                            .foregroundColor(.white)
                            .lineLimit(1)
                        
                        Spacer()
                        
                        HStack(spacing: 1) {
                            Text("23")
                                .font(.custom("Satoshi-Medium", size: 12))
                                .foregroundColor(.white)
                                .lineLimit(1)
                                .padding(.bottom, 3) // Extra bottom padding for "23"
                            
                            Text("/")
                                .font(.custom("Satoshi-Medium", size: 10))
                                .foregroundColor(.white.opacity(0.6))
                                .lineLimit(1)
                            
                            Text("40")
                                .font(.custom("Satoshi-Medium", size: 10))
                                .foregroundColor(.white.opacity(0.8))
                                .lineLimit(1)
                        }
                        .padding(.bottom, 2) // Add padding below progress numbers
                    }
                    
                    // Progress Bar - Full width underneath text, thicker with glow
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            // Background track
                            RoundedRectangle(cornerRadius: 2)
                                .fill(Color.white.opacity(0.2))
                                .frame(height: 5)
                            
                            // Progress fill with glow
                            RoundedRectangle(cornerRadius: 2)
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: [Color(hex: "4F2FB6"), Color(hex: "F7B0FE")]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(width: geometry.size.width * 0.575, height: 5) // 23/40 = 0.575
                                .shadow(color: Color(hex: "4F2FB6").opacity(0.6), radius: 3, x: 0, y: 0)
                                .shadow(color: Color(hex: "F7B0FE").opacity(0.4), radius: 2, x: 0, y: 0)
                        }
                    }
                    .frame(height: 5)
                }
                .frame(width: 80, height: 50) // Reduced width to match shorter progress bar
                .padding(.horizontal, 8)
                // .padding(.vertical, 4)
                .background(
                    RoundedRectangle(cornerRadius: 15) // 15px radius as per mockup
                        .fill(
                            LinearGradient(
                                gradient: Gradient(stops: [
                                    .init(color: Color(hex: "9943F6").opacity(0.05), location: 0.05),
                                    .init(color: Color(hex: "9943F6").opacity(0.25), location: 0.25)
                                ]),
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 15)
                                .stroke(
                                    LinearGradient(
                                        gradient: Gradient(colors: [Color(hex: "4F2FB6"), Color(hex: "F7B0FE")]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 2 // 2px border as per mockup
                                )
                        )
                )
                .shadow(color: Color(hex: "4F2FB6").opacity(0.2), radius: 4, x: 0, y: 2)
                
                // Portfolio Value Badge - Fixed 50px height, no wrapping
                HStack(spacing: 7) { // 7px gap as per mockup
                    // Dollar Icon with glow effect (same as wallet card)
                    ZStack {
                        // Glow effect
                        Circle()
                            .fill(Color(hex: "FFBE02"))
                            .frame(width: 28, height: 28)
                            .blur(radius: 4)
                            .opacity(0.6)
                        
                        // Main icon - yellow circle with white dollar sign
                        Circle()
                            .fill(Color(hex: "FFBE02"))
                            .frame(width: 24, height: 24)
                        
                        Text("$")
                            .font(.custom("Satoshi-Bold", size: 12))
                            .foregroundColor(.white)
                            .lineLimit(1)
                    }
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Portfolio Value")
                            .font(.custom("Satoshi-Medium", size: 10))
                            .foregroundColor(.white.opacity(0.8))
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)
                        
                        // Dynamic text sizing for portfolio value
                        Text("4,237.36")
                            .font(.custom("The Last Shuriken", size: 16))
                            .foregroundColor(.white)
                            .lineLimit(1)
                            .minimumScaleFactor(0.3)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .frame(width: 100, height: 50) // Fixed 50px height
                .padding(.horizontal, 16) // 16px left and right padding as per mockup
                .background(
                    RoundedRectangle(cornerRadius: 15) // 15px radius as per mockup
                        .fill(
                            LinearGradient(
                                gradient: Gradient(stops: [
                                    .init(color: Color(hex: "FFBE02").opacity(0.05), location: 0.05),
                                    .init(color: Color(hex: "FFBE02").opacity(0.20), location: 0.20)
                                ]),
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 15)
                                .stroke(
                                    LinearGradient(
                                        gradient: Gradient(colors: [Color(hex: "F3BA2F"), Color(hex: "F7CC5C")]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 2 // 2px border as per mockup
                                )
                        )
                )
                .shadow(color: Color(hex: "F3BA2F").opacity(0.2), radius: 4, x: 0, y: 2)
                
                // Menu Button - Increased size
                Button(action: {
                    showSidebar = true
                }) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 15) // 15px radius as per mockup
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(stops: [
                                        .init(color: Color(hex: "9943F6").opacity(0.05), location: 0.05),
                                        .init(color: Color(hex: "9943F6").opacity(0.50), location: 0.50)
                                    ]),
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 15)
                                    .stroke(
                                        LinearGradient(
                                            gradient: Gradient(colors: [Color(hex: "4F2FB6"), Color(hex: "F7B0FE")]),
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        lineWidth: 2 // 2px border as per mockup
                                    )
                            )
                            .frame(width: 50, height: 50) // Exact 50x50px dimensions as per mockup
                        
                        Image(systemName: "line.3.horizontal")
                            .font(.system(size: 20, weight: .medium)) // Increased icon size from 16 to 20
                            .foregroundColor(.white)
                            .lineLimit(1)
                    }
                }
                .shadow(color: Color(hex: "4F2FB6").opacity(0.2), radius: 4, x: 0, y: 2)
            }
            
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color(hex: "0E061C"))
    }
}

#Preview {
    DegenHeaderBar()
        .background(Color.black)
}
