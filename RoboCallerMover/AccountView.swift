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
    
    // Session expiration buffer (5 minutes)
    private let sessionExpirationBuffer: TimeInterval = 300

    var body: some View {
        VStack {
            if session != nil {
                ProfileView(session: $session)
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

    // Load session from storage or Supabase with security checks
    private func loadSession() async {
        do {
            print("Starting secure session load")
            
            guard let storedSession = loadStoredSession() else {
                print("No valid stored session - directing to login")
                clearSession()
                return
            }

            print("Loaded stored session: \(storedSession.user.id)")

            if isSessionExpired(storedSession) {
                print("Session expired - attempting refresh...")
                try await handleSessionRefresh(storedSession)
            } else {
                print("Valid session found - restoring")
                try await restoreSession(storedSession)
            }

        } catch {
            print("Error loading session: \(error)")
            handleSessionError(error)
        }
    }

    
    // Check if session is expired with 5-minute buffer
    private func isSessionExpired(_ session: Session) -> Bool {
        let expirationWithBuffer = Date(timeIntervalSince1970: session.expiresAt - sessionExpirationBuffer)
        return Date() > expirationWithBuffer
    }
    
    // Attempt to refresh expired session
    private func handleSessionRefresh(_ oldSession: Session) async throws {
        do {
            let refreshedSession = try await supabase.auth.refreshSession()
            print("Session refreshed: \(refreshedSession.user.id)")
            saveSession(refreshedSession)
            self.session = refreshedSession
        } catch {
            print("Refresh failed - clearing credentials")
            clearSession()
            throw error
        }
    }
    
    // Restore valid session
    private func restoreSession(_ session: Session) async throws {
        try await supabase.auth.setSession(
            accessToken: session.accessToken,
            refreshToken: session.refreshToken
        )
        
        let currentSession = try await supabase.auth.session
        print("Session restored - User ID: \(currentSession.user.id)")
        saveSession(currentSession)
        self.session = currentSession
    }
    
    // Handle session errors securely
    private func handleSessionError(_ error: Error) {
        print("Session error: \(error.localizedDescription)")
        clearSession()
        self.error = error
    }
    
    // Clear all session data securely
    private func clearSession() {
        authSession = nil
        session = nil
        UserDefaults.standard.removeObject(forKey: "authSession")
    }

    // Save session data to secure storage
    private func saveSession(_ session: Session) {
        do {
            let encodedData = try JSONEncoder().encode(session)
            authSession = String(data: encodedData, encoding: .utf8)
            print("Session successfully saved: \(session.user.id)")
        } catch {
            print("Secure encoding failed: \(error)")
            clearSession()
        }
    }

    // Load stored session with validation
    private func loadStoredSession() -> Session? {
        guard let authSession = authSession,
              let data = authSession.data(using: .utf8) else {
            return nil
        }
        
        do {
            let session = try JSONDecoder().decode(Session.self, from: data)
            
            // Additional security validation
            guard !session.user.id.uuidString.isEmpty,
                  session.expiresAt > 0 else {
                print("Invalid session format")
                return nil
            }
            
            return session
        } catch {
            print("Session decoding failed: \(error)")
            return nil
        }
    }
}

////
////  AccountView.swift
////  RoboCallerMover
////
////  Created by Michelle Zheng  on 2/26/25.
////
//
//import SwiftUI
//import Supabase
//
//struct AccountView: View {
//    @Binding var session: Session?
//    @State private var error: Error?
//    @AppStorage("authSession") private var authSession: String?
//
//    var body: some View {
//        VStack {
//            if session != nil {
//                ProfileView(session: $session) //ProfileView receives the correct binding
//            } else {
//                LoginScreen(session: $session)
//            }
//        }
//        .task {
//            await loadSession()
//        }
//        .alert("Error", isPresented: Binding<Bool>(
//            get: { error != nil },
//            set: { if !$0 { error = nil } }
//        )) {
//            Button("OK", role: .cancel) { }
//        } message: {
//            Text(error?.localizedDescription ?? "Unknown error")
//        }
//    }
//
//    /// Load session from storage or Supabase
//    private func loadSession() async {
//        do {
//            print("Starting session load")
//
//            guard let storedSession = loadStoredSession() else {
//                print("No valid stored session found, directing to login screen")
//                self.session = nil
//                return
//            }
//
//            print("Found stored session data")
//            print("Decoded user ID: \(storedSession.user.id)")
//            print("Expires at: \(Date(timeIntervalSince1970: storedSession.expiresAt))")
//
//            if Date(timeIntervalSince1970: storedSession.expiresAt) < Date() {
//                print("Session expired, attempting refresh...")
//
//                do {
//                    let refreshedSession = try await supabase.auth.refreshSession()
//                    print("Session refreshed: \(refreshedSession.user.id)")
//                    saveSession(refreshedSession)
//                    self.session = refreshedSession
//                    return
//                } catch {
//                    print("Failed to refresh session: \(error)")
//                    self.authSession = nil
//                    self.session = nil
//                    return
//                }
//            }
//
//            try await supabase.auth.setSession(
//                accessToken: storedSession.accessToken,
//                refreshToken: storedSession.refreshToken
//            )
//
//            let currentSession = try await supabase.auth.session
//            print("Session restored - Client session: \(currentSession.user.id)")
//
//            saveSession(currentSession)
//            self.session = currentSession
//
//        } catch {
//            print("Session error: \(error)")
//            self.authSession = nil
//            self.session = nil
//            self.error = error
//        }
//    }
//
//    /// Save session data to AppStorage
//    private func saveSession(_ session: Session) {
//        do {
//            let encodedData = try JSONEncoder().encode(session)
//            authSession = String(data: encodedData, encoding: .utf8)
//        } catch {
//            print("Failed to encode session: \(error)")
//        }
//    }
//
//    /// Load stored session data from AppStorage
//    private func loadStoredSession() -> Session? {
//        guard let authSession = authSession,
//              let data = authSession.data(using: .utf8) else { return nil }
//
//        do {
//            return try JSONDecoder().decode(Session.self, from: data)
//        } catch {
//            print("Failed to decode stored session: \(error)")
//            return nil
//        }
//    }
//}
