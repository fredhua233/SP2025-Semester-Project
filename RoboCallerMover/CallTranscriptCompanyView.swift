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
        ZStack {
                Color("background").ignoresSafeArea()

                VStack(spacing: 20) {
                    Text("Call Transcript for \(quote.companyName)")
                        .font(.title)
                        .bold()
                        .multilineTextAlignment(.center)
                        .foregroundColor(Color("MovingBlue"))
                        .padding(.horizontal, 24)
                        .padding(.top, 40)

                    TextEditor(text: $callTranscript)
                        .frame(height: 300)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(10)
                        .shadow(radius: 1)
                        .padding(.horizontal, 24)

                    Spacer()

                    Image("movingLogo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 80, height: 80)
                        .padding(.bottom, 20)
                }
                .padding(.horizontal, 24)
            }
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
