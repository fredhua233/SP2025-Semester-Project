//
//  LoginScreen.swift
//  RoboCallerMover
//
//  Created by Michelle Zheng on 2/25/25.
//

import SwiftUI
import Supabase

struct LoginScreen: View {
    @State private var email: String = ""
    @State private var password: String = ""

    @State private var isLoading: Bool = false
    @State private var result: Result<Void, Error>?

    // For registration sheet
    @State private var showRegisterSheet: Bool = false

    var body: some View {
        Form {
            Section {
                TextField("Email", text: $email)
                    .textContentType(.emailAddress)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()

                SecureField("Password", text: $password)
                    .textContentType(.password)
                    .autocorrectionDisabled()
            }

            Section {
                Button("Sign in") {
                    signInButtonTapped()
                }
                .disabled(isLoading)

                if isLoading {
                    ProgressView()
                }

                // "New user?" button
                Button("Register New User") {
                    showRegisterSheet = true
                }
            }

            if let result {
                Section {
                    switch result {
                    case .success:
                        Text("Signed in successfully!")
                    case .failure(let error):
                        Text(error.localizedDescription)
                            .foregroundColor(.red)
                    }
                }
            }
        }
        .sheet(isPresented: $showRegisterSheet) {
            RegisterUserSheet(isPresented: $showRegisterSheet)
        }
    }

    func signInButtonTapped() {
        Task {
            isLoading = true
            defer { isLoading = false }
            do {
                // If older supabase-swift:
                try await supabase.auth.signIn(email: email, password: password)

                // If newer supabase-swift (0.6+):
                // try await supabase.auth.signInWithPassword(
                //   credentials: AuthCredentialsEmailPassword(email: email, password: password)
                // )

                result = .success(())
            } catch {
                result = .failure(error)
            }
        }
    }
}

// MARK: - Registration Sheet
struct RegisterUserSheet: View {
    @Binding var isPresented: Bool

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
                        registerNewUser()
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

    func registerNewUser() {
        Task {
            isLoading = true
            defer { isLoading = false }

            do {
                // If older supabase-swift:
                try await supabase.auth.signUp(email: newEmail, password: newPassword)

                // If newer supabase-swift (0.6+):
                // try await supabase.auth.signUp(
                //   credentials: AuthCredentialsEmailPassword(email: newEmail, password: newPassword)
                // )

                // If success, dismiss sheet
                isPresented = false
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }
}

struct LoginScreen_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            LoginScreen()
        }
    }
}
