//
// UDT Hackathon Project Gringotts by Team Goblins
// Copyright © 2020 Goblins. all rights reserved.
// 

import SwiftUI
import Combine

struct RootView: View {
    @EnvironmentObject private var store: Store
    @State private var showSettingsView = false
    private let showSettingViewTriggered = NotificationCenter.default.publisher(for: .showSettingsView).receive(on: RunLoop.main)

    var body: some View {
        ZStack {
            HStack {
                if store.state.viewTab.selected == .borrower {
                    BorrowerView()
                } else if store.state.viewTab.selected == .market {
                    MarketView()
                } else {
                    LenderView()
                }
            }
        }
        .sheet(isPresented: $showSettingsView) {
            SettingsView().environmentObject(self.store)
        }
        .frame(minWidth: 640, minHeight: 320)
        .onReceive(showSettingViewTriggered) { _ in
            self.showSettingsView = true
        }
    }
}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView().environmentObject(Store())
    }
}
