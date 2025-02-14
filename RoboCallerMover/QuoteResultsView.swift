import SwiftUI
import MapKit

struct QuoteResultsView: View {
    // MARK: - Inputs from the previous screen
    let fromLocation: String
    let toLocation: String
    let items: String
    let availability: String
    
    // MARK: - Quotes array (using your separate Quote model)
    let quotes: [Quote]
    
    // Optional: region for a SwiftUI map
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 38.6270, longitude: -90.1994),
        span: MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2)
    )

    // Filter out any quotes missing lat/long for map markers
    private var filteredQuotes: [Quote] {
        quotes.filter { $0.latitude != nil && $0.longitude != nil }
    }

    var body: some View {
        VStack(spacing: 0) {
            // Use the filteredQuotes for map annotations:
            Map(coordinateRegion: $region, annotationItems: filteredQuotes) { quote in
                // Force-unwrap is safe here because we filtered
                MapMarker(coordinate: CLLocationCoordinate2D(
                    latitude: quote.latitude!,
                    longitude: quote.longitude!
                ))
            }
            .frame(height: 200)
            
            Text("Quotes")
                .font(.headline)
                .padding(.vertical, 8)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
            
            // Show all quotes in a list
            List(quotes) { quote in
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
                .padding(.vertical, 4)
            }
            .listStyle(.plain)
        }
        .navigationTitle("Move from \(fromLocation) to \(toLocation)")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Preview
struct QuoteResultsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            QuoteResultsView(
                fromLocation: "St. Louis",
                toLocation: "Boston",
                items: "2 sofas, 5 boxes",
                availability: "Feb 20, 10AM",
                quotes: [
                    // Example data
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
                    ),
                    Quote(
                        companyName: "NoCoord Movers",
                        description: "Can't be pinned on the map.",
                        price: 40,
                        iconName: "mappin",
                        latitude: nil,
                        longitude: nil
                    )
                ]
            )
        }
    }
}
