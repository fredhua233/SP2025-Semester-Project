//
//  LoginScreen.swift
//  RoboCallerMover
//
//  Created by Michelle Zheng on 2/25/25.
//

import SwiftUI
import Supabase
import CryptoKit

struct LoginScreen: View {
    
    @Binding var session: Session?
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var isLoading: Bool = false
    @State private var errorMessage: String?
    @State private var showingRegisterSheet = false
    @State private var showingResetSheet = false
    @State private var securityQuestion: String = ""
    @State private var securityAnswer: String = ""
    @State private var newPassword: String = ""
    
    // Rate limiting state
    @State private var failedAttempts = 0
    @State private var lastFailedAttempt = Date.distantPast
    @State private var isLocked = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color("background").ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 10) {
                        Image("movingLogo")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 200)

                        Group {
                            TextField("Email", text: $email)
                                .textContentType(.emailAddress)
                                .autocapitalization(.none)
                                .padding()
                                .background(Color.white)
                                .cornerRadius(10)

                            SecureField("Password", text: $password)
                                .textContentType(.password)
                                .padding()
                                .background(Color.white)
                                .cornerRadius(10)
                        }

                        if let errorMessage = errorMessage {
                            Text(errorMessage)
                                .foregroundColor(.red)
                        }

                        if isLoading {
                            ProgressView()
                        } else {
                            Button("Sign In                   ") {
                                Task { await signIn() }
                            }
                            .padding(.horizontal, 32)
                            .padding(.vertical, 7)
                            .cornerRadius(10)
                            .foregroundColor(Color.black)

                            Button("  Create Account  ") {
                                showingRegisterSheet.toggle()
                            }
                            .padding(.horizontal, 32)
                            .padding(.vertical, 7)
                            .cornerRadius(10)
                            .foregroundColor(.black)
                            

                            Button("Forgot Password?") {
                                showingResetSheet.toggle()
                            }
                            .padding(.horizontal, 32)
                            .padding(.vertical, 7)
                            .cornerRadius(10)
                            .foregroundColor(.black)


                        }

                        Spacer()
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 40)
                }
            }
            .navigationTitle("Login")
            .sheet(isPresented: $showingResetSheet) {
                passwordResetSheet
            }
            .sheet(isPresented: $showingRegisterSheet) {
                RegisterUserSheet(isPresented: $showingRegisterSheet, session: $session)
            }
            .navigationDestination(isPresented: Binding(get: { session != nil }, set: { _ in })) {
                RootTabView(session: $session)
            }
        }
    }


    private var passwordResetSheet: some View {
        NavigationStack {
            Form {
                Section("Password Reset") {
                    TextField("Email", text: $email)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                    
                    if !securityQuestion.isEmpty {
                        Text("Security Question: \(securityQuestion)")
                        SecureField("Your Answer", text: $securityAnswer)
                            .textContentType(.password)
                            .disableAutocorrection(true)
                        SecureField("New Password", text: $newPassword)
                            .textContentType(.newPassword)
                    }
                }
                
                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                }
                
                Section {
                    Button(securityQuestion.isEmpty ? "Find Account" : "Reset Password") {
                        Task {
                            if securityQuestion.isEmpty {
                                await fetchSecurityQuestion()
                            } else {
                                await confirmReset()
                            }
                        }
                    }
                    .disabled(isLocked)
                }
            }
            .navigationTitle("Reset Password")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        resetResetSheet()
                    }
                }
            }
        }
    }

    private func signIn() async {
        guard !isLocked else {
            errorMessage = "Account locked. Try again in 5 minutes"
            return
        }
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            let currentSession = try await supabase.auth.signIn(
                email: email,
                password: password
            )
            session = currentSession
            resetRateLimit()
        } catch {
            handleAuthError(error)
        }
    }

    private func handleAuthError(_ error: Error) {
        failedAttempts += 1
        lastFailedAttempt = Date()
        
        if failedAttempts >= 5 {
            isLocked = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 300) {
                self.isLocked = false
                self.failedAttempts = 0
            }
            errorMessage = "Too many failed attempts. Account locked for 5 minutes"
        } else {
            errorMessage = "Login failed: \(error.localizedDescription)"
        }
    }

    private func resetRateLimit() {
        failedAttempts = 0
        lastFailedAttempt = .distantPast
    }

    private func fetchSecurityQuestion() async {
        do {
            let question = try await ClientManager.shared.getSecurityQuestion(email: email)
            await MainActor.run {
                securityQuestion = question
                errorMessage = nil
            }
        } catch {
            await MainActor.run {
                errorMessage = "Error fetching security question: \(error.localizedDescription)"
            }
        }
    }

    private func confirmReset() async {
        do {
            let isValid = try await ClientManager.shared.verifySecurityAnswer(
                email: email,
                answer: securityAnswer
            )
            
            guard isValid else {
                await MainActor.run { errorMessage = "Incorrect security answer" }
                return
            }
            
            try await ClientManager.shared.adminUpdatePassword(
                email: email,
                newPassword: newPassword
            )
            
            await MainActor.run {
                errorMessage = "Password reset successful!"
                showingResetSheet = false
                resetResetSheet()
            }
        } catch {
            await MainActor.run {
                errorMessage = "Password reset failed: \(error.localizedDescription)"
            }
        }
    }
    
    private func resetResetSheet() {
        securityQuestion = ""
        securityAnswer = ""
        newPassword = ""
        errorMessage = nil
    }
}

struct LoginScreen_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            LoginScreen(session: .constant(nil))
        }
    }
}
