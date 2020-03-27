//
// UDT Hackathon Project Gringotts by Team Goblins
// Copyright © 2020 Goblins. all rights reserved.
// 

import Foundation

struct Response<T>: Decodable where T: Decodable {
    let whatEver: String // TODO
}
