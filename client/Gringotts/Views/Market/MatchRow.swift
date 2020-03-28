//
// UDT Hackathon Project Gringotts by Team Goblins
// Copyright © 2020 Goblins. all rights reserved.
// 

import SwiftUI

struct MatchRow: View {
    @EnvironmentObject var store: Store
    var match: Match
    var holderAddress: String { store.state.settings.holderAddress }
    var builderAddress: String { store.state.settings.builderAddress }

    var body: some View {
        VStack {
            HStack(alignment: .center) {
                VStack(alignment: .leading) {
                    Text("ID: ") + Text(match.id)
                    Text("Status: ") + Text(match.data.status)
                }

                HStack(alignment: .center) {
                    Spacer()
                    VStack(alignment: .trailing) {
                        Image(match.coinType.icon)
                            .resizable()
                            .frame(width: 20, height: 20)
                        Spacer()
                    }
                }
            }

            HStack {
                if !holderAddress.isEmpty {
                    if match.canOffer {
                        Button(action: {
                            self.takeMatch()
                        }) {
                            Text("Offer")
                        }
                    }

                    if match.holderCanSign && match.data.info.holderPubkeyHash == KeyManager.pubkeyHash(for: holderAddress) {
                        Button(action: {
                            self.signMatch()
                        }) {
                            Text("Sign (Holder)")
                        }
                    }
                }

                if !builderAddress.isEmpty {
                    if match.builderCanSign && match.data.info.builderPubkeyHash == KeyManager.pubkeyHash(for: builderAddress) {
                        Button(action: {
                            self.confirm()
                        }) {
                            Text("Sign & Confirm")
                        }
                    }
                }

                Spacer()
            }

            Divider()
        }
        .padding()
    }
}

extension MatchRow {
    // Holder offer and confirm
    private func takeMatch() {
        store.takeMatch(id: match.id)
    }

    private func signMatch() {
        store.signMatch(match: match)
    }

    // Builder sign
    private func confirm() {
        store.signConfirm(match: match)
    }
}

struct MatchRow_Previews: PreviewProvider {
    static var previews: some View {
        MatchRow(match: Match.sample)
            .environmentObject(Store())
    }
}
