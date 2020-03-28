//
// UDT Hackathon Project Gringotts by Team Goblins
// Copyright © 2020 Goblins. all rights reserved.
// 

import SwiftUI

struct CellRow: View {
    var cell: Cell
    @State var tipNumber: UInt64

    var status: Cell.Status {
        cell.status(tipNumber: tipNumber)
    }

    var body: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading) {
                Text(cell.leaseInfo.amountPerPeriod)
                    .font(.subheadline)
                Text("Status: ") + Text(status.description)
                    .foregroundColor(status.color)

                Text("Lease period: ") + Text("#\(cell.leasePeriod)")
                Text("Overdue period: ") + Text("#\(cell.overduePeriod)")
                Text("Last payment time: ") + Text("#\(cell.lastPaymentTime)")
            }
            Spacer()
        }
        .padding(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(status.color, lineWidth: 4)
        )
        .padding(10)
    }
}

extension Cell.Status {
    var color: Color {
        return Color("CellStatus\(rawValue.capitalized)")
    }
}

struct CellRow_Previews: PreviewProvider {
    static var previews: some View {
        CellRow(cell: Cell.samples[0], tipNumber: 1_000)
    }
}
