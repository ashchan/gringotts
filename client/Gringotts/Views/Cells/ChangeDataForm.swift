//
// UDT Hackathon Project Gringotts by Team Goblins
// Copyright © 2020 Goblins. all rights reserved.
// 

import SwiftUI

struct ChangeDataForm: View {
    @EnvironmentObject var store: Store
    @Binding var isPresented: Bool
    var cell: Cell
    @State var data: String = ""

    var body: some View {
        Form {
            Text("Update cell data")
                .font(.caption)

            Section {
                HStack {
                    Text("Data")
                        .font(.caption)
                        .frame(width: 150, alignment: .trailing)
                    TextField("Input a message as data", text: $data)
                }
            }

            Divider()

            HStack {
                Spacer()

                Button("Cancel") {
                    self.cancel()
                }

                Button("Save") {
                    self.save()
                }
            }

            Spacer()
        }
        .padding()
        .background(Color("FormBackground"))
        .onAppear {
            self.data = self.cell.dataMessage
        }
    }
}

extension ChangeDataForm {
    func cancel() {
        isPresented = false
    }

    func save() {
        self.store.changeData(cell: self.cell, data: "0x" + data.data(using: .utf8)!.toHexString())
        isPresented = false
    }
}

struct ChangeDataForm_Previews: PreviewProvider {
    static var previews: some View {
        ChangeDataForm(isPresented: .constant(true), cell: Cell.samples[0])
    }
}
