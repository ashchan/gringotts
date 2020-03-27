//
// UDT Hackathon Project Gringotts by Team Goblins
// Copyright © 2020 Goblins. all rights reserved.
// 

import SwiftUI

struct RootView: View {
    @EnvironmentObject private var store: Store

    var body: some View {
        HStack {
            if store.state.viewTab.selected == .borrower {
                BorrowerView()
            } else if store.state.viewTab.selected == .market {
                MarketView()
            } else {
                LenderView()
            }
        }
        .frame(minWidth: 640, minHeight: 320)
    }
}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView().environmentObject(Store())
    }
}
