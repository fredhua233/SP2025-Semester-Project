//
//  Transcript.swift
//  RoboCallerMover
//
//  Created by Michelle Zheng  on 2/18/25.
//

import Foundation

struct Transcript: Identifiable, Codable {
    var id = UUID() // Make `id` mutable
    let quoteID: UUID            // or some ID to link to the quote
    let content: String          // main text
    let date: Date?             // optional date/time of call
    // Add fields like “agentName,” “customerName,” “segments,” etc. if needed
}
