//
//  LoginScreen.swift
//  RoboCallerMover
//
//  Created by Michelle Zheng  on 2/4/25.
//

import SwiftUI

struct LoginScreen: View {
    @EnvironmentObject var authManager: AuthManager
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var errorMessage: String? = nil

    var body: some View {
        VStack(spacing: 16) {
//            Text("Account Login")
//                .font(.largeTitle)
//                .padding(.top, 80)
            Image("movingLogo")
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity)
                .frame(height: 500)
                .cornerRadius(300)

            TextField("Username", text: $username)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .autocapitalization(.none)

            SecureField("Password", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())

            //error message
            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
            }

            //button
            Button(action: {
                authManager.login(username: username, password: password) { success, error in
                    if !success {
                        errorMessage = error ?? "Login failed"
                    }
                }
            }) {
                Text("Login")
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.yellow)
                    .cornerRadius(8)
            }
            
            //push the image down
            Spacer()
            
            
        }
        .padding(.horizontal)
        .background(Color.white) // optional if you want a solid background
        .edgesIgnoringSafeArea(.top)
    }
}

struct LoginScreen_Previews: PreviewProvider {
    static var previews: some View {
        LoginScreen()
            .environmentObject(AuthManager())
    }
}
