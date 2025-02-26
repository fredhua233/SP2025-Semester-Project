//
//  RootTabView.swift
//  RoboCallerMover
//
//  Created by Michelle Zheng on 2/25/25.
//

import SwiftUI
import Supabase

struct RootTabView: View {
    var body: some View {
        TabView {
            NavigationStack {
                SearchFormView() // existing code
            }
            .tabItem {
                Label("Search", systemImage: "magnifyingglass")
            }

            NavigationStack {
                PastSearchesView() // existing code
            }
            .tabItem {
                Label("Past", systemImage: "clock")
            }

            // New tab for "Account"
//            NavigationStack {
//                AccountView()
//            }
//            .tabItem {
//                Label("Account", systemImage: "person")
//            }
        }
    }
}

//struct AccountView: View {
//    var body: some View {
//        // If session is available => show profile
//        if let _ = supabase.auth.session {
//            ProfileView()
//        } else {
//            // No session => show login
//            LoginScreen()
//        }
//    }
//}

struct RootTabView_Previews: PreviewProvider {
    static var previews: some View {
        RootTabView()
    }
}


