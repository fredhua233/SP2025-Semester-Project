import Foundation

class AuthManager: ObservableObject {
    @Published var isLoggedIn: Bool = false

    func login(username: String, password: String) {
        // TODO: Implement actual login logic
        if username == "user" && password == "password" {
            isLoggedIn = true
        }
    }

    func logout() {
        isLoggedIn = false
    }
}