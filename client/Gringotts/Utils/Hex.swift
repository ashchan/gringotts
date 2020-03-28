//
// UDT Hackathon Project Gringotts by Team Goblins
// Copyright © 2020 Goblins. all rights reserved.
// 

import Foundation

extension String {
    var numberFromHex: UInt64 {
        let text = String(dropFirst(2))
        return UInt64(text, radix: 16) ?? 0
    }
}
