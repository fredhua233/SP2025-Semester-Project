//
//  PastSearchesView.swift
//  RoboCallerMover
//
//  Created by Michelle Zheng  on 2/4/25.
//
import SwiftUI
import Supabase

struct PastSearchesView: View {
    @Binding var session: Session?
    
    @State private var pastSearches: [MovingQuery] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    // Navigation control and selected query data
    @State private var navigateToQuoteResults: Bool = false
    @State private var selectedMovingQuery: MovingQuery?
    @State private var selectedMovingCompanyIDs: [Int] = []
    @State private var selectedMovingInquiryIDS: [Int] = []
    
    var body: some View {
        NavigationStack {
            VStack {
                if isLoading {
                    ProgressView("Loading past searches...")
                } else if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                } else {
                    List(pastSearches) { query in
                        // Each row is a button that triggers the async fetching of extra data
                        Button {
                            Task { await handleQuerySelection(query) }
                        } label: {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("From: \(query.location_from)")
                                    Text("To: \(query.location_to)")
                                    Text("Date: \(query.availability)") // Alternatively, use query.created_at
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                }
                                Spacer()
                            }
                        }
                    }
                }
                
                // NavigationLink to QuoteResultsView (programmatic navigation)
                NavigationLink(isActive: $navigateToQuoteResults) {
                    if let selectedQuery = selectedMovingQuery {
                        QuoteResultsView(
                            fromLocation: selectedQuery.location_from,
                            toLocation: selectedQuery.location_to,
                            items: selectedQuery.items,
                            availability: selectedQuery.availability,
                            movingQueryID: selectedQuery.id,
                            movingCompanyIDs: selectedMovingCompanyIDs,
                            movingInquiryIDS: selectedMovingInquiryIDS
                        )
                    } else {
                        EmptyView()
                    }
                } label: { EmptyView() }
            }
            .navigationTitle("Past Searches")
            .padding()
            .onAppear {
                print("user id: \(session?.user.id.uuidString ?? "nil")")
                Task { await fetchPastSearches() }
            }
        }
    }
    
    // MARK: - Fetch Past Searches for the current user
    private func fetchPastSearches() async {
        guard let session = session else {
            self.errorMessage = "User session not found."
            return
        }
        
        isLoading = true
        errorMessage = nil
        

        do {
            let response = try await supabase
                .from("moving_query")
                .select("*")
                .eq("user_id", value: session.user.id.uuidString)
                .execute()

            // Print the raw response data for debugging
            if let responseData = String(data: response.data, encoding: .utf8) {
                print("Raw response data: \(responseData)")
            }

            // Decode the response into an array of MovingQuery objects.
            let queries = try JSONDecoder().decode([MovingQuery].self, from: response.data)
            await MainActor.run {
                self.pastSearches = queries
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.errorMessage = "Failed to load past searches: \(error.localizedDescription)"
                self.isLoading = false
            }
        }
    }
    
    // MARK: - Handle selection of a past search row
    private func handleQuerySelection(_ query: MovingQuery) async {
        do {
            // Use the helper functions to get additional details
            selectedMovingCompanyIDs = try await fetchMovingCompanyIDs(for: query.id)
            selectedMovingInquiryIDS = try await fetchMovingInquiryIDs(for: query.id)
            selectedMovingQuery = query
            await MainActor.run {
                navigateToQuoteResults = true
            }
        } catch {
            await MainActor.run {
                errorMessage = "Failed to load additional query details: \(error.localizedDescription)"
            }
        }
    }
    
    // MARK: - Helper functions to fetch additional information from Supabase
    
    private func fetchMovingCompanyIDs(for movingQueryID: Int) async throws -> [Int] {
        let response = try await supabase
            .from("moving_inquiry")
            .select("moving_company_id")
            .eq("moving_query_id", value: movingQueryID)
            .execute()
        
        let jsonData = response.data
        let inquiryIDs = try JSONDecoder().decode([[String: Int]].self, from: jsonData)
        return inquiryIDs.compactMap { $0["moving_company_id"] }
    }
    
    private func fetchMovingInquiryIDs(for movingQueryID: Int) async throws -> [Int] {
        let response = try await supabase
            .from("moving_inquiry")
            .select("id")
            .eq("moving_query_id", value: movingQueryID)
            .execute()
        
        let jsonData = response.data
        let inquiryIDs = try JSONDecoder().decode([[String: Int]].self, from: jsonData)
        return inquiryIDs.compactMap { $0["id"] }
    }
}

struct PastSearchesView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            PastSearchesView(session: .constant(nil))
        }
    }
}
