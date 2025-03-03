//
//  RegisterUserSheet.swift
//  RoboCallerMover
//
//  Created by Michelle Zheng on 3/2/25.
//

import Foundation
import SwiftUI
import Supabase

struct RegisterUserSheet: View {
    @Binding var isPresented: Bool
    @Binding var session: Session? // Add this binding for session
    
    @State private var newEmail: String = ""
    @State private var newPassword: String = ""
    @State private var isLoading: Bool = false
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            Form {
                Section("Create New Account") {
                    TextField("Email", text: $newEmail)
                        .textContentType(.emailAddress)
                        .autocapitalization(.none)
                    SecureField("Password", text: $newPassword)
                        .textContentType(.password)
                }

                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                }

                if isLoading {
                    ProgressView()
                } else {
                    Button("Register") {
                        Task(priority: .background) {
                            await handleRegister()
                        }
                    }
                }
            }
            .navigationTitle("Register")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        isPresented = false // Dismiss the sheet
                    }
                }
            }
        }
    }

    /// Async function to handle user registration
    private func handleRegister() async {
        do {
            let cleanEmail = newEmail.trimmingCharacters(in: .whitespaces)
            let cleanPassword = newPassword.trimmingCharacters(in: .whitespaces)

            // Debugging: Check if Supabase is accessible
            print("Supabase client:", supabase)

            // 1. Sign up the user
            let result = try await supabase.auth.signUp(
                email: cleanEmail,
                password: cleanPassword
            )
            print("Sign up result:", result)

            // 2. Retrieve the current session
            let currentSession = try await supabase.auth.session
            print("🔑 Current session:", currentSession)

            // 3. Attempt profile creation as a fallback
            let newProfile = ProfileInsert(
                user_id: currentSession.user.id,
                email: cleanEmail
            )

            try await supabase
                .from("profiles")
                .insert(newProfile) // Now we are passing a properly Encodable struct
                .execute()
            print("Profile inserted for user:", currentSession.user.id)

            // 4. Update session state and dismiss the sheet
            await MainActor.run {
                self.session = currentSession
                isPresented = false
            }

        } catch {
            await MainActor.run {
                errorMessage = "Registration failed: \(error.localizedDescription)"
            }
        }
    }
}

