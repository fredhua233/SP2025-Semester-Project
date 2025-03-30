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
        let security_question: String?
        let security_answer_hash: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case user_id
        case full_name
        case email
        case security_question
        case security_answer_hash
    }
}

struct ProfileInsert: Codable {
    let user_id: UUID
    let email: String
    let full_name: String
    let security_question: String
    let security_answer_hash: String
}

enum SecurityQuestion: String, CaseIterable, Identifiable {
    case mothersMaiden = "What is your mother's maiden name?"
    case childhoodStreet = "What was your childhood home street address?"
    case firstCar = "What was your first car's make and model?"
    
    var id: String { self.rawValue }
}

//struct UserAttributes: Encodable {
//    let password: String?
//    let email: String?
//    
//    init(password: String? = nil, email: String? = nil) {
//        self.password = password
//        self.email = email
//    }
//}

struct UpdateProfileParams: Codable {
    let full_name: String?
    let email: String?
    
}
struct MovingCompany: Identifiable, Codable {
    let id: Int
    let name: String
    let phoneNumber: String
    let address: String
    let rating: Float
    let user_ratings_total: Int

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case phoneNumber = "phone_number" // Match Supabase column
        case address
        case rating
        case user_ratings_total
    }
}



struct MovingInquiry: Identifiable, Codable {
    let id: Int
    let moving_company_id: Int
    let created_at: String
    let price: Int?
    let phone_call_transcript: String?
    let moving_query_id: Int
    let phone_number: String
    let vapi_call_id: String?
    let in_progress: Bool
    let call_duration: Float?
    let summary: String?
    enum CodingKeys: String, CodingKey {
        case id
        case moving_company_id
        case created_at
        case price
        case phone_call_transcript
        case moving_query_id
        case phone_number
        case vapi_call_id
        case in_progress
        case call_duration
        case summary
    }
}

struct MovingQuery: Identifiable, Codable {
    let id: Int
    let location_from: String
    let location_to: String
    let created_at: String
    let items: String
    let items_details: String
    let availability: String
    let user_id: String
    enum CodingKeys: String, CodingKey {
        case id
        case location_from
        case location_to
        case created_at
        case items
        case items_details
        case availability
        case user_id
    }
}





/////
////  Profile.swift
////  RoboCallerMover
////
////  Created by Michelle Zheng on 2/25/25.
////
//
//import Foundation
//
//struct Profile: Codable {
//    let id: UUID?
//    let user_id: UUID
//    let full_name: String?
//    let email: String?
//    
//    enum CodingKeys: String, CodingKey {
//        case id
//        case user_id
//        case full_name
//        case email
//    }
//}
//
//struct UpdateProfileParams: Encodable {
//    let full_name: String
//    let email: String
//}
//
//struct ProfileInsert: Codable {
//    let user_id: UUID
//    let email: String
//}
//
//struct MovingCompany: Identifiable, Codable {
//    let id: Int
//    let name: String
//    let phoneNumber: String
//
//    enum CodingKeys: String, CodingKey {
//        case id
//        case name
//        case phoneNumber = "phone_number" // Match Supabase column
//    }
//}
//
//struct MovingInquiry: Identifiable, Codable {
//    let id: Int
//    let moving_company_id: Int
//    let created_at: String
//    let price: Int?
//    let phone_call_transcript: String
//    let moving_query_id: Int
//    let phone_number: String
//    let vapi_call_id: String?
//    let in_progress: Bool
//    let call_duration: Int?
//    let summary: String?
//    enum CodingKeys: String, CodingKey {
//        case id
//        case moving_company_id
//        case created_at
//        case price
//        case phone_call_transcript
//        case moving_query_id
//        case phone_number
//        case vapi_call_id
//        case in_progress
//        case call_duration
//        case summary
//    }
//}
//
//struct MovingQuery: Identifiable, Codable {
//    let id: Int
//    let location_from: String
//    let location_to: String
//    let created_at: String
//    let items: String
//    let items_details: String
//    let availability: String
//    let user_id: String
//    enum CodingKeys: String, CodingKey {
//        case id
//        case location_from
//        case location_to
//        case created_at
//        case items
//        case items_details
//        case availability
//        case user_id
//    }
//}
//
//
//
//
