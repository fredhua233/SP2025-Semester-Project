//
//  LoginScreen.swift
//  RoboCallerMover
//
//  Created by Michelle Zheng on 2/25/25.
//

import SwiftUI
import Foundation
import Supabase
import AuthenticationServices



struct LoginScreen: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var isLoading: Bool = false
    @State private var result: Result<Void, Error>?
    
    var body: some View {
        Form {
            Section {
                TextField("Email", text: $email)
                    .textContentType(.emailAddress)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                
                SecureField("Password", text: $password)
                    .textContentType(.password)
                    .autocorrectionDisabled()
            }
            
            Section {
                Button("Sign in") {
                    signInButtonTapped()
                }
                
                if isLoading {
                    ProgressView()
                }
            }
            
            // Show success or error
            if let result {
                Section {
                    switch result {
                    case .success:
                        Text("Signed in successfully!")
                    case .failure(let error):
                        Text(error.localizedDescription)
                            .foregroundColor(.red)
                    }
                }
            }
        }
    }
    
    func signInButtonTapped() {
        Task {
            isLoading = true
            defer { isLoading = false }
            do {
                // Sign in with email/password
                try await supabase.auth.signIn(email: email, password: password)
                
                result = .success(())
            } catch {
                result = .failure(error)
            }
        }
    }
    
    
    struct LoginScreen_Previews: PreviewProvider {
        static var previews: some View {
            NavigationStack {
                LoginScreen()
            }
        }
    }
}
