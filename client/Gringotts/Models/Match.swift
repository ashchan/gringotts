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
    let lastPaymentTime: String
    let leaseAmounts: String
}

struct Match: Decodable, Identifiable {
    let id: String
    let data: Data

    struct Data: Decodable {
        let status: String
        let info: Info
        let leaseAmounts: String?
        let messagesToSign: [Message]?
        let nextMessagesToSign: [Message]?

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
            case nextMessagesToSign = "nextMessagesToSign"
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
    "tx": {
      "version": "0x0",
      "cell_deps": [
        {
          "dep_type": "dep_group",
          "out_point": {
            "tx_hash": "0xace5ea83c478bb866edf122ff862085789158f5cbff155b7bb5f13058555b708",
            "index": "0x0"
          }
        },
        {
          "dep_type": "code",
          "out_point": {
            "tx_hash": "0x677f4795b52dd1db044c8c2de7e7efe0f1711d769271064925b8eddf4a629252",
            "index": "0x0"
          }
        }
      ],
      "header_deps": [],
      "inputs": [
        {
          "previous_output": {
            "tx_hash": "0x2b33147c300dfe49972f18d88a413e18ed1b89009cfad341dcae26658b292cd1",
            "index": "0x2"
          },
          "since": "0x0"
        },
        {
          "previous_output": {
            "tx_hash": "0x1c4cf81fbd5bc698b6106a5f5163683acd0a9b51f4d7c9c853cdd12499bd46af",
            "index": "0x0"
          },
          "since": "0x0"
        },
        {
          "previous_output": {
            "tx_hash": "0x684a3c60c9e97060bd69df99f79b3c2984384f807178fce4d985b22bd7d6b867",
            "index": "0x0"
          },
          "since": "0x0"
        }
      ],
      "outputs": [
        {
          "capacity": "0x1bc15030f3507700",
          "lock": {
            "code_hash": "0x9bd7e06f3ecf4be0f2fcd2188b23f1b9fcc88e5d4b65a8637b17723bbda3cce8",
            "hash_type": "type",
            "args": "0xc8328aabcd9b9e8e64fbc566c4385c3bdeb219d7"
          },
          "type": null
        },
        {
          "capacity": "0x25b14b2fd9",
          "lock": {
            "code_hash": "0x9bd7e06f3ecf4be0f2fcd2188b23f1b9fcc88e5d4b65a8637b17723bbda3cce8",
            "hash_type": "type",
            "args": "0x276f2fa3565a10c76164a5e92d4a0b699889ef48"
          },
          "type": null
        }
      ],
      "outputs_data": [
        "0x",
        "0x"
      ],
      "witnesses": [
        "0x55000000100000005500000055000000410000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000",
        "0x",
        "0x55000000100000005500000055000000410000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000"
      ]
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
    ],
    "nextMessagesToSign": [
      {
        "index": 2,
        "message": "0x55493c0dd56bd00b35a8cb84654ddc52906589dae5f905f2240c36b3cd87786c",
        "lock": {
          "code_hash": "0x9bd7e06f3ecf4be0f2fcd2188b23f1b9fcc88e5d4b65a8637b17723bbda3cce8",
          "hash_type": "type",
          "args": "0x276f2fa3565a10c76164a5e92d4a0b699889ef48"
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
      "lease_amounts": "0x12309ce54000",
      "tx": {
        "inputs": [
          {
            "cell_output": {
              "capacity": "0x19ff6c8888",
              "lock": {
                "code_hash": "0x9bd7e06f3ecf4be0f2fcd2188b23f1b9fcc88e5d4b65a8637b17723bbda3cce8",
                "hash_type": "type",
                "args": "0x276f2fa3565a10c76164a5e92d4a0b699889ef48"
              },
              "type": null
            },
            "out_point": {
              "tx_hash": "0xa061140267e342a8c9f21bed227f151b4998bb057ed96da82e3b201b73318f0b",
              "index": "0x0"
            },
            "block_hash": "0xe062edcea1ffef07940af1bb9a53a4fe548ea04ada8629217df07284a84ae41a",
            "data": "0x"
          }
        ],
        "outputs": [
          {
            "cell_output": {
              "capacity": "0x10e4e1e188",
              "lock": {
                "code_hash": "0x9bd7e06f3ecf4be0f2fcd2188b23f1b9fcc88e5d4b65a8637b17723bbda3cce8",
                "hash_type": "type",
                "args": "0x276f2fa3565a10c76164a5e92d4a0b699889ef48"
              },
              "type": null
            },
            "data": null
          }
        ]
      }
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
      "lease_amounts": "0x12309ce54000",
      "tx": {
        "inputs": [
          {
            "cell_output": {
              "capacity": "0x2ecbd1ac29",
              "lock": {
                "code_hash": "0x9bd7e06f3ecf4be0f2fcd2188b23f1b9fcc88e5d4b65a8637b17723bbda3cce8",
                "hash_type": "type",
                "args": "0x276f2fa3565a10c76164a5e92d4a0b699889ef48"
              },
              "type": null
            },
            "out_point": {
              "tx_hash": "0x300aa7d906b27fb54e5a56dd6eed15cc69089c95c482126f86dfbccaa0b36019",
              "index": "0x0"
            },
            "block_hash": "0xa5afc0297e0c55c0e6394bec88101af004f01e3dfabb8a5c482aaca26273fec2",
            "data": "0x"
          }
        ],
        "outputs": [
          {
            "cell_output": {
              "capacity": "0x25b1470529",
              "lock": {
                "code_hash": "0x9bd7e06f3ecf4be0f2fcd2188b23f1b9fcc88e5d4b65a8637b17723bbda3cce8",
                "hash_type": "type",
                "args": "0x276f2fa3565a10c76164a5e92d4a0b699889ef48"
              },
              "type": null
            },
            "data": null
          }
        ]
      }
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
      "lease_amounts": "0x12309ce54000",
      "tx": {
        "inputs": [
          {
            "cell_output": {
              "capacity": "0x19ff6c84f7",
              "lock": {
                "code_hash": "0x9bd7e06f3ecf4be0f2fcd2188b23f1b9fcc88e5d4b65a8637b17723bbda3cce8",
                "hash_type": "type",
                "args": "0x276f2fa3565a10c76164a5e92d4a0b699889ef48"
              },
              "type": null
            },
            "out_point": {
              "tx_hash": "0x98db2d0fc2a51312be8c60b48cfec289caa2775ab2206ac6e2582c63996fb407",
              "index": "0x0"
            },
            "block_hash": "0x73f840030becc5d2fd0a9ac0ea75e5a050250361596896cb908681a5dca49fc1",
            "data": "0x"
          }
        ],
        "outputs": [
          {
            "cell_output": {
              "capacity": "0x10e4e1ddf7",
              "lock": {
                "code_hash": "0x9bd7e06f3ecf4be0f2fcd2188b23f1b9fcc88e5d4b65a8637b17723bbda3cce8",
                "hash_type": "type",
                "args": "0x276f2fa3565a10c76164a5e92d4a0b699889ef48"
              },
              "type": null
            },
            "data": null
          }
        ]
      }
    }
  }
]
"""
