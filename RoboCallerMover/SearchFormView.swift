//
//  SearchFormView.swift
//  RoboCallerMover
//
//  Created by Michelle Zheng on 2/2/25.
//

import SwiftUI
import Supabase

struct SearchFormView: View {
    @Binding var session: Session? // Fix: Ensure session binding exists
    @State private var fromLocation: String = ""
    @State private var toLocation: String = ""
    @State private var selectedMoveSize: MoveSize = .small
    @State private var moveDescription: String = ""
    @State private var selectedDate: Date = Date()
    @State private var userID: String = ""
    @State private var movingCompanyIDs: [Int] = []
    @State private var movingInquiryIDS: [Int] = []
    @State private var movingQuery: Int = 0
    
    // Navigation
    @State private var navigateToQuoteResults: Bool = false
    @State private var isLoading: Bool = false
    @State private var errorMessage: String?

    enum MoveSize: String, CaseIterable {
        case small = "Small (1–10 small items)"
        case medium = "Medium (1–5 small items, 1–3 large items)"
        case large = "Large (5+ all large items)"
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Text("Search for a Move").font(.title2).padding(.top).foregroundColor(Color("MovingBlue"))

                // "From" and "To" fields
                TextField("From", text: $fromLocation).textFieldStyle(.roundedBorder)
                TextField("To", text: $toLocation).textFieldStyle(.roundedBorder)

                // Move Size
                Picker("Size of Move", selection: $selectedMoveSize) {
                    ForEach(MoveSize.allCases, id: \.self) { size in
                        Text(size.rawValue)
                    }
                }
                .pickerStyle(MenuPickerStyle()).accentColor(Color("MovingBlue"))

                // Move Description
                TextEditor(text: $moveDescription)
                    .frame(height: 100)
                    .border(Color.gray.opacity(0.3))

                // Date
                DatePicker("Select Date", selection: $selectedDate, displayedComponents: .date)
                    .labelsHidden()

                // Loading indicator or Search button
                if isLoading {
                    ProgressView("Searching...")
                } else {
                    Button("Search") {
                        Task {
                            await performSearch()
                        }
                    }
                    .foregroundColor(Color("MovingBlue"))
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color("background"))
                    .cornerRadius(8)
                }

                // Error Message
                if let errorMessage = errorMessage {
                    Text(errorMessage).foregroundColor(.red)
                }

                Spacer()
                Image("movingLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 80)
                    .padding(.bottom, 5)
            }
            .padding()
            // Navigate to QuoteResultsView when search completes
            .navigationDestination(isPresented: $navigateToQuoteResults) {
                QuoteResultsView(
                    fromLocation: fromLocation,
                    toLocation: toLocation,
                    items: moveDescription,
                    availability: "\(selectedDate)",
                    movingQueryID: movingQuery,
                    movingCompanyIDs: movingCompanyIDs,
                    movingInquiryIDS: movingInquiryIDS
                    
                )
            }
        }
    }

    // MARK: - Perform Search
    private func performSearch() async {
        isLoading = true
        errorMessage = nil

        let created_at = ISO8601DateFormatter().string(from: Date())
        let availability = "\(selectedDate)"

        do {
            // Retrieve userID properly with try await
            guard let session = session else {
                errorMessage = "User session not found."
                isLoading = false
                return
            }
            let userID = session.user.id.uuidString

            let searchRequest = SearchRequest(
                location_from: fromLocation,
                location_to: toLocation,
                created_at: created_at,
                items: selectedMoveSize.rawValue,
                items_details: moveDescription,
                availability: availability,
                user_id: userID,
                inquiries: []
            )

            let responseString = try await withCheckedThrowingContinuation { continuation in
                APIManager.shared.getMovingCompanies(request: searchRequest) { result in
                    switch result {
                    case .success(let response):
                        continuation.resume(returning: response)
                    case .failure(let error):
                        continuation.resume(throwing: error)
                    }
                }
            }

            let responseData = Data(responseString.utf8)
            let jsonResponse = try JSONSerialization.jsonObject(with: responseData, options: []) as? [String: Any]
            guard let movingQueryID = jsonResponse?["moving_query_id"] as? Int else {
                throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid response from server"])
            }
            movingQuery = movingQueryID

            movingCompanyIDs = try await fetchMovingCompanyIDs(for: movingQueryID)
            movingInquiryIDS = try await fetchMovingInquiryIDs(for: movingQueryID)
            navigateToQuoteResults = true
        } catch {
            errorMessage = "Search failed: \(error.localizedDescription)"
        }

        isLoading = false
    }

    // MARK: - Fetch Moving Company IDs from Supabase
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

    // MARK: - Fetch Moving Company Details from Supabase
    private func fetchMovingCompanyDetails(for companyIDs: [Int]) async throws -> [MovingCompany] {
        let response = try await supabase
            .from("moving_company")
            .select("*")
            .in("id", values: companyIDs)
            .execute()

        let jsonData = response.data
        return try JSONDecoder().decode([MovingCompany].self, from: jsonData)
    }


}

struct SearchFormView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            SearchFormView(session: .constant(nil))
        }
    }
}
