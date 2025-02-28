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
                                // If signOut is async/throws, do `try await`.
                                try await supabase.auth.signOut()
                            } catch {
                                errorMessage = "Sign-out error: \(error.localizedDescription)"
                            }
                        }
                    }
                }
            }
        }
        // As soon as the view appears, fetch the existing profile
        .task {
            await fetchProfile()
        }
        // Display errors in an alert
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
            // 1) Get user session (async/throws in your supabase-swift)
            let session = try await supabase.auth.session
            let user = session.user

            // 2) Convert the user ID to a string if your DB column is text
            let userID = user.id.uuidString

            // 3) Select from "profiles" where "id" == userID
            //    Then parse the result with `.value` instead of `.decoded()`
            let response = try await supabase
                .from("profiles")
                .eq(column: "id", value: userID)
                .select("*")
                .single()
                .execute()

            // `.value` is how older libs decode data (it doesn't throw)
            let profile: Profile = response.value

            // 4) Update local state
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

            // 1) Update the row, then .select("*") + .single() to get back the updated row
            let response = try await supabase
              .from("profiles")
              .filter("id", .eq, userID)
              .update(params)
              .select("*")
              .single()
              .execute()



            // 2) decode with `.value`
            let updatedProfile: Profile = response.value

            // 3) Reflect changes in UI
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
