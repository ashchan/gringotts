//
// UDT Hackathon Project Gringotts by Team Goblins
// Copyright © 2020 Goblins. all rights reserved.
// 

import Foundation
import CKB
import secp256k1

// Dummy key manager. Don't do nothing.
struct KeyManager {
    static func address(for privateKey: String) -> String {
        Utils.privateToAddress(privateKey, network: .mainnet)
    }

    static func pubkeyPash(for address: String) -> String {
        Utils.prefixHex(AddressGenerator.publicKeyHash(for: address) ?? "0x")
    }

    static func sign(message: String, privateKey: String) -> String {
        let signed = Secp256k1.signRecoverable(privateKey: Data(hex: privateKey), data: Data(hex: message))!
        return Utils.prefixHex(signed.toHexString())
    }
}

extension SigningMessage {
    func sign(with privateKey: String) -> SignedMessage {
        SignedMessage(
            id: id,
            signatures: messagesToSign.map { KeyManager.sign(message: $0.message, privateKey: privateKey) }
        )
    }
}

extension Match {
    func sign(with privateKey: String) -> [String] {
        data.messagesToSign!.map { KeyManager.sign(message: $0.message, privateKey: privateKey) }
    }
}
