//
//  RoboCallerMoverApp.swift
//  RoboCallerMover
//
//  Created by Michelle Zheng  on 2/4/25.
//

import SwiftUI
import Supabase

@main
struct RoboCallerMoverApp: App {
    @State private var session: Session? = nil
    var body: some Scene {
        WindowGroup {
            if session == nil {
                LoginScreen(session: $session)
            } else {
                RootTabView(session: $session)
            }
        }
    }
}
