//
// UDT Hackathon Project Gringotts by Team Goblins
// Copyright © 2020 Goblins. all rights reserved.
// 

import Foundation

struct SigningTx: Codable {
    let tx: Transaction
    let messagesToSign: [Message]
    let signatures: [String]?

    enum CodingKeys: String, CodingKey {
        case tx
        case signatures
        case messagesToSign = "messagesToSign"
    }
}

struct Message: Codable {
    let index: Int
    let message: String
    let lock: Transaction.Script
}

extension SigningTx {
    static let sample: SigningTx = try! JSONDecoder.apiDecoder.decode(
        SigningTx.self,
        from: json.data(using: .utf8)!
    )
}

fileprivate let json = """
{
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
          "tx_hash": "0x96ded6eae047cf6beccd8b324c090bc5bb55f16a1a8952036258081e7e10dc02",
          "index": "0x0"
        },
        "since": "0x0"
      },
      {
        "previous_output": {
          "tx_hash": "0x24ef00be3fcbc62547e1183ae595a0405ef32fbc238629c1c19d658cafd1df31",
          "index": "0x0"
        },
        "since": "0x0"
      }
    ],
    "outputs": [
      {
        "capacity": "0x2ec5df46b5",
        "lock": {
          "code_hash": "0x9bd7e06f3ecf4be0f2fcd2188b23f1b9fcc88e5d4b65a8637b17723bbda3cce8",
          "hash_type": "type",
          "args": "0x276f2fa3565a10c76164a5e92d4a0b699889ef48"
        },
        "type": null
      },
      {
        "capacity": "0x1d1a94a2000",
        "lock": {
          "code_hash": "0x3de0499b41e86df8ef3fb4a5712a9439ad42bf9dfeebcbd959daf7e1fac575bd",
          "hash_type": "data",
          "args": "0xc8328aabcd9b9e8e64fbc566c4385c3bdeb219d7276f2fa3565a10c76164a5e92d4a0b699889ef48000000000000000000000000000000000000000000000000000000000000000064000000000000006400000000000000c30100000000000000c817a804000000"
        },
        "type": null
      }
    ],
    "outputs_data": [
      "0x",
      "0x6368616e67656463656c6c64617461"
    ],
    "witnesses": [
      "0x55000000100000005500000055000000410000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000",
      "0x55000000100000005500000055000000410000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000"
    ]
  },
  "messagesToSign": [
    {
      "index": 0,
      "message": "0xd48e1bdc59e2cef442a5634da00fadbc15cb49357bd47ebc04c91031e5d47123",
      "lock": {
        "code_hash": "0x9bd7e06f3ecf4be0f2fcd2188b23f1b9fcc88e5d4b65a8637b17723bbda3cce8",
        "hash_type": "type",
        "args": "0x276f2fa3565a10c76164a5e92d4a0b699889ef48"
      }
    },
    {
      "index": 1,
      "message": "0xd48e1bdc59e2cef442a5634da00fadbc15cb49357bd47ebc04c91031e5d47123",
      "lock": {
        "code_hash": "0x3de0499b41e86df8ef3fb4a5712a9439ad42bf9dfeebcbd959daf7e1fac575bd",
        "hash_type": "data",
        "args": "0xc8328aabcd9b9e8e64fbc566c4385c3bdeb219d7276f2fa3565a10c76164a5e92d4a0b699889ef48000000000000000000000000000000000000000000000000000000000000000064000000000000006400000000000000c30100000000000000c817a804000000"
      }
    }
  ]
}
"""
