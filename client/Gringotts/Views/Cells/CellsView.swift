//
// UDT Hackathon Project Gringotts by Team Goblins
// Copyright © 2020 Goblins. all rights reserved.
// 

import SwiftUI

struct CellsView: View {
    @EnvironmentObject var store: Store

    private var viewType: ViewType { store.state.viewTab.selected == .lender ? .holder : .builder }
    private var isHolder: Bool { viewType == .holder }
    private var address: String { isHolder ? store.state.settings.holderAddress : store.state.settings.builderAddress }

    var cells: [Cell] { isHolder ? store.state.holderCells : store.state.builderCells }

    var body: some View {
        ZStack {
            if address.isEmpty {
                HStack {
                    Spacer()
                    VStack {
                        Spacer()
                        Logo()
                            .padding()
                        EmptyAccountView(prompt: "You haven't configured \(viewType.rawValue.uppercased()) account yet.")
                            .padding()
                        Spacer()
                    }
                    Spacer()
                }
            } else {
                ScrollView {
                    HStack(alignment: .top) {
                        VStack(alignment: .leading) {
                            Text("\(self.store.state.balance.numberFromHex / 100_000_000)")
                                .font(.headline)
                            +
                            Text(" CKB")

                            Text(self.address)
                                .font(.system(.caption, design: .monospaced))
                        }

                        Spacer()

                        Button(action: {
                            self.refresh()
                        }) {
                            Text("Refresh")
                        }
                    }
                    .padding()

                    ForEach(cells) { cell in
                        CellRow(cell: cell, isHolder: self.isHolder)
                    }
                }
                .padding()
                .onAppear {
                    self.refreshIfNecessary()
                }
            }
        }
        .background(Color.white)
    }
}

extension CellsView {
    enum ViewType: String {
        case holder
        case builder
    }

    func refresh() {
        if isHolder {
            store.loadHolderCells()
        } else {
            store.loadBuilderCells()
        }
        store.loadBalance(address: address)
    }

    func refreshIfNecessary() {
        if cells.isEmpty || store.state.balance == "0" {
            refresh()
        }
    }
}

struct CellsView_Previews: PreviewProvider {
    static var previews: some View {
        CellsView().environmentObject(Store())
    }
}
