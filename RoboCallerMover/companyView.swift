import SwiftUI
import Supabase

struct CompanyView: View {
    let company: MovingCompany?

    var body: some View {
        VStack {
            if let company = company {
                Text("Company Name: \(company.name)")
                    .font(.title)
                Text("Phone: \(company.phoneNumber)")
                    .font(.subheadline)
            } else {
                Text("No company details available.")
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .navigationTitle("Company Details")
        .navigationBarTitleDisplayMode(.inline)
    }
}