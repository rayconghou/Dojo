//
//  DegenSplashScreenView.swift
//  Dojo
//
//  Created by Raymond Hou on 3/25/25.
//

import Foundation
import SwiftUI

struct DegenSplashScreen: View {
    
    var body: some View {
        ZStack {
            // // Custom background color #050715
            // Color(hex: "050715")
            //     .edgesIgnoringSafeArea(.all)
            
            // DegenBackground asset overlay
            Image("DegenBackground")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 40) {
                // DOJO Logo and Text from SplashScreenBranding asset
                Image("SplashScreenBranding")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 250, height: 250)
                
            }
            .padding(.vertical, 50)
        }
        .onAppear {
            // No animations - just show immediately
        }
    } 
}
