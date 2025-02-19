//
//  Created by Michelle Zheng  on 2/4/25.
//

import SwiftUI
import MapKit

struct QuoteResultsView: View {
    let fromLocation: String
    let toLocation: String
    let items: String
    let availability: String
    let quotes: [Quote]

    @State private var selectedQuote: Quote? = nil

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // Move details at the top
                    moveDetailsSection

                    // Map showing the locations of the companies
                    mapSection

                    // Table of quotes
                    quotesSection
                }
                .padding(.vertical)
            }
            .navigationTitle("Move from \(fromLocation) to \(toLocation)")
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(isPresented: Binding<Bool>(
                get: { selectedQuote != nil },
                set: { if !$0 { selectedQuote = nil } }
            )) {
                if let selectedQuote = selectedQuote {
                    CallTranscriptCompanyView(quote: selectedQuote)
                }
            }
        }
    }

    // MARK: - Subviews

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

    private var mapSection: some View {
        Map(initialPosition: .region(MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 38.6270, longitude: -90.1994),
            span: MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2)
        ))) {
            ForEach(quotes.filter { $0.latitude != nil && $0.longitude != nil }) { quote in
                Marker(quote.companyName, coordinate: CLLocationCoordinate2D(
                    latitude: quote.latitude!,
                    longitude: quote.longitude!
                ))
            }
        }
        .frame(height: 200)
        .cornerRadius(8)
        .padding(.horizontal)
    }

    private var quotesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Quotes")
                .font(.headline)
                .padding(.horizontal)

            ForEach(quotes) { quote in
                quoteRow(quote: quote)
            }
        }
    }

    private func quoteRow(quote: Quote) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: quote.iconName)
                    .resizable()
                    .frame(width: 40, height: 40)
                    .foregroundColor(.blue)

                VStack(alignment: .leading) {
                    Text(quote.companyName)
                        .font(.headline)
                    Text(quote.description)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                Spacer()
                Text("$\(Int(quote.price))")
                    .font(.headline)
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(8)
            .onTapGesture {
                selectedQuote = quote
            }
        }
        .padding(.horizontal)
    }
}


struct QuoteResultsView_Previews: PreviewProvider {
    static var previews: some View {
        QuoteResultsView(
            fromLocation: "St. Louis",
            toLocation: "Boston",
            items: "2 sofas, 5 boxes",
            availability: "Feb 20, 10AM",
            quotes: [
                Quote(
                    companyName: "ABC Corp",
                    description: "Polite movers.",
                    price: 50,
                    iconName: "house",
                    latitude: 38.6270,
                    longitude: -90.1994
                ),
                Quote(
                    companyName: "XYZ Ltd",
                    description: "Affordable packing.",
                    price: 70,
                    iconName: "shippingbox",
                    latitude: 42.3601,
                    longitude: -71.0589
                )
            ]
        )
    }
}
