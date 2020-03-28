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
            HStack {
                Text("Data: ")
                TextField("Input a message as data", text: $data)
                    .offset(x: -4, y: -1)
            }

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
