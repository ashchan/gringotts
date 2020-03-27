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
