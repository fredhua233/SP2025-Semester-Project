//
//  CallTranscriptCompanyView.swift
//  RoboCallerMover
//
//  Created by Michelle Zheng  on 2/4/25.
//

import SwiftUI

struct CallTranscriptCompanyView: View {
    let quote: Quote
    @State private var callTranscript: String = "Loading transcript..."

    var body: some View {
        VStack {
            Text("Call Transcript for \(quote.companyName)")
                .font(.largeTitle)
                .padding(.bottom, 20)

            TextEditor(text: $callTranscript)
                .frame(height: 300)
                .border(Color.gray.opacity(0.3))
                .padding()

            Spacer()
        }
        .padding(.horizontal)
        .onAppear {
            fetchCallTranscript()
        }
    }

    private func fetchCallTranscript() {
        // TODO: Fetch transcript from backend
        callTranscript = "This is a sample call transcript for \(quote.companyName)."
    }
}

struct CallTranscriptCompanyView_Previews: PreviewProvider {
    static var previews: some View {
        CallTranscriptCompanyView(quote: Quote(
            companyName: "ABC Corp",
            description: "Polite movers.",
            price: 50,
            iconName: "house",
            latitude: 38.6270,
            longitude: -90.1994
        ))
    }
}
