//
//  RegisterUserSheet.swift
//  RoboCallerMover
//
//  Created by Michelle Zheng on 3/2/25.
//

import SwiftUI
import Supabase
import CryptoKit

struct RegisterUserSheet: View {
    @Binding var isPresented: Bool
    @Binding var session: Session?
    @State private var newEmail: String = ""
    @State private var newPassword: String = ""
    @State private var fullName: String = ""
    @State private var selectedQuestion: SecurityQuestion = .mothersMaiden
    @State private var securityAnswer: String = ""
    @State private var isLoading: Bool = false
    @State private var errorMessage: String?
    
    // Rate limiting state
    @State private var registrationAttempts = 0
    @State private var lastRegistrationAttempt = Date.distantPast
    private let maxAttempts = 3
    private let attemptWindow: TimeInterval = 300

    var body: some View {
        NavigationStack {
            Form {
                Section("Create Account") {
                    TextField("Full Name", text: $fullName)
                    TextField("Email", text: $newEmail)
                        .textContentType(.emailAddress)
                        .autocapitalization(.none)
                        .keyboardType(.emailAddress)
                    SecureField("Password", text: $newPassword)
                        .textContentType(.newPassword)
                        .autocapitalization(.none)
                }
                
                Section("Security Questions") {
                    Picker("Select a question", selection: $selectedQuestion) {
                        ForEach(SecurityQuestion.allCases) { question in
                            Text(question.rawValue).tag(question)
                        }
                    }
                    SecureField("Answer", text: $securityAnswer)
                        .textContentType(.password)
                        .disableAutocorrection(true)
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
                        .disabled(shouldDisableRegisterButton)
                    }
                }
                
                if registrationAttempts > 0 {
                    Section {
                        Text(attemptStatusMessage)
                            .foregroundColor(.secondary)
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

    private var shouldDisableRegisterButton: Bool {
        isLoading || registrationAttempts >= maxAttempts
    }
    
    private var attemptStatusMessage: String {
        if registrationAttempts >= maxAttempts {
            let remainingTime = Int(attemptWindow - Date().timeIntervalSince(lastRegistrationAttempt))
            return "Try again in \(max(remainingTime, 0)) seconds"
        }
        return "Attempts remaining: \(maxAttempts - registrationAttempts)"
    }

    private func handleRegister() async {
        guard validateRegistrationAttempt() else { return }
        
        do {
            isLoading = true
            defer { isLoading = false }
            
            try validateInputs()
            
            let authResponse = try await supabase.auth.signUp(
                email: newEmail.trimmingCharacters(in: .whitespaces),
                password: newPassword.trimmingCharacters(in: .whitespaces)
            )
            
            let user = authResponse.user
            
            try await createUserProfile(user: user)
            
            if let currentSession = authResponse.session {
                await MainActor.run {
                    self.session = currentSession
                    isPresented = false
                }
            }
            
        } catch {
            await handleRegistrationError(error)
        }
    }
    
    private func validateRegistrationAttempt() -> Bool {
        let timeSinceLastAttempt = Date().timeIntervalSince(lastRegistrationAttempt)
        
        if timeSinceLastAttempt > attemptWindow {
            registrationAttempts = 0
        }
        
        guard registrationAttempts < maxAttempts else {
            errorMessage = "Too many attempts. Please try again later."
            return false
        }
        
        registrationAttempts += 1
        lastRegistrationAttempt = Date()
        return true
    }
    
    private func validateInputs() throws {
        guard !newEmail.isEmpty, newEmail.contains("@") else {
            throw NSError(domain: "Validation", code: 1,
                        userInfo: [NSLocalizedDescriptionKey: "Invalid email address"])
        }
        
        guard newPassword.count >= 8 else {
            throw NSError(domain: "Validation", code: 2,
                        userInfo: [NSLocalizedDescriptionKey: "Password must be at least 8 characters"])
        }
        
        guard !securityAnswer.isEmpty else {
            throw NSError(domain: "Validation", code: 3,
                        userInfo: [NSLocalizedDescriptionKey: "Security answer required"])
        }
    }
    
    private func createUserProfile(user: User) async throws {
        let newProfile = ProfileInsert(
            user_id: user.id,
            email: newEmail.trimmingCharacters(in: .whitespaces),
            full_name: fullName.trimmingCharacters(in: .whitespaces),
            security_question: selectedQuestion.rawValue,
            security_answer_hash: securityAnswer.sha256WithStretching()
        )

        try await supabase
            .from("profiles")
            .insert(newProfile)
            .execute()

        print("User profile created for \(fullName)")
    }

    
    private func handleRegistrationError(_ error: Error) async {
        let message: String
        if let nsError = error as NSError? {
            switch nsError.code {
            case 1: message = "Invalid email address"
            case 2: message = "Password must be at least 8 characters"
            case 3: message = "Security answer required"
            default: message = "Registration failed: \(error.localizedDescription)"
            }
        } else {
            message = "Registration failed: \(error.localizedDescription)"
        }
        
        await MainActor.run {
            errorMessage = message
        }
    }
}

////
////  RegisterUserSheet.swift
////  RoboCallerMover
////
////  Created by Michelle Zheng on 3/2/25.
////
//
//import Foundation
//import SwiftUI
//import Supabase
//
//struct RegisterUserSheet: View {
//    @Binding var isPresented: Bool
//    @Binding var session: Session?
//    @State private var newEmail: String = ""
//    @State private var newPassword: String = ""
//    @State private var fullName: String = ""
//    @State private var isLoading: Bool = false
//    @State private var errorMessage: String?
//
//    var body: some View {
//        NavigationStack {
//            Form {
//                Section("Create Account") {
//                    TextField("Full Name", text: $fullName)
//                    TextField("Email", text: $newEmail)
//                        .textContentType(.emailAddress)
//                        .autocapitalization(.none)
//                    SecureField("Password", text: $newPassword)
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
//                        Button("Register") {
//                            Task { await handleRegister() }
//                        }
//                    }
//                }
//            }
//            .navigationTitle("Register")
//            .toolbar {
//                ToolbarItem(placement: .cancellationAction) {
//                    Button("Cancel") {
//                        isPresented = false
//                    }
//                }
//            }
//        }
//    }
//
//    private func handleRegister() async {
//        do {
//            let cleanEmail = newEmail.trimmingCharacters(in: .whitespaces)
//            let cleanPassword = newPassword.trimmingCharacters(in: .whitespaces)
//            let cleanName = fullName.trimmingCharacters(in: .whitespaces)
//
//            // Registration logic remains the same
//            let authResponse = try await supabase.auth.signUp(
//                email: cleanEmail,
//                password: cleanPassword
//            )
//
//            let user = authResponse.user
//            
//            let newProfile = ProfileInsert(
//                user_id: user.id,
//                email: cleanEmail
//            )
//
//            try await supabase
//                .from("profiles")
//                .insert(newProfile)
//                .execute()
//
//            if let currentSession = authResponse.session {
//                await MainActor.run {
//                    self.session = currentSession
//                    isPresented = false
//                }
//            }
//            
//        } catch {
//            await MainActor.run {
//                errorMessage = "Registration failed: \(error.localizedDescription)"
//            }
//        }
//    }
//}
