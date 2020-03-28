//
// UDT Hackathon Project Gringotts by Team Goblins
// Copyright © 2020 Goblins. all rights reserved.
// 

import Foundation

struct AppState {
    var viewTab = ViewTab()
    var settings = Settings()

    var tipNumber = UInt64(0)
    var balance = "0"

    var holderCells: [Cell] = []
    var builderCells: [Cell] = []
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

        @UserDefault("Settings.HolderAddress", defaultValue: "")
        var holderAddress: String

        @UserDefault("Settings.BuilderAddress", defaultValue: "")
        var builderAddress: String

        #warning("Keys: Private keys are hardcoded for DEMO only. Do not use your real private keys!")
        @UserDefault("Settings.HolderPrivateKey", defaultValue: "")
        var holderPrivatekey: String

        var holder1PrivateKey: String { "0xd00c06bfd800d27397002dca6fb0993d5ba6399b4238b2f29ee9deb97593d2bc" } // pub hash: 0xc8328aabcd9b9e8e64fbc566c4385c3bdeb219d7
        var holder2PrivateKey: String { "0x63d86723e08f0f813a36ce6aa123bb2289d90680ae1e99d4de8cdb334553f24d" } // pub hash: 0x470dcdc5e44064909650113a274b3b36aecb6dc7
        var builderPrivateKey: String { "0xc132966fa84d33fdbe1aec7ecc8e00b9192941123a7f2fa4b3c3e668110181b7" } // pub hash: 0x276f2fa3565a10c76164a5e92d4a0b699889ef48
    }
}
