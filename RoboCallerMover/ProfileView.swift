//
//  ProfileView.swift
//  RoboCallerMover
//
//  Created by Michelle Zheng on 2/25/25.
//

import SwiftUI
import Supabase

struct ProfileView: View {
    @Binding var session: Session?
    @State private var fullName = ""
    @State private var email = ""
    @State private var isLoading = false
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            Form {
                Section("Profile") {
                    TextField("Full Name", text: $fullName)
                    TextField("Email", text: $email)
                }
                Section {
                    if isLoading {
                        ProgressView()
                    } else {
                        Button("Update Profile") {
                            Task { await updateProfile() }
                        }
                    }
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
                                errorMessage = "Sign-out error: \(error.localizedDescription)"
                            }
                        }
                    }
                }
            }
        }
        .task {
            await fetchProfile()
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
    
    // MARK: - Profile Updating
    private func updateProfile() async {
        do {
            isLoading = true
            defer { isLoading = false }

            guard let session = session else {
                throw NSError(domain: "Auth", code: 401, userInfo: [NSLocalizedDescriptionKey: "No active session"])
            }

            let params = UpdateProfileParams(
                full_name: fullName,
                email: email
            )

            let response = try await supabase
                .from("profiles")
                .update(params)
                .eq("user_id", value: session.user.id)
                .select()
                .single()
                .execute()

            let updatedProfile: Profile = try JSONDecoder().decode(Profile.self, from: response.data)
            await MainActor.run {
                fullName = updatedProfile.full_name ?? "No name provided"
                email = updatedProfile.email!
            }
        } catch {
            await MainActor.run {
                errorMessage = "Update failed: \(error.localizedDescription)"
            }
        }
    }

    // MARK: - Profile Fetching
    private func fetchProfile() async {
        do {
            guard let session = session else { return }
            
            let response = try await supabase
                .from("profiles")
                .select()
                .eq("user_id", value: session.user.id)
                .single()
                .execute()

            let profile: Profile = try JSONDecoder().decode(Profile.self, from: response.data)
            
            await MainActor.run {
                fullName = profile.full_name ?? "" // Handle optional
                email = profile.email ?? "" // Handle optional
            }
            
        } catch {
            await MainActor.run {
                errorMessage = "Profile error: \(error.localizedDescription)"
            }
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView(session: .constant(nil))
    }
}
