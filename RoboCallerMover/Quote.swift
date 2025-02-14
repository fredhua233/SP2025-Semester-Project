//
//  Quote.swift
//  RoboCallerMover
//
//  Created by Michelle Zheng  on 2/13/25.
//

import Foundation
import CoreLocation //for use lat/long

struct Quote: Identifiable {
    let id = UUID()
    let companyName: String
    let description: String
    let price: Double
    let iconName: String
    let latitude: Double?   // optional if you have map coords
    let longitude: Double?  // optional if you have map coords
}
