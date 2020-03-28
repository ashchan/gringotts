//
// UDT Hackathon Project Gringotts by Team Goblins
// Copyright © 2020 Goblins. all rights reserved.
// 

import SwiftUI
import Combine

struct RootView: View {
    @EnvironmentObject private var store: Store
    @State private var showSettingsView = false
    @State private var message = ""
    private let showSettingViewTriggered = NotificationCenter.default.publisher(for: .showSettingsView).receive(on: RunLoop.main)
    private let messageReceived = NotificationCenter.default.publisher(for: .showMessage).receive(on: RunLoop.main)

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            HStack {
                if store.state.viewTab.selected == .market {
                    MarketView()
                } else {
                    CellsView()
                }
            }

            Text("#\(store.state.tipNumber)")
                .font(.system(size: 10, weight: .thin, design: .monospaced))
                .frame(width: 100, height: 20)
                .background(Color.white.opacity(0.8))
                .cornerRadius(3)

            if !message.isEmpty {
                VStack {
                    HStack {
                        Text(message)
                            .foregroundColor(.white)
                        Spacer()
                    }
                }
                .padding()
                .frame(minHeight: 42)
                .background(Color.green.opacity(0.8))
            }
        }
        .sheet(isPresented: $showSettingsView) {
            SettingsView().environmentObject(self.store)
        }
        .frame(minWidth: 700, minHeight: 320)
        .onReceive(showSettingViewTriggered) { _ in
            self.showSettingsView = true
        }
        .onReceive(messageReceived) { noti in
            self.message = (noti.userInfo?["message"] as? String) ?? ""
            _ = Just("")
                .delay(for: .seconds(3), scheduler: RunLoop.main)
                .sink {
                    self.message = $0
                }
        }
        .onAppear {
            self.store.updateTipNumberPublisher()
        }
    }
}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView().environmentObject(Store())
    }
}
