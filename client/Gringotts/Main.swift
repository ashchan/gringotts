//
// UDT Hackathon Project Gringotts by Team Goblins
// Copyright © 2020 Goblins. all rights reserved.
// 

import Cocoa
import SwiftUI

class HostingController: NSHostingController<RootView> {
    @objc required dynamic init?(coder: NSCoder) {
        super.init(coder: coder, rootView: RootView())
    }
}
