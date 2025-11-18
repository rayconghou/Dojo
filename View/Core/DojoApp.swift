//
//  DojoApp.swift
//  Dojo
//
//  Created by Raymond Hou on 2/28/25.
//

import SwiftUI
import FirebaseCore

struct Constants {
    static let typing_wait_time = 0.5
}

@main
struct DojoApp: App {
    @ObservedObject var authManager: AuthManager
    
    init() {
        FirebaseApp.configure()
        
        authManager = AuthManager.shared
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
