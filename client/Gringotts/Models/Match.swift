//
// UDT Hackathon Project Gringotts by Team Goblins
// Copyright © 2020 Goblins. all rights reserved.
// 

import Foundation

// To submit to matches/create
struct MatchData: Codable {
    let coinHash: String
    let builderPubkeyHash: String
    let leasePeriod: String
    let overduePeriod: String
    let amountPerPeriod: String
    let leaseAmounts: String
}

struct Match: Decodable, Identifiable {
    let id: String
    let data: Data

    var coinType: Cell.CoinType { Cell.CoinType.from(coinHash: data.info.coinHash) }
    var status: String { data.status }

    var canOffer: Bool { status == "created" }
    var holderCanSign: Bool { status == "matched" }
    var builderCanSign: Bool { status == "sign_matched" }

    struct Data: Decodable {
        let status: String
        let info: Info
        let leaseAmounts: String?
        let messagesToSign: [Message]?

        struct Info: Decodable {
            let coinHash: String
            let builderPubkeyHash: String
            let holderPubkeyHash: String?
            let leasePeriod: String
            let overduePeriod: String
            let amountPerPeriod: String
            let lastPaymentTime: String?
        }

        enum CodingKeys: String, CodingKey {
            case status, info, leaseAmounts
            case messagesToSign = "messagesToSign"
        }
    }
}

extension Match {
    static let sample: Match = try! JSONDecoder.apiDecoder.decode(
        Match.self,
        from: json.data(using: .utf8)!
    )

    static let samples: [Match] = try! JSONDecoder.apiDecoder.decode(
        [Match].self,
        from: jsonCollestion.data(using: .utf8)!
    )
}

fileprivate let json = """
{
  "id": "3fb6c534-758e-45a2-af57-1ac775c43f9d",
  "data": {
    "status": "matched",
    "info": {
      "coin_hash": "0x0000000000000000000000000000000000000000000000000000000000000000",
      "builder_pubkey_hash": "0x276f2fa3565a10c76164a5e92d4a0b699889ef48",
      "lease_period": "0x64",
      "overdue_period": "0x64",
      "amount_per_period": "0x91494c600",
      "holder_pubkey_hash": "0xc8328aabcd9b9e8e64fbc566c4385c3bdeb219d7",
      "last_payment_time": "0x592"
    },
    "messagesToSign": [
      {
        "index": 0,
        "message": "0x5fb82d29cab7c9460bbcacf13dd5ef3cacb5582ad3b901675bb28f09a76ef73a",
        "lock": {
          "code_hash": "0x9bd7e06f3ecf4be0f2fcd2188b23f1b9fcc88e5d4b65a8637b17723bbda3cce8",
          "hash_type": "type",
          "args": "0xc8328aabcd9b9e8e64fbc566c4385c3bdeb219d7"
        }
      }
    ]
  }
}
"""

fileprivate let jsonCollestion = """
[
  {
    "id": "5278dcba-01dc-4007-8ee0-a9f17706bf10",
    "data": {
      "status": "created",
      "info": {
        "coin_hash": "0x0000000000000000000000000000000000000000000000000000000000000000",
        "builder_pubkey_hash": "0x276f2fa3565a10c76164a5e92d4a0b699889ef48",
        "lease_period": "0x64",
        "overdue_period": "0x64",
        "amount_per_period": "0x91494c600"
      },
      "lease_amounts": "0x12309ce54000"
    }
  },
  {
    "id": "bd75611e-fa7d-44c3-82ea-96a2fd2b0fcb",
    "data": {
      "status": "created",
      "info": {
        "coin_hash": "0x0000000000000000000000000000000000000000000000000000000000000000",
        "builder_pubkey_hash": "0x276f2fa3565a10c76164a5e92d4a0b699889ef48",
        "lease_period": "0x60",
        "overdue_period": "0x50",
        "amount_per_period": "0x91494c600"
      },
      "lease_amounts": "0x12309ce54000"
    }
  },
  {
    "id": "1b83a7b9-9388-4686-9e70-222a9afa02b3",
    "data": {
      "status": "created",
      "info": {
        "coin_hash": "0x0000000000000000000000000000000000000000000000000000000000000000",
        "builder_pubkey_hash": "0x276f2fa3565a10c76164a5e92d4a0b699889ef48",
        "lease_period": "0x64",
        "overdue_period": "0x64",
        "amount_per_period": "0x91494c600"
      },
      "lease_amounts": "0x12309ce54000"
    }
  }
]
"""
