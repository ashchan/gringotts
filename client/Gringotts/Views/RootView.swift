//
// UDT Hackathon Project Gringotts by Team Goblins
// Copyright © 2020 Goblins. all rights reserved.
// 

import SwiftUI

struct RootView: View {
    private var showLenderView = false

    var body: some View {
        HStack {
            if showLenderView {
                LenderView()
            } else {
                BorrowerView()
            }
        }
    }
}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView()
    }
}
