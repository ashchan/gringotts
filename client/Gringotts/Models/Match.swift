//
// UDT Hackathon Project Gringotts by Team Goblins
// Copyright © 2020 Goblins. all rights reserved.
// 

import Foundation

// To submit to matches/create
struct MatchData: Codable {
    let builderPubkeyHash: String
    let coinHash: String
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
        let leaseAmounts: String
        let tx: Transaction

        struct Info: Decodable {
            let builderPubkeyHash: String
            let coinHash: String
            let leasePeriod: String
            let overduePeriod: String
            let lastPaymentTime: String
        }
    }
}
