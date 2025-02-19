//
//  APImanager.swift
//  RoboCallerMover
//
//  Created by Michelle Zheng  on 2/4/25.
//

import Foundation

class APIManager {
    static let shared = APIManager()

    private init() {}

    func fetchCallTranscript(location: String, completion: @escaping (String?) -> Void) {
        // TODO: Implement API call
        completion("Sample transcript for \(location)")
    }

    func authenticate(username: String, password: String, completion: @escaping (Bool) -> Void) {
        // TODO: Implement API call
        completion(username == "user" && password == "password")
    }
}
