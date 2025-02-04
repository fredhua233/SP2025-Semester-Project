//
//  RootTabView.swift
//  RoboCallerMover
//
//  Created by Michelle Zheng  on 2/2/25.
// NEED DO
// Custom images for each button

import SwiftUI

struct RootTabView: View {
    var body: some View {
        TabView {
            NavigationView {
                SearchFormView()
            }
            .tabItem {
                Label("Search", systemImage: "magnifyingglass")
            }

            NavigationView {
                PastSearchesView()
            }
            .tabItem {
                Label("Past", systemImage: "clock")
            }

            NavigationView {
                QuoteResultsView()
            }
            .tabItem {
                Label("Quotes", systemImage: "doc.text.magnifyingglass")
            }
            
            NavigationView {
                CallTranscriptCompanyView()
            }
            .tabItem {
                Label("Call Log", systemImage: "phone")
            }
            
            NavigationView {
                LoginScreen()
            }
            .tabItem {
                Label("Login", systemImage: "person")
            }
        }
    }
}

struct RootTabView_Previews: PreviewProvider {
    static var previews: some View {
        RootTabView()
    }
}
