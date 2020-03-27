//
// UDT Hackathon Project Gringotts by Team Goblins
// Copyright © 2020 Goblins. all rights reserved.
// 

import Foundation

struct Cell: Decodable, Identifiable {
    let leaseInfo: LeaseInfo
    let outPoint: Transaction.OutPoint
    let data: String?

    var id: String { outPoint.txHash + outPoint.index }
}

struct LeaseInfo: Decodable {
    let holderPubkeyHash: String
    let builderPubkeyHash: String
    let coinHash: String
    let leasePeriod: String
    let overduePeriod: String
    let lastPaymentTime: String
    let amountPerPeriod: String
}

extension Cell {
    static let samples: [Cell] = try! JSONDecoder.apiDecoder.decode(
        [Cell].self,
        from: json.data(using: .utf8)!
    )
}

fileprivate let json = """
[
{
"lease_info": {
"holder_pubkey_hash": "0xc8328aabcd9b9e8e64fbc566c4385c3bdeb219d7",
"builder_pubkey_hash": "0x276f2fa3565a10c76164a5e92d4a0b699889ef48",
"coin_hash": "0x0000000000000000000000000000000000000000000000000000000000000000",
"lease_period": "0x64",
"overdue_period": "0x32",
"last_payment_time": "0x8",
"amount_per_period": "0x77359400"
},
"out_point": {
"tx_hash": "0xd39fc1d94e075e5b6416374c2676682235e53f255fe13cfb4d627bdc83185d0c",
"index": "0x0"
},
"data": "0x746869736973616c6561736563656c6c"
},
{
"lease_info": {
"holder_pubkey_hash": "0xc8328aabcd9b9e8e64fbc566c4385c3bdeb219d7",
"builder_pubkey_hash": "0x276f2fa3565a10c76164a5e92d4a0b699889ef48",
"coin_hash": "0x0000000000000000000000000000000000000000000000000000000000000000",
"lease_period": "0x64",
"overdue_period": "0x46",
"last_payment_time": "0xc",
"amount_per_period": "0x9502f900"
},
"out_point": {
"tx_hash": "0x145fcf4f10f9d286e5d0afbc56b92e53e9b9a65a0c9001504b25797c76c9b356",
"index": "0x0"
},
"data": "0x746869736973616c6561736563656c6c"
},
{
"lease_info": {
"holder_pubkey_hash": "0xc8328aabcd9b9e8e64fbc566c4385c3bdeb219d7",
"builder_pubkey_hash": "0x276f2fa3565a10c76164a5e92d4a0b699889ef48",
"coin_hash": "0x0000000000000000000000000000000000000000000000000000000000000000",
"lease_period": "0x6e",
"overdue_period": "0x4c",
"last_payment_time": "0x10",
"amount_per_period": "0xa6e49c00"
},
"out_point": {
"tx_hash": "0x7c3fa1494e82c937ff424d46102c57252fa9437be4d9e9e4abf4b28e4090b0ef",
"index": "0x0"
},
"data": "0x746869736973616c6561736563656c6c"
},
{
"lease_info": {
"holder_pubkey_hash": "0xc8328aabcd9b9e8e64fbc566c4385c3bdeb219d7",
"builder_pubkey_hash": "0x276f2fa3565a10c76164a5e92d4a0b699889ef48",
"coin_hash": "0x0000000000000000000000000000000000000000000000000000000000000000",
"lease_period": "0x78",
"overdue_period": "0x1e",
"last_payment_time": "0x18",
"amount_per_period": "0x4a817c800"
},
"out_point": {
"tx_hash": "0xd051cd984b54d592705b766d852c701dbebbbf10b50f9a5587859245f9d1d19d",
"index": "0x0"
},
"data": "0x746869736973616c6561736563656c6c"
},
{
"lease_info": {
"holder_pubkey_hash": "0xc8328aabcd9b9e8e64fbc566c4385c3bdeb219d7",
"builder_pubkey_hash": "0x276f2fa3565a10c76164a5e92d4a0b699889ef48",
"coin_hash": "0x0000000000000000000000000000000000000000000000000000000000000000",
"lease_period": "0xc8",
"overdue_period": "0x64",
"last_payment_time": "0x1c",
"amount_per_period": "0x6c088e200"
},
"out_point": {
"tx_hash": "0x99b4dde0b39664ab988cea2daadc979eb2649d684df66a93f8a31431609f6875",
"index": "0x0"
},
"data": "0x746869736973616c6561736563656c6c"
},
{
"lease_info": {
"holder_pubkey_hash": "0xc8328aabcd9b9e8e64fbc566c4385c3bdeb219d7",
"builder_pubkey_hash": "0x276f2fa3565a10c76164a5e92d4a0b699889ef48",
"coin_hash": "0x0000000000000000000000000000000000000000000000000000000000000000",
"lease_period": "0x96",
"overdue_period": "0x46",
"last_payment_time": "0x14",
"amount_per_period": "0x83215600"
},
"out_point": {
"tx_hash": "0xc7a0777c23a343479b213720ab79f124d2509963cb04e674ef9c7132ef8191c1",
"index": "0x0"
},
"data": "0x746869736973616c6561736563656c6c"
}
]
"""

