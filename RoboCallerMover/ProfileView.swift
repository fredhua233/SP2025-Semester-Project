//
//  ProfileView.swift
//  RoboCallerMover
//
//  Created by Michelle Zheng on 2/25/25.
//

import SwiftUI
import AuthenticationServices
import Supabase

struct ProfileView: View {
    let client = SupabaseClient(
        supabaseURL: URL(string: "https://trhnmlvipaujtmtvagbs.supabase.co")!,
        supabaseKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InRyaG5tbHZpcGF1anRtdHZhZ2JzIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDAwOTM0NzUsImV4cCI6MjA1NTY2OTQ3NX0.jRvPzrjGDnm7dTdXwUEVOKspvaR7NEHzqNYR_Shhqos"
      )
    var body: some View {
      SignInWithAppleButton { request in
        request.requestedScopes = [.email, .fullName]
      } onCompletion: { result in
        Task {
          do {
            guard let credential = try result.get().credential as? ASAuthorizationAppleIDCredential
            else {
              return
            }

            guard let idToken = credential.identityToken
              .flatMap({ String(data: $0, encoding: .utf8) })
            else {
              return
            }
              try await client.auth.signInWithIdToken(
              credentials: .init(
                provider: .apple,
                idToken: idToken
              )
            )
          } catch {
            dump(error)
          }
        }
      }
      .fixedSize()
    }
}


// MARK: - Preview
struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}
