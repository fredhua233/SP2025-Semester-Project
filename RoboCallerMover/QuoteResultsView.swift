//
//  QuoteResultsView.swift
//  RoboCallerMover
//
//  Created by Michelle Zheng  on 2/18/25.
//

import SwiftUI
import Supabase

struct QuoteResultsView: View {
    let fromLocation: String
    let toLocation: String
    let items: String
    let availability: String
    let movingCompanies: [MovingCompany] // List of moving companies

    @State private var isLoading: Bool = false
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {
                // **Move details section**
                moveDetailsSection

                // **Moving company results**
                if isLoading {
                    ProgressView("Loading moving companies...")
                } else if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding()
                } else {
                    movingCompanyList
                }

                Spacer()
            }
            .padding()
            .navigationTitle("Move from \(fromLocation) to \(toLocation)")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    // **MARK: Move Details Section**
    private var moveDetailsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Move Details")
                .font(.title2)
                .padding(.top)

            Text("From: \(fromLocation)")
                .font(.subheadline)

            Text("To: \(toLocation)")
                .font(.subheadline)

            Text("Items: \(items)")
                .font(.subheadline)

            Text("Availability: \(availability)")
                .font(.subheadline)
        }
        .padding(.horizontal)
    }

    // **MARK: Moving Company List**
    private var movingCompanyList: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Available Moving Companies")
                .font(.headline)
                .padding(.horizontal)

            if movingCompanies.isEmpty {
                Text("No moving companies found for your search.")
                    .foregroundColor(.gray)
                    .padding(.horizontal)
            } else {
                List(movingCompanies) { company in
                    movingCompanyRow(company)
                }
            }
        }
    }

    // **MARK: Moving Company Row**
    private func movingCompanyRow(_ company: MovingCompany) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(company.name)
                .font(.headline)

            Text("Phone: \(company.phoneNumber)")
                .font(.subheadline)
                .foregroundColor(.blue)

            Divider()
        }
        .padding(.vertical, 8)
    }
}

