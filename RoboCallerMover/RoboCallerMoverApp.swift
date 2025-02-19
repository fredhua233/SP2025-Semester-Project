//
//  RoboCallerMoverApp.swift
//  RoboCallerMover
//
//  Created by Michelle Zheng  on 2/4/25.
//

import SwiftUI

@main
struct RoboCallerMoverApp: App {
    @StateObject private var authManager = AuthManager()

    var body: some Scene {
        WindowGroup {
            if authManager.isLoggedIn {
                RootTabView()
                    .environmentObject(authManager)
            } else {
                LoginScreen()
                    .environmentObject(authManager)
            }
        }
    }
}
