//
// UDT Hackathon Project Gringotts by Team Goblins
// Copyright © 2020 Goblins. all rights reserved.
// 

import Foundation

struct Transaction: Codable {
    struct OutPoint: Codable, Hashable {
        let txHash: String
        let index: String
    }

    struct Script: Codable {
        let codeHash: String
        let hashType: String
        let args: String
    }
}
