//
//  AccountView.swift
//  RoboCallerMover
//
//  Created by Michelle Zheng  on 2/26/25.
//


import SwiftUI
import Supabase

struct AccountView: View {
    // We'll store the session as a state variable
    @State private var session: Session? = nil
    @State private var error: Error?

    var body: some View {
        Group {
            // If session is present, show ProfileView; else show Login
            if let _ = session {
                ProfileView()
            } else {
                LoginScreen()
            }
        }
        .task {
            await loadSession()
        }
        .alert("Error", isPresented: Binding<Bool>(
            get: { error != nil },
            set: { if !$0 { error = nil } }
        )) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(error?.localizedDescription ?? "Unknown error")
        }
    }

    // Because supabase.auth.session is async/throws, we call it here
    private func loadSession() async {
        do {
            // Get the current session
            let currentSession = try await supabase.auth.session
            // If successful, store it in state
            self.session = currentSession
        } catch {
            // If it fails, store the error
            self.error = error
        }
    }
}
