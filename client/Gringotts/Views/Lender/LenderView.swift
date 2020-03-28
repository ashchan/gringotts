//
// UDT Hackathon Project Gringotts by Team Goblins
// Copyright © 2020 Goblins. all rights reserved.
// 

import SwiftUI

struct LenderView: View {
    @EnvironmentObject var store: Store
    @State private var selectedCell: Cell?
    var cells: [Cell] = []

    var body: some View {
        NavigationView {
            if store.state.settings.holderAddress.isEmpty {
                Logo()
                    .padding()
                EmptyAccountView(prompt: "You haven't configured HOLDER account yet.")
                    .padding()
            } else {
                LenderMasterView(selectedCell: $selectedCell)

                if selectedCell != nil {
                    LenderDetailView(cell: selectedCell!)
                }
            }
        }
    }
}

struct LenderView_Previews: PreviewProvider {
    static var previews: some View {
        LenderView(cells: Cell.samples)
    }
}
