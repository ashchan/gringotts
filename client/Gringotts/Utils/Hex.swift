//
// UDT Hackathon Project Gringotts by Team Goblins
// Copyright © 2020 Goblins. all rights reserved.
// 

import Foundation

extension String {
    var numberFromHex: UInt64 {
        let text = starts(with: "0x") ? String(dropFirst(2)) : self
        return UInt64(text, radix: 16) ?? 0
    }
}
