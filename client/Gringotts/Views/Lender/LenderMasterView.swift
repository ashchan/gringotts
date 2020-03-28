//
// UDT Hackathon Project Gringotts by Team Goblins
// Copyright © 2020 Goblins. all rights reserved.
// 

import SwiftUI

struct LenderMasterView: View {
    @Binding var selectedCell: Cell?

    var body: some View {
        VStack {
            List(selection: $selectedCell) {
                ForEach(Cell.samples) { cell in
                    CellRow(cell: cell).tag(cell)
                }
            }
            .listStyle(SidebarListStyle())
        }
        .frame(minWidth: 220, maxWidth: 400)
    }
}

struct LenderMasterView_Previews: PreviewProvider {
    static var previews: some View {
        LenderMasterView(selectedCell: .constant(Cell.samples[0]))
    }
}
