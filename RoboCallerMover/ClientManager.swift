//
//  ClientManager.swift
//  RoboCallerMover
//
//  Created by Michelle Zheng  on 2/25/25.
//

import Supabase
import Foundation
import CryptoKit

final class ClientManager {
    static let shared = ClientManager()
       
       let client: SupabaseClient
       let adminClient: SupabaseClient
       
       init() {
           client = SupabaseClient(
               supabaseURL: URL(string: "https://trhnmlvipaujtmtvagbs.supabase.co")!,
               supabaseKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InRyaG5tbHZpcGF1anRtdHZhZ2JzIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDAwOTM0NzUsImV4cCI6MjA1NTY2OTQ3NX0.jRvPzrjGDnm7dTdXwUEVOKspvaR7NEHzqNYR_Shhqos"
           )
           
           adminClient = SupabaseClient(
               supabaseURL: URL(string: "https://trhnmlvipaujtmtvagbs.supabase.co")!,
               supabaseKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InRyaG5tbHZpcGF1anRtdHZhZ2JzIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDAwOTM0NzUsImV4cCI6MjA1NTY2OTQ3NX0.jRvPzrjGDnm7dTdXwUEVOKspvaR7NEHzqNYR_Shhqos"
           )
       }
       
       
    // MARK: - Security Question Operations
    func getSecurityQuestion(email: String) async throws -> String {
        let response = try await adminClient
            .from("profiles")
            .select("security_question")
            .eq("email", value: email)
            .single()
            .execute()
        
        let profile = try JSONDecoder().decode(Profile.self, from: response.data)
        return profile.security_question ?? "No security question set"
    }
    
    func verifySecurityAnswer(email: String, answer: String) async throws -> Bool {
        let response = try await adminClient
            .from("profiles")
            .select("security_answer_hash")
            .eq("email", value: email)
            .single()
            .execute()
        
        let profile = try JSONDecoder().decode(Profile.self, from: response.data)
        return profile.security_answer_hash == answer.sha256WithStretching()
    }
    
    func adminUpdatePassword(email: String, newPassword: String) async throws {
        let response = try await adminClient
            .from("profiles")
            .select("user_id")
            .eq("email", value: email)
            .single()
            .execute()
        
        let profile = try JSONDecoder().decode(Profile.self, from: response.data)
        
        try await supabase.auth.update(user: UserAttributes(password: newPassword))
    }
    
    func updateSecurityQuestion(userId: UUID, question: String, answer: String) async throws {
        try await adminClient
            .from("profiles")
            .update([
                "security_question": question,
                "security_answer_hash": answer.sha256WithStretching()
            ])
            .eq("user_id", value: userId)
            .execute()
    }
}

let supabase = ClientManager.shared.client

extension String {
    func sha256WithStretching() -> String {
        var hash = SHA256.hash(data: Data(self.utf8))
        for _ in 0..<100_000 { hash = SHA256.hash(data: Data(hash)) }
        return hash.compactMap { String(format: "%02x", $0) }.joined()
    }
}


////
////  ClientManager.swift
////  RoboCallerMover
////
////  Created by Michelle Zheng  on 2/25/25.
////
//
//import Supabase
//import Foundation
//
//let supabase = SupabaseClient(
//  supabaseURL: URL(string: "https://trhnmlvipaujtmtvagbs.supabase.co")!,
//  supabaseKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InRyaG5tbHZpcGF1anRtdHZhZ2JzIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDAwOTM0NzUsImV4cCI6MjA1NTY2OTQ3NX0.jRvPzrjGDnm7dTdXwUEVOKspvaR7NEHzqNYR_Shhqos"
//)
