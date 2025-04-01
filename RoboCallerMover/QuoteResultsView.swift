//
//  QuoteResultsView.swift
//  RoboCallerMover
//
//  Created by Michelle Zheng  on 2/24/25.
//

import SwiftUI
import Supabase


struct QuoteResultsView: View {
    let fromLocation: String
    let toLocation: String
    let items: String
    let availability: String
    let movingQueryID: Int
    let movingCompanyIDs: [Int] // IDs of moving companies
    let movingInquiryIDS: [Int] // IDs of moving inquiries

    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var movingInquiries: [MovingInquiry] = []
    @State private var movingCompanies: [MovingCompany] = []
    @State private var realtimeChannel: RealtimeChannelV2?  // Holds the realtime channel
    @State private var selectedCompany: MovingCompany?
    @State private var selectedInquiry: MovingInquiry?
    @State private var isCompanyViewActive = false

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {
                moveDetailsSection

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
            .onAppear {
                // Start data fetch and realtime subscription
                Task{
                    fetchMovingCompanies()
                    await fetchMovingInquiries()
                    await subscribeToRealtimeUpdates()
                }

            }
            .onDisappear {
                // Cleanup if needed
            }
            // NavigationLink to overlay the CompanyView
            .background(
                NavigationLink(
                    destination: CompanyView(
                        company: selectedCompany,
                        movingQueryID: movingQueryID,
                        movingInquiryID: selectedInquiry?.id ?? 0,
                        initialInquiry: selectedInquiry
                    ),
                    isActive: $isCompanyViewActive,
                    label: { EmptyView() }
                )
                .hidden()
            )
        }
    }

    // MARK: - Move Details Section
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

    // MARK: - Moving Company List
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
                List(movingInquiries) { inquiry in
                    movingCompanyRow(inquiry)
                }
            }
        }
    }

    // MARK: - Moving Company Row
    private func movingCompanyRow(_ inquiry: MovingInquiry) -> some View {
        guard let company = movingCompanies.first(where: { $0.id == inquiry.moving_company_id }) else {
            return AnyView(EmptyView())
        }

        switch (inquiry.price, inquiry.in_progress) {
        case (-1, false):
            return AnyView(
                HStack {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(company.name)
                            .font(.headline)
                        Text("Make Call to Get Quote")
                            .font(.subheadline)
                            .foregroundColor(.blue)
                        Divider()
                    }
                    .padding(.vertical, 8)
                    Spacer()
                    Button(action: {
                        navigateToCompanyView(company: company, inquiry: inquiry)
                    }) {
                        Image(systemName: "info.circle.fill")
                            .foregroundColor(.blue)
                            .padding()
                    }
                }
            )
        case (-1, true):
            return AnyView(
                HStack {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(company.name)
                            .font(.headline)
                        Text("Status: In Progress")
                            .font(.subheadline)
                            .foregroundColor(.green)
                        Divider()
                    }
                    .padding(.vertical, 8)
                    Spacer()
                    Button(action: {
                        navigateToCompanyView(company: company, inquiry: inquiry)
                    }) {
                        Image(systemName: "info.circle.fill")
                            .foregroundColor(.blue)
                            .padding()
                    }
                }
            )
        default:
            return AnyView(
                HStack {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(company.name)
                            .font(.headline)
                        Text("Phone: \(company.phoneNumber)")
                            .font(.subheadline)
                            .foregroundColor(.blue)
                        Text("Price: \(inquiry.price)")
                            .font(.subheadline)
                        Divider()
                    }
                    .padding(.vertical, 8)
                    Spacer()
                    Button(action: {
                        navigateToCompanyView(company: company, inquiry: inquiry)
                    }) {
                        Image(systemName: "info.circle.fill")
                            .foregroundColor(.blue)
                            .padding()
                    }
                }
            )
        }
    }

    // MARK: - Fetch Initial Data
    private func fetchMovingCompanies() {
        isLoading = true
        errorMessage = nil

        // Wrap async code in a Task block.
        Task {
            do {
                let response = try await supabase
                    .from("moving_company")
                    .select("*")
                    .in("id", values: movingCompanyIDs)
                    .execute()

                let companies = try JSONDecoder().decode([MovingCompany].self, from: response.data)
                await MainActor.run {
                    movingCompanies = companies
                    isLoading = false
                }
            } catch {
                await MainActor.run {
                    errorMessage = "Failed to load moving companies: \(error.localizedDescription)"
                    isLoading = false
                }
            }
        }
    }
    private func fetchMovingInquiries() async {

        do {
            let response = try await supabase
                .from("moving_inquiry")
                .select("*")
                .in("id", values: movingInquiryIDS)
                .execute()
                        // Print the raw response data for debugging
            if let responseData = String(data: response.data, encoding: .utf8) {
                print("Raw response data: \(responseData)")
            }
            let inquiries = try JSONDecoder().decode([MovingInquiry].self, from: response.data)
            await MainActor.run {
                movingInquiries = inquiries
                isLoading = false
            }
        } catch {
            await MainActor.run {
                errorMessage = "Failed to load moving inquiries: \(error.localizedDescription)"
                isLoading = false
            }
        }
    }

    // MARK: - Subscribe to Realtime Updates (Callback‑Based)
    private func subscribeToRealtimeUpdates() {
        Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { _ in
            Task {
                await fetchMovingInquiries()
            }
        }
    }
    private func navigateToCompanyView(company: MovingCompany, inquiry: MovingInquiry) {
        selectedCompany = company
        selectedInquiry = inquiry
        isCompanyViewActive = true
    }

}
