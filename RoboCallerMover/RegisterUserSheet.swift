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
    @Binding var session: Session?
    @State private var newEmail: String = ""
    @State private var newPassword: String = ""
    @State private var fullName: String = ""
    @State private var isLoading: Bool = false
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            Form {
                Section("Create Account") {
                    TextField("Full Name", text: $fullName)
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

                Section {
                    if isLoading {
                        ProgressView()
                    } else {
                        Button("Register") {
                            Task { await handleRegister() }
                        }
                    }
                }
            }
            .navigationTitle("Register")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }
            }
        }
    }

    private func handleRegister() async {
        do {
            let cleanEmail = newEmail.trimmingCharacters(in: .whitespaces)
            let cleanPassword = newPassword.trimmingCharacters(in: .whitespaces)
            let cleanName = fullName.trimmingCharacters(in: .whitespaces)

            // Registration logic remains the same
            let authResponse = try await supabase.auth.signUp(
                email: cleanEmail,
                password: cleanPassword
            )

            let user = authResponse.user
            
            let newProfile = ProfileInsert(
                user_id: user.id,
                email: cleanEmail,
                full_name: cleanName
            )

            try await supabase
                .from("profiles")
                .insert(newProfile)
                .execute()

            if let currentSession = authResponse.session {
                await MainActor.run {
                    self.session = currentSession
                    isPresented = false
                }
            }
            
        } catch {
            await MainActor.run {
                errorMessage = "Registration failed: \(error.localizedDescription)"
            }
        }
    }
}
