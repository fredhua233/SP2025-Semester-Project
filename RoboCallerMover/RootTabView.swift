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
                SearchFormView()
            }
            .tabItem {
                Label("Search", systemImage: "magnifyingglass")
            }

            NavigationStack {
                PastSearchesView()
            }
            .tabItem {
                Label("Past", systemImage: "clock")
            }

            // 3rd tab for "Account"
            NavigationStack {
                AccountView() // Decides if user sees LoginScreen or ProfileView
            }
            .tabItem {
                Label("Account", systemImage: "person")
            }
        }
    }
}

struct RootTabView_Previews: PreviewProvider {
    static var previews: some View {
        RootTabView()
    }
}
