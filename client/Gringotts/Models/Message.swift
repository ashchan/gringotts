//
// UDT Hackathon Project Gringotts by Team Goblins
// Copyright © 2020 Goblins. all rights reserved.
// 

import Foundation

struct SigningMessage: Codable {
    let id: String
    let messagesToSign: [Message]

    enum CodingKeys: String, CodingKey {
        case id
        case messagesToSign = "messagesToSign"
    }
}

struct SignedMessage: Codable {
    let id: String
    let signatures: [String]
}

struct Message: Codable {
    let index: Int
    let message: String
    let lock: Transaction.Script
}

struct SignMessageResult: Codable {
    let txHash: String
}

extension SigningMessage {
    static let sample: SigningMessage = try! JSONDecoder.apiDecoder.decode(
        SigningMessage.self,
        from: json.data(using: .utf8)!
    )
}

fileprivate let json = """
{
  "id": "aad2e272-7330-4c80-84c9-382c983b7906",
  "messagesToSign": [
    {
      "index": 0,
      "message": "0x450cd0eaa05644d350b414ffe3ac004848c97c31ef9ba5b0b88b9aed3f3c40c6",
      "lock": {
        "code_hash": "0x9bd7e06f3ecf4be0f2fcd2188b23f1b9fcc88e5d4b65a8637b17723bbda3cce8",
        "hash_type": "type",
        "args": "0x276f2fa3565a10c76164a5e92d4a0b699889ef48"
      }
    },
    {
      "index": 1,
      "message": "0x450cd0eaa05644d350b414ffe3ac004848c97c31ef9ba5b0b88b9aed3f3c40c6",
      "lock": {
        "code_hash": "0x3de0499b41e86df8ef3fb4a5712a9439ad42bf9dfeebcbd959daf7e1fac575bd",
        "hash_type": "data",
        "args": "0xc8328aabcd9b9e8e64fbc566c4385c3bdeb219d7276f2fa3565a10c76164a5e92d4a0b699889ef48000000000000000000000000000000000000000000000000000000000000000064000000000000006400000000000000870200000000000000c6941409000000"
      }
    }
  ]
}
"""
