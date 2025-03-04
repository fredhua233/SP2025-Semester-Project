//
//  ProfileView.swift
//  RoboCallerMover
//
//  Created by Michelle Zheng on 2/25/25.
//

import SwiftUI
import Supabase
import CryptoKit

struct ProfileView: View {
    @Binding var session: Session?
    @State private var fullName = ""
    @State private var email = ""
    @State private var currentSecurityAnswer = ""
    @State private var newSecurityQuestion = ""
    @State private var newSecurityAnswer = ""
    @State private var newPassword = ""
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    // Session expiration buffer (matches AccountView)
    private let sessionExpirationBuffer: TimeInterval = 300

    var body: some View {
        NavigationStack {
            Form {
                Section("Profile") {
                    TextField("Full Name", text: $fullName)
                    TextField("Email", text: $email)
                        .textContentType(.emailAddress)
                        .autocapitalization(.none)
                        .disabled(true)
                }

                Section("Security Settings") {
                    SecureField("Current Security Answer", text: $currentSecurityAnswer)
                        .textContentType(.password)
                    
                    Picker("New Security Question", selection: $newSecurityQuestion) {
                        Text("Select a question").tag("")
                        ForEach(SecurityQuestion.allCases) { question in
                            Text(question.rawValue).tag(question.rawValue)
                        }
                    }
                    
                    SecureField("New Security Answer", text: $newSecurityAnswer)
                        .textContentType(.newPassword)
                    
                    SecureField("New Password", text: $newPassword)
                        .textContentType(.newPassword)
                }

                Section {
                    if isLoading {
                        ProgressView()
                    } else {
                        Button("Update Settings") {
                            Task { await updateSecuritySettings() }
                        }
                        .disabled(updateButtonDisabled)
                    }
                }

                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                }
            }
            .navigationTitle("Profile")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Sign out", role: .destructive) {
                        Task {
                            do {
                                try await supabase.auth.signOut()
                                session = nil
                            } catch {
                                handleError(error)
                            }
                        }
                    }
                }
            }
            .task {
                await loadProfile()
            }
            .alert("Error", isPresented: Binding<Bool>(
                get: { errorMessage != nil },
                set: { if !$0 { errorMessage = nil } }
            )) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(errorMessage ?? "Unknown error")
            }
        }
    }
    
    // MARK: - Update Logic
    private var updateButtonDisabled: Bool {
        currentSecurityAnswer.isEmpty &&
        newSecurityQuestion.isEmpty &&
        newSecurityAnswer.isEmpty &&
        newPassword.isEmpty
    }
    
    private func updateSecuritySettings() async {
        guard let userId = session?.user.id else {
            handleError(NSError(domain: "Auth", code: 401, userInfo: [NSLocalizedDescriptionKey: "No active session"]))
            return
        }
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            try await checkSessionExpiration()

            var updateData: [String: String] = [:]
            
            // Only include non-empty fields
            if !fullName.isEmpty { updateData["full_name"] = fullName }
            if !newSecurityQuestion.isEmpty { updateData["security_question"] = newSecurityQuestion }
            if !newSecurityAnswer.isEmpty { updateData["security_answer_hash"] = newSecurityAnswer.sha256WithStretching() }
            
            // If there's nothing to update, return early
            guard !updateData.isEmpty else {
                errorMessage = "No changes to update."
                return
            }
            
            try await supabase
                .from("profiles")
                .update(updateData)
                .eq("user_id", value: userId)
                .execute()

            await MainActor.run {
                errorMessage = "Settings updated successfully!"
                resetFields()
                Task { await loadProfile() } // Reload profile to reflect changes
            }
        } catch {
            handleError(error)
        }
    }

    
    // MARK: - Helper Methods
    private func loadProfile() async {
        guard let userId = session?.user.id else { return }

        do {
            let response = try await supabase
                .from("profiles")
                .select()
                .eq("user_id", value: userId)
                .limit(1) // Prevent multiple rows issue
                .execute()

            // Check if response data is empty
            guard !response.data.isEmpty else {
                print("No profile found for user \(userId)")
                return
            }

            // Decode JSON array to get first profile
            let profile = try JSONDecoder().decode([Profile].self, from: response.data).first

            await MainActor.run {
                fullName = profile?.full_name ?? ""
                email = profile?.email ?? ""
                newSecurityQuestion = profile?.security_question ?? ""
            }

        } catch {
            handleError(error)
        }
    }


    
    private func resetFields() {
        currentSecurityAnswer = ""
        newSecurityAnswer = ""
        newPassword = ""
    }
    
    private func checkSessionExpiration() async throws {
        guard let session = session else { return }
        
        let expirationWithBuffer = Date(timeIntervalSince1970: session.expiresAt - sessionExpirationBuffer)
        if Date() > expirationWithBuffer {
            let refreshedSession = try await supabase.auth.refreshSession()
            self.session = refreshedSession
        }
    }
    
    private func handleError(_ error: Error) {
        Task { @MainActor in
            errorMessage = error.localizedDescription
            print("Profile Error: \(error)")
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView(session: .constant(nil))
    }
}

extension ClientManager {
    func updateSecuritySettings(userId: UUID, question: String?, answer: String?) async throws {
        var updates: [String: String] = [:]
        
        if let question = question {
            updates["security_question"] = question
        }
        if let answer = answer {
            updates["security_answer_hash"] = answer.sha256WithStretching()
        }
        
        try await adminClient
            .from("profiles")
            .update(updates)
            .eq("user_id", value: userId)
            .execute()
    }
}



