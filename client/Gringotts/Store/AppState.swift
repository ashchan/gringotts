//
// UDT Hackathon Project Gringotts by Team Goblins
// Copyright © 2020 Goblins. all rights reserved.
// 

import Foundation

struct AppState {
    var viewTab = ViewTab()
    var settings = Settings()
}

extension AppState {
    struct ViewTab {
        enum Index: Hashable {
            case lender, borrower, market
        }

        var selected: Index = .lender
    }
}

extension AppState {
    struct Settings {
        @UserDefault("Settings.APIServer", defaultValue: "http://18.162.232.6:3000")
        var apiServer: String
    }
}
