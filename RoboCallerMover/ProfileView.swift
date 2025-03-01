//
//  ProfileView.swift
//  RoboCallerMover
//
//  Created by Michelle Zheng on 2/25/25.
//

import SwiftUI
import Supabase

struct ProfileView: View {
    @State private var username = ""
    @State private var fullName = ""
    @State private var email = ""
    @State private var password = ""
    @State private var isLoading = false
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            Form {
                Section("Profile") {
                    TextField("Username", text: $username)
                    TextField("Full Name", text: $fullName)
                    TextField("Email", text: $email)
                    SecureField("Password", text: $password)
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

    // MARK: - Fetch the user's current profile
    private func fetchProfile() async {
        do {
            let session = try await supabase.auth.session
            let user = session.user
            let userID = user.id.uuidString

            // Fetch profile from the `profiles` table
            let response = try await supabase
                .from("profiles")
                .select()
                .eq("user_id", value: userID) // Match the `user_id` in `profiles` with the current user's ID
                .single()
                .execute()

            // Decode the response into the Profile type
            let profile: Profile = try JSONDecoder().decode(Profile.self, from: response.data)

            // Update state
            username = profile.username ?? ""
            fullName = profile.fullName ?? ""
            email    = profile.email ?? ""
            password = profile.password ?? ""

        } catch {
            errorMessage = "Error fetching profile: \(error.localizedDescription)"
        }
    }

    // MARK: - Update the user's profile
    private func updateProfile() async {
        do {
            isLoading = true
            defer { isLoading = false }

            let session = try await supabase.auth.session
            let user = session.user
            let userID = user.id.uuidString

            let params = UpdateProfileParams(
                username: username,
                fullName: fullName,
                email: email,
                password: password
            )

            // Update profile in the `profiles` table
            let response = try await supabase
                .from("profiles")
                .update(params)
                .eq("user_id", value: userID) // Match the `user_id` in `profiles` with the current user's ID
                .select()
                .single()
                .execute()

            // Decode the response into the Profile type
            let updatedProfile: Profile = try JSONDecoder().decode(Profile.self, from: response.data)

            // Update state
            username = updatedProfile.username ?? ""
            fullName = updatedProfile.fullName ?? ""
            email    = updatedProfile.email ?? ""
            password = updatedProfile.password ?? ""

            print("Profile updated to username: \(updatedProfile.username ?? "nil")")

        } catch {
            errorMessage = "Error updating profile: \(error.localizedDescription)"
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}
