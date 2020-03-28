//
// UDT Hackathon Project Gringotts by Team Goblins
// Copyright © 2020 Goblins. all rights reserved.
// 

import SwiftUI

struct CellRow: View {
    @EnvironmentObject var store: Store
    var cell: Cell
    var isHolder: Bool
    var tipNumber: UInt64 { store.state.tipNumber }
    @State var showChangeDataForm = false

    var status: Cell.Status {
        cell.status(tipNumber: tipNumber)
    }

    var body: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: 10) {
                    Text(cell.amountPerPeriod)
                        .font(.subheadline)

                    Text("Status: ")
                    +
                    Text(status.description)
                        .foregroundColor(status.color)
                    +
                    Text(status != .normal ? " (\(cell.due(tipNumber: tipNumber)))" : "")

                    Text("Lease period: ") + Text("#\(cell.leasePeriod)")
                    Text("Overdue period: ") + Text("#\(cell.overduePeriod)")
                    Text("Last payment time: ") + Text("#\(cell.lastPaymentTime)")
                }
                Spacer()
                VStack(alignment: .trailing) {
                    Image(cell.coinType.icon)
                        .resizable()
                        .frame(width: 40, height: 40)
                    Spacer()
                }
            }

            if showChangeDataForm {
                ChangeDataForm(isPresented: $showChangeDataForm, cell: cell)
                    .cornerRadius(10)
            } else {
                HStack {
                    Text("Data: ")
                    Text(cell.dataMessage)
                }
            }

            if isHolder {
                if cell.canClaim(tipNumber: tipNumber) {
                    HStack {
                        Button(action: {
                            self.store.claim(cell: self.cell)
                        }) {
                            Text("Claim")
                        }
                        Spacer()
                    }
                }
            } else {
                HStack {
                    Spacer()

                    Button(action: {
                        self.showChangeDataForm.toggle()
                    }) {
                        Text("Change data")
                    }

                    Button(action: {
                        self.store.pay(cell: self.cell)
                    }) {
                        Text("Pay")
                    }
                }
            }
        }
        .font(.custom("Helvetica", size: 14))
        .padding(10)
        .background(Color.white)
        .foregroundColor(.black)
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
        CellRow(cell: Cell.samples[0], isHolder: true)
    }
}
