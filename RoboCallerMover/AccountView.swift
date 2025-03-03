//
//  AccountView.swift
//  RoboCallerMover
//
//  Created by Michelle Zheng  on 2/26/25.
//

import SwiftUI
import Supabase

struct AccountView: View {
    @Binding var session: Session?
    @State private var error: Error?
    @AppStorage("authSession") private var authSession: String?

    var body: some View {
        VStack {
            if session != nil {
                ProfileView(session: $session) //ProfileView receives the correct binding
            } else {
                LoginScreen(session: $session)
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

    /// Load session from storage or Supabase
    private func loadSession() async {
        do {
            print("Starting session load")

            guard let storedSession = loadStoredSession() else {
                print("No valid stored session found, directing to login screen")
                self.session = nil
                return
            }

            print("Found stored session data")
            print("Decoded user ID: \(storedSession.user.id)")
            print("Expires at: \(Date(timeIntervalSince1970: storedSession.expiresAt))")

            if Date(timeIntervalSince1970: storedSession.expiresAt) < Date() {
                print("Session expired, attempting refresh...")

                do {
                    let refreshedSession = try await supabase.auth.refreshSession()
                    print("Session refreshed: \(refreshedSession.user.id)")
                    saveSession(refreshedSession)
                    self.session = refreshedSession
                    return
                } catch {
                    print("Failed to refresh session: \(error)")
                    self.authSession = nil
                    self.session = nil
                    return
                }
            }

            try await supabase.auth.setSession(
                accessToken: storedSession.accessToken,
                refreshToken: storedSession.refreshToken
            )

            let currentSession = try await supabase.auth.session
            print("Session restored - Client session: \(currentSession.user.id)")

            saveSession(currentSession)
            self.session = currentSession

        } catch {
            print("Session error: \(error)")
            self.authSession = nil
            self.session = nil
            self.error = error
        }
    }

    /// Save session data to AppStorage
    private func saveSession(_ session: Session) {
        do {
            let encodedData = try JSONEncoder().encode(session)
            authSession = String(data: encodedData, encoding: .utf8)
        } catch {
            print("Failed to encode session: \(error)")
        }
    }

    /// Load stored session data from AppStorage
    private func loadStoredSession() -> Session? {
        guard let authSession = authSession,
              let data = authSession.data(using: .utf8) else { return nil }

        do {
            return try JSONDecoder().decode(Session.self, from: data)
        } catch {
            print("Failed to decode stored session: \(error)")
            return nil
        }
    }
}
