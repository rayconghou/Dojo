//
//  DojoApp.swift
//  Dojo
//
//  Created by Raymond Hou on 2/28/25.
//

import SwiftUI
import FirebaseCore
import CoreText

struct Constants {
    static let typing_wait_time = 0.5
}

@main
struct DojoApp: App {
    @ObservedObject var authManager: AuthManager
    
    init() {
        FirebaseApp.configure()
        registerCustomFonts()
    }
    
    private func registerCustomFonts() {
        // Register The Last Shuriken font
        if let fontURL = Bundle.main.url(forResource: "The Last Shuriken", withExtension: "ttf") {
            CTFontManagerRegisterFontsForURL(fontURL as CFURL, .process, nil)
        }
        
        // Register Korosu font
        if let fontURL = Bundle.main.url(forResource: "Korosu", withExtension: "ttf") {
            CTFontManagerRegisterFontsForURL(fontURL as CFURL, .process, nil)
        }
        
        // Register Satoshi fonts - all variants we're using
        let satoshiFonts = [
            "Satoshi-Black", "Satoshi-BlackItalic", 
            "Satoshi-Bold", "Satoshi-BoldItalic",
            "Satoshi-Medium", "Satoshi-MediumItalic",
            "Satoshi-Regular", "Satoshi-Italic",
            "Satoshi-Light", "Satoshi-LightItalic"
        ]
        for fontName in satoshiFonts {
            if let fontURL = Bundle.main.url(forResource: fontName, withExtension: "ttf") {
                CTFontManagerRegisterFontsForURL(fontURL as CFURL, .process, nil)
            }
        }
    }
    var body: some Scene {
        WindowGroup {
            if authManager.isLoggedIn {
                ContentView()
            } else {
                AuthView()
            }
        }
    }
}

// MARK: - Preview
struct DojoApp_Previews: PreviewProvider {
    static var previews: some View {
        if AuthManager.shared.isLoggedIn {
            ContentView()
//            TEMP:
                .preferredColorScheme(.dark)
        } else {
            AuthView()
        }
    }
}
