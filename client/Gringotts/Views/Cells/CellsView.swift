//
// UDT Hackathon Project Gringotts by Team Goblins
// Copyright © 2020 Goblins. all rights reserved.
// 

import SwiftUI

struct CellsView: View {
    @EnvironmentObject var store: Store
    @State private var selectedCell: Cell?

    var viewType: ViewType {
        store.state.viewTab.selected == .lender ? .holder : .builder
    }

    var address: String {
        return viewType == .holder ? store.state.settings.holderAddress : store.state.settings.builderAddress
    }

    var cells: [Cell] = []

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
                List(selection: $selectedCell) {
                    ForEach(Cell.samples) { cell in
                        CellRow(cell: cell, tipNumber: self.store.state.tipNumber).tag(cell)
                    }
                }
            }
        }
    }
}

extension CellsView {
    enum ViewType: String {
        case holder
        case builder
    }
}

struct CellsView_Previews: PreviewProvider {
    static var previews: some View {
        CellsView(cells: Cell.samples).environmentObject(Store())
    }
}
