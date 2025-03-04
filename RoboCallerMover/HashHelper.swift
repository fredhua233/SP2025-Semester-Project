//
//  HashHelper.swift
//  RoboCallerMover
//
//  Created by Michelle Zheng  on 3/4/25.
//


import Foundation
import CryptoKit

extension String {
    func sha256WithStretching() -> String {
        var hash = SHA256.hash(data: Data(self.utf8))
        for _ in 0..<100_000 { hash = SHA256.hash(data: Data(hash)) }
        return hash.compactMap { String(format: "%02x", $0) }.joined()
    }
}