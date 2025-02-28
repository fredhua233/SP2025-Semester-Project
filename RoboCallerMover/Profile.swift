//
//  Profile.swift
//  RoboCallerMover
//
//  Created by Michelle Zheng on 2/25/25.
//

import Foundation

struct Profile: Decodable {
    let username: String?
    let fullName: String?
    let email: String?
    let password: String?

    enum CodingKeys: String, CodingKey {
        case username
        case fullName = "full_name"
        case email
        case password
    }
}

struct UpdateProfileParams: Encodable {
    let username: String
    let fullName: String
    let email: String
    let password: String

    enum CodingKeys: String, CodingKey {
        case username
        case fullName = "full_name"
        case email
        case password
    }
}
