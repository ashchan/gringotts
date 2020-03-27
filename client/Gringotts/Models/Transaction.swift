//
// UDT Hackathon Project Gringotts by Team Goblins
// Copyright © 2020 Goblins. all rights reserved.
// 

import Foundation

struct Transaction: Codable {
    let txHash: String?
    let version: String?
    let inputs: [Input] // TODO: different Input struct from matches/list and matches/sign_match
    let outputs: [Output]
    let cellDeps: [CellDep]?
    let headerDeps: [String]?
    let outputsData: [String]?
    let witnesses: [String]?

    struct CellInput: Codable {
        let previousOutput: OutPoint
        let since: String
    }

    struct Input: Codable {
        let cellOutput: CellOutput
        let outPoint: OutPoint
        let blockHash: String
        let data: String
    }

    struct Output: Codable {
        let cellOutput: CellOutput
        let data: String?
    }

    struct CellOutput: Codable {
        let capacity: String
        let lock: Script
        let type: String?
    }

    struct OutPoint: Codable {
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
