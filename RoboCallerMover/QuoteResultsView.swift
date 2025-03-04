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
            }
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
                        makeCall(phoneNumber: inquiry.phone_number, id: company.id, inquiryID: inquiry.id)
                    }) {
                        Image(systemName: "phone.fill")
                            .foregroundColor(.blue)
                            .padding()
                    }
                }
            )
        case (-1, true):
            return AnyView(
                VStack(alignment: .leading, spacing: 8) {
                    Text(company.name)
                        .font(.headline)
                    Text("Status: In Progress")
                        .font(.subheadline)
                        .foregroundColor(.green)
                    Divider()
                }
                .padding(.vertical, 8)
            )
        default:
            return AnyView(
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
            )
        }
    }
    private func makeCall(phoneNumber: String, id: Int, inquiryID: Int) {
        guard let url = URL(string: "http://127.0.0.1:8000/call_moving_companies/?moving_company_number=\(phoneNumber)&moving_company_id=\(id)&moving_query_id=\(movingQueryID)") else {
            print("Invalid URL")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "accept")

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error making call: \(error)")
                return
            }

            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                print("Server error")
                return
            }

            if let data = data, let responseString = String(data: data, encoding: .utf8) {
                print("Response: \(responseString)")
            }

            // Update the in_progress column in the moving_inquiry table
            Task {
                do {
                    let updateResponse = try await supabase
                        .from("moving_inquiry")
                        .update(["in_progress": true])
                        .eq("id", value: inquiryID)
                        .execute()

                    await fetchMovingInquiries()
                } catch {
                    print("Error updating in_progress column: \(error)")
                }
            }
        }

        task.resume()
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

}
