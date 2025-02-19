//
//  AuthManager.swift
//  RoboCallerMover
//
//  Created by Michelle Zheng  on 2/18/25.
//


import Foundation
import Combine

class AuthManager: ObservableObject {
    @Published var isLoggedIn: Bool = false
    @Published var currentUser: User? = nil

    // Login function
    func login(username: String, password: String, completion: @escaping (Bool, String?) -> Void) {
        guard let url = URL(string: "https://your-mongodb-api.com/login") else {
            completion(false, "Invalid URL")
            return
        }

        let body: [String: Any] = [
            "username": username,
            "password": password
        ]

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(false, error.localizedDescription)
                return
            }

            guard let data = data else {
                completion(false, "No data received")
                return
            }

            do {
                let user = try JSONDecoder().decode(User.self, from: data)
                DispatchQueue.main.async {
                    self.currentUser = user
                    self.isLoggedIn = true
                }
                completion(true, nil)
            } catch {
                completion(false, "Failed to decode user: \(error.localizedDescription)")
            }
        }.resume()
    }

    // Logout function
    func logout() {
        self.currentUser = nil
        self.isLoggedIn = false
    }
}

// User model to match MongoDB structure
struct User: Codable, Identifiable {
    let id: String
    let type: String
    let data: [String: String]
    let custom_data: [String: String]
    let identities: [Identity]
}

struct Identity: Codable {
    let id: String
    let provider_type: String
    let data: [String: String]
}
