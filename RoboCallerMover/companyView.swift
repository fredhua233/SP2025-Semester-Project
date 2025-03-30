import SwiftUI
import Supabase

struct CompanyView: View {
    let company: MovingCompany?
    let movingQueryID: Int
    let inquiry: MovingInquiry?

    var body: some View {
        ScrollView { // Added ScrollView to enable scrolling
            VStack(alignment: .leading, spacing: 16) {
                if let company = company, let inquiry = inquiry {
                    companyHeader(company)
                    callToGetPriceButton(inquiry: inquiry)
                    coverImage()
                    ratingSection(company)
                    inquiryStatus(inquiry)
                } else {
                    Text("No company details available.")
                        .foregroundColor(.gray)
                }
            }
            .padding()
        }
        .navigationTitle(company?.name ?? "Company Details")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Subviews

    @ViewBuilder
    private func companyHeader(_ company: MovingCompany) -> some View {
        Text(company.name)
            .font(.largeTitle)
            .bold()
            .padding(.top)
    }

    @ViewBuilder
    private func callToGetPriceButton(inquiry: MovingInquiry) -> some View {
        if !inquiry.in_progress && inquiry.price == -1 {
            Button(action: {
                makeCall()
            }) {
                Text("Call to Get Price")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
            }
        }
    }

    @ViewBuilder
    private func coverImage() -> some View {
        if let coverImageURL = URL(string: "https://lh5.googleusercontent.com/p/AF1QipOcZgYqgL4JC5VdWdx5tZycuYUfSUeT-6mvM3S-=w408-h357-k-no") {
            AsyncImage(url: coverImageURL) { image in
                image
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity, maxHeight: 200)
                    .cornerRadius(10)
            } placeholder: {
                ProgressView()
            }
        }
    }

    @ViewBuilder
    private func ratingSection(_ company: MovingCompany) -> some View {
        HStack {
            ForEach(0..<5) { index in
                Image(systemName: index < Int(company.rating) ? "star.fill" : "star")
                    .foregroundColor(.yellow)
            }
            Text("(\(company.user_ratings_total))")
                .font(.subheadline)
                .foregroundColor(.gray)
        }
    }

    @ViewBuilder
    private func inquiryStatus(_ inquiry: MovingInquiry) -> some View {
        if !inquiry.in_progress {
            Text("Please make the call to get moving details")
                .font(.subheadline)
                .foregroundColor(.red)
        } else if inquiry.in_progress && inquiry.price == -1 {
            Text("Call is in progress, please wait while we get your price.")
                .font(.subheadline)
                .foregroundColor(.orange)
        } else if inquiry.in_progress && inquiry.price != -1 {
            Section(header: Text("Price").font(.headline)) {
                Text("$\(inquiry.price ?? 0)")
                    .font(.title)
                    .bold()
            }

            Section(header: Text("Call Information").font(.headline)) {
                Text("Duration: \(inquiry.call_duration ?? 0) minutes")
                    .font(.subheadline)
                Text("Summary: \(inquiry.summary ?? "No summary available")")
                    .font(.subheadline)
                Text("Full Transcript: \(inquiry.phone_call_transcript ?? "No transcript available")")
                    .font(.subheadline)
            }
        }
    }

    // MARK: - Make Call Function
    private func makeCall() {
        guard let inquiry = inquiry else {
            print("Inquiry is missing")
            return
        }

        guard let url = URL(string: "http://127.0.0.1:8000/call_moving_companies/?moving_company_number=\(inquiry.phone_number)&moving_company_id=\(inquiry.moving_company_id)&moving_query_id=\(inquiry.moving_query_id)") else {
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
                    let _ = try await supabase
                        .from("moving_inquiry")
                        .update(["in_progress": true])
                        .eq("id", value: inquiry.id)
                        .execute()
                } catch {
                    print("Error updating in_progress column: \(error)")
                }
            }
        }

        task.resume()
    }
}