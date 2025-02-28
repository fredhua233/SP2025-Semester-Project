import SwiftUI
import Supabase

struct AccountView: View {
    var body: some View {
        if let _ = supabase.auth.session {
            // If supabase.auth.session is non-nil => user is logged in
            ProfileView()
        } else {
            // Not logged in => show the Login screen
            LoginScreen()
        }
    }
}
