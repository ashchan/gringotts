//
// UDT Hackathon Project Gringotts by Team Goblins
// Copyright © 2020 Goblins. all rights reserved.
// 

import Foundation

struct Cell: Decodable, Identifiable, Hashable {
    let id: String
    let capacity: String
}
