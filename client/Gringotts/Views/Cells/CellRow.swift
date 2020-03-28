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
                    HStack {
                        Image(cell.coinType.icon)
                            .resizable()
                            .frame(width: 20, height: 20)
                        Text(cell.amountPerPeriod)
                            .font(.subheadline)
                        Spacer()
                    }

                    Text("Status: ")
                    +
                    Text(status.description + (status != .normal ? " (\(cell.due(tipNumber: tipNumber)))" : ""))
                        .foregroundColor(status.color)

                    Text("Lease period: ") + Text("#\(cell.leasePeriod)")
                    Text("Overdue period: ") + Text("#\(cell.overduePeriod)")
                    Text("Last payment time: ") + Text("#\(cell.lastPaymentTime)")
                }
                Spacer()
            }

            if showChangeDataForm {
                ChangeDataForm(isPresented: $showChangeDataForm, cell: cell)
            } else {
                HStack {
                    Text("Data: ")
                    Text(cell.dataMessage)
                }
                .padding(.vertical, 10)
            }

            Divider()

            if isHolder {
                if cell.canClaim(tipNumber: tipNumber) {
                    HStack(alignment: .center, spacing: 20) {
                        Spacer()

                        Button(action: {
                            self.store.claim(cell: self.cell)
                        }) {
                            ActionButton(image: "lock", title: "Claim")
                        }
                        .buttonStyle(ActionButtonStyle())
                    }
                    .padding()
                }
            } else {
                HStack(alignment: .center, spacing: 20) {
                    Spacer()

                    Button(action: {
                        self.showChangeDataForm.toggle()
                    }) {
                        ActionButton(image: "pencil", title: "Change data")
                    }
                    .buttonStyle(ActionButtonStyle())

                    Button(action: {
                        self.store.pay(cell: self.cell)
                    }) {
                        ActionButton(image: "unlock", title: "Pay")
                    }
                    .buttonStyle(ActionButtonStyle())
                }
                .padding()
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
