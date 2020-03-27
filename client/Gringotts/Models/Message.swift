//
// UDT Hackathon Project Gringotts by Team Goblins
// Copyright © 2020 Goblins. all rights reserved.
// 

import Foundation

struct SigningTx: Codable {
    let tx: Transaction
    let messagesToSign: [Message]
    let nextMessagesToSign: [Message]?
    let signatures: [String]?

    enum CodingKeys: String, CodingKey {
        case tx
        case signatures
        case messagesToSign = "messagesToSign"
        case nextMessagesToSign = "nextMessagesToSign"
    }
}

struct Message: Codable {
    let index: Int
    let message: String
    let lock: Transaction.Script
}
