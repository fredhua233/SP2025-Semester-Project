//
//  SearchFormView.swift
//  roboCaller
//  Allows users to search for items
//  Created by Michelle Zheng on 2/2/25.
//

import SwiftUI
import Supabase

struct SearchFormView: View {
    // User inputs
    @State private var fromLocation: String = ""
    @State private var toLocation: String = ""
    @State private var selectedMoveSize: MoveSize = .small
    @State private var moveDescription: String = ""
    @State private var selectedDate: Date = Date()
    @State private var user_id: String = ""

    // State
    @State private var isLoading: Bool = false
    @State private var errorMessage: String? = nil
    @State private var successMessage: String? = nil
    @State private var navigateToQuoteResults: Bool = false // For final navigation

    enum MoveSize: String, CaseIterable {
        case small = "Small (1–10 small items)"
        case medium = "Medium (1–5 small items, 1–3 large items)"
        case large = "Large (5+ all large items)"
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Text("Search for a Move")
                    .font(.title2)
                    .padding(.top)

                // "From" and "To" fields
                Group {
                    TextField("From", text: $fromLocation)
                        .textFieldStyle(.roundedBorder)
                    TextField("To", text: $toLocation)
                        .textFieldStyle(.roundedBorder)
                }

                // Move Size
                Picker("Size of Move", selection: $selectedMoveSize) {
                    ForEach(MoveSize.allCases, id: \.self) { size in
                        Text(size.rawValue)
                    }
                }
                .pickerStyle(MenuPickerStyle())

                // Move Description
                TextEditor(text: $moveDescription)
                    .frame(height: 100)
                    .border(Color.gray.opacity(0.3))

                // Date
                DatePicker("Select Date", selection: $selectedDate, displayedComponents: .date)
                    .labelsHidden()

                // Loading indicator or Search button
                if isLoading {
                    ProgressView("Posting requests...")
                } else {
                    Button("Search") {
                        performSearch()
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.black)
                    .cornerRadius(8)
                }

                // Error
                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                }

                // Success
                if let successMessage = successMessage {
                    Text(successMessage)
                        .foregroundColor(.green)
                }

                Spacer()
            }
            .padding()
            // When both calls succeed, navigate to QuoteResultsView
            .navigationDestination(isPresented: $navigateToQuoteResults) {
                // A simple results page (or your real QuoteResultsView)
                QuoteResultsView(
                    fromLocation: fromLocation,
                    toLocation: toLocation,
                    items: moveDescription,
                    availability: "\(selectedDate)",
                    quotes: []
                )
            }
        }
    }

    private func performSearch() {
        isLoading = true
        errorMessage = nil
        successMessage = nil

        // Build the request body
        let created_at = ISO8601DateFormatter().string(from: Date())
        let items_details = selectedMoveSize.rawValue
        let availability = "\(selectedDate)"
        let inquiries: [Int] = []
        let userID: String = "000"

        // If you still need a user_id, derive from supabase.auth.session?.user?.id
//        let userID = supabase.auth.session?.user?.id ?? ""
//
//        // 1) /get_moving_companies
        let searchRequest = SearchRequest(
            location_from: fromLocation,
            location_to: toLocation,
            created_at: created_at,
//            items: moveDescription,
//            items_details: items_details,
            items: items_details,
            items_details: moveDescription,
            availability: availability,
            user_id: userID,
            inquiries: inquiries
        )

        APIManager.shared.getMovingCompanies(request: searchRequest) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let responseString):
                    print("getMovingCompanies success => \(responseString)")
                    // 2) Now call call_moving_companies
                case .failure(let error):
                    self.isLoading = false
                    self.errorMessage = "Failed getMovingCompanies: \(error.localizedDescription)"
                }
            }
        }
    }

}

struct SearchFormView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            SearchFormView()
        }
    }
}
