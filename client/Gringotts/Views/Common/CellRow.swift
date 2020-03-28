//
// UDT Hackathon Project Gringotts by Team Goblins
// Copyright © 2020 Goblins. all rights reserved.
// 

import SwiftUI

struct CellRow: View {
    var cell: Cell

    var body: some View {
        HStack(alignment: .center) {
            Text(cell.id)
        }
    }
}

struct CellRow_Previews: PreviewProvider {
    static var previews: some View {
        CellRow(cell: Cell.samples[0])
    }
}
