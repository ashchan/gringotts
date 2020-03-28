//
// UDT Hackathon Project Gringotts by Team Goblins
// Copyright © 2020 Goblins. all rights reserved.
// 

import Foundation
import CKB

// Dummy key manager. Don't do nothing.
struct KeyManager {
    static func address(for privateKey: String) -> String {
        Utils.privateToAddress(privateKey, network: .mainnet)
    }

    static func pubkeyPash(for address: String) -> String {
        Utils.prefixHex(AddressGenerator.publicKeyHash(for: address) ?? "0x")
    }
}
