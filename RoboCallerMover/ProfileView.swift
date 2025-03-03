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

            let userID = session.user.id

            let params = UpdateProfileParams(
                full_name: fullName,
                email: email
            )

            let response = try await supabase
                .from("profiles")
                .update(params)
                .eq("user_id", value: userID)
                .select()
                .single()
                .execute()

            let updatedProfile: Profile = try JSONDecoder().decode(Profile.self, from: response.data)
            await MainActor.run {
                fullName = updatedProfile.full_name ?? ""
                email = updatedProfile.email ?? ""
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
            guard let session = session else {
                throw NSError(domain: "Auth", code: 401, userInfo: [NSLocalizedDescriptionKey: "No active session"])
            }

            let userID = session.user.id

            print("Fetching profile for user ID:", userID)

            // Fetch all rows matching the user_id
            let response = try await supabase
                .from("profiles")
                .select()
                .eq("user_id", value: userID)
                .execute()

            print("Profile query response:", response)

            // Check if there are multiple or zero rows returned
            let jsonData = response.data

            if jsonData.isEmpty {
                print("No profile found for user:", userID)
                
                // Create a new profile
                try await createNewProfile(userID: userID, email: session.user.email ?? "")
                
                return
            }

            // Decode profile safely
            let profiles = try JSONDecoder().decode([Profile].self, from: jsonData)

            if profiles.count > 1 {
                print("Multiple profiles found for user! This should not happen.")
                throw NSError(domain: "Database", code: 500, userInfo: [NSLocalizedDescriptionKey: "Multiple profiles found for the same user."])
            }

            if let profile = profiles.first {
                print("Profile found:", profile)
                await MainActor.run {
                    fullName = profile.full_name ?? ""
                    email = profile.email ?? ""
                }
            }

        } catch {
            print("Profile error:", error)
            await MainActor.run {
                errorMessage = """
                Profile error: \(error.localizedDescription)
                
                Debugging steps:
                1. Check if a profile exists for your user_id
                2. Ensure profiles table has unique user_id values
                3. If needed, create a profile manually
                """
            }
        }
    }
    
    // MARK: - create new profiles
    private func createNewProfile(userID: UUID, email: String) async throws {
        print("🆕 Creating new profile for user:", userID)

        let newProfile = ProfileInsert(
            user_id: userID,
            email: email
        )

        try await supabase
            .from("profiles")
            .insert(newProfile)
            .execute()

        print("✅ Profile successfully created for user:", userID)

        await MainActor.run {
            fullName = ""
            self.email = email
        }
    }

    


    // MARK: - Error Handling
    private func handleProfileError(_ error: Error) async {
        let nsError = error as NSError
        var message = "Profile error: \(error.localizedDescription)"
        
        if nsError.domain == "PostgRESTError" {
            message = """
            Database error. Please check:
            1. Internet connection
            2. Profile table permissions
            """
        }
        
        await MainActor.run {
            errorMessage = message
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView(session: .constant(nil))
    }
}
