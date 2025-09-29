//
//  DojoApp.swift
//  Dojo
//
//  Created by Raymond Hou on 2/28/25.
//

import SwiftUI
import FirebaseCore

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
