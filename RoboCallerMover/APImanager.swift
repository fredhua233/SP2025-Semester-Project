//
//  APImanager.swift
//  RoboCallerMover
//
//  Created by Michelle Zheng  on 2/4/25.
//

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

    // MARK: - Get Moving Companies
    func getMovingCompanies(
        request: SearchRequest,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        guard let url = URL(string: "http://127.0.0.1:8000/get_moving_companies/") else {
            let err = NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey : "Invalid URL"])
            completion(.failure(err))
            return
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")

        // Encode the request body using SearchRequest
        do {
            let jsonData = try JSONEncoder().encode(request)
            urlRequest.httpBody = jsonData
        } catch {
            completion(.failure(error))
            return
        }

        URLSession.shared.dataTask(with: urlRequest) { data, response, error in
            // 1) Networking error
            if let error = error {
                completion(.failure(error))
                return
            }

            // 2) Check status code
            guard let httpResponse = response as? HTTPURLResponse else {
                let err = NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey : "No HTTP response"])
                completion(.failure(err))
                return
            }
            if !(200...299).contains(httpResponse.statusCode) {
                let msg = "Server returned status code: \(httpResponse.statusCode)"
                let err = NSError(domain: "", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey : msg])
                completion(.failure(err))
                return
            }

            // 3) Check data
            guard let data = data else {
                let err = NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey : "No data received"])
                completion(.failure(err))
                return
            }

            // 4) Convert the response data to a string
            if let responseString = String(data: data, encoding: .utf8) {
                completion(.success(responseString))
            } else {
                let err = NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey : "Failed to decode response as string"])
                completion(.failure(err))
            }
        }.resume()
    }

    // MARK: - Call Moving Company
    func callMovingCompany(
        moving_company_number: String,
        request: CallMovingCompanyRequest,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        // Construct the URL with a query parameter
        var components = URLComponents(string: "https://your-backend-api.com/call_moving_companies/")!
        components.queryItems = [
            URLQueryItem(name: "moving_company_number", value: moving_company_number)
        ]

        guard let url = components.url else {
            let err = NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey : "Invalid URL"])
            completion(.failure(err))
            return
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")

        // Encode the request body using CallMovingCompanyRequest
        do {
            let jsonData = try JSONEncoder().encode(request)
            urlRequest.httpBody = jsonData
        } catch {
            completion(.failure(error))
            return
        }

        URLSession.shared.dataTask(with: urlRequest) { data, response, error in
            // 1) Networking error
            if let error = error {
                completion(.failure(error))
                return
            }

            // 2) Check status code
            guard let httpResponse = response as? HTTPURLResponse else {
                let err = NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey : "No HTTP response"])
                completion(.failure(err))
                return
            }
            if !(200...299).contains(httpResponse.statusCode) {
                let msg = "Server returned status code: \(httpResponse.statusCode)"
                let err = NSError(domain: "", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey : msg])
                completion(.failure(err))
                return
            }

            // 3) Check data
            guard let data = data else {
                let err = NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey : "No data received"])
                completion(.failure(err))
                return
            }

            // 4) Convert data to a string
            if let responseString = String(data: data, encoding: .utf8) {
                completion(.success(responseString))
            } else {
                let err = NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey : "Failed to decode response as string"])
                completion(.failure(err))
            }
        }.resume()
    }
}

// MARK: - Request Structs

struct SearchRequest: Codable {
    let location_from: String
    let location_to: String
    let created_at: String
    let items: String
    let items_details: String
    let availability: String
    let user_id: String?
    let inquiries: [Int]
}

struct CallMovingCompanyRequest: Codable {
    let location_from: String
    let location_to: String
    let created_at: String
    let items: String
    let items_details: String
    let availability: String
    let user_id: String
    let inquiries: [Int]
}
