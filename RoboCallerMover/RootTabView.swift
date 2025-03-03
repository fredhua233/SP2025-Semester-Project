//
//  RootTabView.swift
//  RoboCallerMover
//
//  Created by Michelle Zheng on 2/25/25.
//

import SwiftUI
import Supabase

struct RootTabView: View {
    @Binding var session: Session?
    var body: some View {
        TabView {
            NavigationStack {
                SearchFormView(session: $session) 
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

            NavigationStack {
                AccountView(session: $session) 
            }
            .tabItem {
                Label("Account", systemImage: "person")
            }
        }
    }
}

struct RootTabView_Previews: PreviewProvider {
    static var previews: some View {
        RootTabView(session: .constant(nil))
    }
}
