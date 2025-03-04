//
//  LoginScreen.swift
//  RoboCallerMover
//
//  Created by Michelle Zheng on 2/25/25.
//

import SwiftUI
import Supabase


struct LoginScreen: View {
    @Binding var session: Session?
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var isLoading: Bool = false
    @State private var errorMessage: String?
    @State private var showingRegisterSheet = false

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Email", text: $email)
                        .textContentType(.emailAddress)
                        .autocapitalization(.none)
                    SecureField("Password", text: $password)
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
                        Button("Sign In") {
                            Task { await signIn() }
                        }
                        
                        Button("Create Account") {
                            showingRegisterSheet.toggle()
                        }
                    }
                }
            }
            .navigationTitle("Login")
            .sheet(isPresented: $showingRegisterSheet) {
                RegisterUserSheet(isPresented: $showingRegisterSheet, session: $session)
            }
            .navigationDestination(isPresented: Binding(get: { session != nil }, set: { _ in })) {
                RootTabView(session: $session)
            }
        }
    }

    private func signIn() async {
        isLoading = true
        errorMessage = nil

        do {
            let currentSession = try await supabase.auth.signIn(email: email, password: password)
            session = currentSession
        } catch {
            errorMessage = "Login failed: \(error.localizedDescription)"
        }

        isLoading = false
    }
}

struct LoginScreen_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            LoginScreen(session: .constant(nil)) // Provide a mock Binding<Session?>
        }
    }
}
