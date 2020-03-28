//
// UDT Hackathon Project Gringotts by Team Goblins
// Copyright © 2020 Goblins. all rights reserved.
// 

import Foundation

struct Transaction: Codable {
    let txHash: String?
    let version: String?
    let inputs: [Input]
    let outputs: [Output]
    let cellDeps: [CellDep]?
    let headerDeps: [String]?
    let outputsData: [String]?
    let witnesses: [String]?

    struct Input: Codable {
        let previousOutput: OutPoint
        let since: String
    }

    struct Output: Codable {
        let capacity: String
        let lock: Script
        let type: String?
    }

    struct OutPoint: Codable, Hashable {
        let txHash: String
        let index: String
    }

    struct Script: Codable {
        let codeHash: String
        let hashType: String
        let args: String
    }

    struct CellDep: Codable {
        let depType: String
        let outPoint: OutPoint
    }
}
