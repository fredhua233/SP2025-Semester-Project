//
//  Profile.swift
//  RoboCallerMover
//
//  Created by Michelle Zheng on 2/25/25.
//

import Foundation

struct Profile: Codable {
    let id: UUID?
    let user_id: UUID
    let full_name: String?
    let email: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case user_id
        case full_name
        case email
    }
}

struct UpdateProfileParams: Encodable {
    let full_name: String
    let email: String
}

struct ProfileInsert: Codable {
    let user_id: UUID
    let email: String
}

struct MovingCompany: Identifiable, Codable {
    let id: Int
    let name: String
    let phoneNumber: String

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case phoneNumber = "phone_number" // Match Supabase column
    }
}







