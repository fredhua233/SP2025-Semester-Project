import SwiftUI

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
        }
    }
}

struct RootTabView_Previews: PreviewProvider {
    static var previews: some View {
        RootTabView()
    }
}
