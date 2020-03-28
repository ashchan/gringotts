//
// UDT Hackathon Project Gringotts by Team Goblins
// Copyright © 2020 Goblins. all rights reserved.
// 

import SwiftUI

struct MatchForm: View {
    @EnvironmentObject var store: Store
    @State var leasePeriod = "200"
    @State var overduePeriod = "100"
    @State var amountPerPeriod = "5000000000"
    @State var leaseAmount = "100000000000"
    @State var coinType: Cell.CoinType = .ckb
    @Binding var isPresented: Bool

    var body: some View {
        Form {
            Text("Publish a match")
                .font(.title)

            Section {
                Picker(selection: $coinType, label: Text("Coin")) {
                    ForEach(Cell.CoinType.allCases) { type in
                        Text(type.description + " - " + type.coinHash)
                            .font(.system(.caption, design: .monospaced))
                            .tag(type)
                    }
                }
                Divider()
            }

            Section {
                HStack {
                    Text("Lease Period")
                        .font(.caption)
                        .frame(width: 150, alignment: .trailing)
                    TextField("Lease Period", text: $leasePeriod)
                }

                HStack {
                    Text("Overdue Period")
                        .font(.caption)
                        .frame(width: 150, alignment: .trailing)
                    TextField("Overdue Period", text: $overduePeriod)
                }

                HStack {
                    Text("Amount per Period")
                        .font(.caption)
                        .frame(width: 150, alignment: .trailing)
                    TextField("Amount per Period", text: $amountPerPeriod)
                }

                HStack {
                    Text("Lease Amount")
                        .font(.caption)
                        .frame(width: 150, alignment: .trailing)
                    TextField("Lease Amount", text: $leaseAmount)
                }
            }

            Divider()

            HStack {
                Spacer()

                Button(action: {
                    self.cancel()
                }) {
                    Text("Cancel")
                }

                Button(action: {
                    self.publish()
                }) {
                    Text("Publish")
                }
            }

            Spacer()
        }
        .padding()
        .background(Color("FormBackground"))
    }

    func cancel() {
        isPresented = false
    }

    func publish() {
        let data = MatchData(
            coinHash: coinType.coinHash,
            builderPubkeyHash: KeyManager.pubkeyHash(for: store.state.settings.builderAddress),
            leasePeriod: stringToU64Hex(text: leasePeriod),
            overduePeriod: stringToU64Hex(text: overduePeriod),
            amountPerPeriod: stringToU64Hex(text: amountPerPeriod),
            leaseAmounts: stringToU64Hex(text: leaseAmount)
        )
        store.createMatch(match: data)

        isPresented = false
    }

    func stringToU64Hex(text: String) -> String {
        let value = UInt64(text) ?? 0
        return value.hexString
    }
}

struct MatchForm_Previews: PreviewProvider {
    static var previews: some View {
        MatchForm(isPresented: .constant(true))
    }
}
