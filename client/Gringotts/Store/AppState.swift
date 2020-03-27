//
// UDT Hackathon Project Gringotts by Team Goblins
// Copyright © 2020 Goblins. all rights reserved.
// 

import Foundation

struct AppState {
    var viewTab = ViewTab()
}

extension AppState {
    struct ViewTab {
        enum Index: Hashable {
            case lender, borrower, market
        }

        var selected: Index = .lender
    }
}
