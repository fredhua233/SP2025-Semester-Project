//
//  Quote.swift
//  RoboCallerMover
//
//  Created by Michelle Zheng  on 2/13/25.
//

import Foundation
import CoreLocation

struct Quote: Identifiable, Decodable {
    var id = UUID() // Ensure this is unique
    let companyName: String
    let description: String
    let price: Double
    let iconName: String
    let latitude: Double?
    let longitude: Double?
}
