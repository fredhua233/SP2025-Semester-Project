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
                        .disabled(isLocked)
                        
                        Button("Create Account") {
                            showingRegisterSheet.toggle()
                        }
                    }
                }
                
                Section {
                    Button("Forgot Password?") {
                        showingResetSheet.toggle()
                    }
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


////
////  LoginScreen.swift
////  RoboCallerMover
////
////  Created by Michelle Zheng on 2/25/25.
////
//
//import SwiftUI
//import Supabase
//
//
//struct LoginScreen: View {
//    @Binding var session: Session?
//    @State private var email: String = ""
//    @State private var password: String = ""
//    @State private var isLoading: Bool = false
//    @State private var errorMessage: String?
//    @State private var showingRegisterSheet = false
//
//    var body: some View {
//        NavigationStack {
//            Form {
//                Section {
//                    TextField("Email", text: $email)
//                        .textContentType(.emailAddress)
//                        .autocapitalization(.none)
//                    SecureField("Password", text: $password)
//                        .textContentType(.password)
//                }
//
//                if let errorMessage = errorMessage {
//                    Text(errorMessage)
//                        .foregroundColor(.red)
//                }
//
//                Section {
//                    if isLoading {
//                        ProgressView()
//                    } else {
//                        Button("Sign In") {
//                            Task { await signIn() }
//                        }
//                        
//                        Button("Create Account") {
//                            showingRegisterSheet.toggle()
//                        }
//                    }
//                }
//            }
//            .navigationTitle("Login")
//            .sheet(isPresented: $showingRegisterSheet) {
//                RegisterUserSheet(isPresented: $showingRegisterSheet, session: $session)
//            }
//            .navigationDestination(isPresented: Binding(get: { session != nil }, set: { _ in })) {
//                RootTabView(session: $session)
//            }
//        }
//    }
//
//    private func signIn() async {
//        isLoading = true
//        errorMessage = nil
//
//        do {
//            let currentSession = try await supabase.auth.signIn(email: email, password: password)
//            session = currentSession
//        } catch {
//            errorMessage = "Login failed: \(error.localizedDescription)"
//        }
//
//        isLoading = false
//    }
//}
//
//struct LoginScreen_Previews: PreviewProvider {
//    static var previews: some View {
//        NavigationStack {
//            LoginScreen(session: .constant(nil)) // Provide a mock Binding<Session?>
//        }
//    }
//}
