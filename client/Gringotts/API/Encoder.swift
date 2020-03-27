//
// UDT Hackathon Project Gringotts by Team Goblins
// Copyright © 2020 Goblins. all rights reserved.
// 

import Foundation

extension JSONEncoder {
    static var apiEncoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        return encoder
    }()
}

extension Encodable {
    func toJSON() -> Data? {
        try? JSONEncoder.apiEncoder.encode(self)
    }
}
