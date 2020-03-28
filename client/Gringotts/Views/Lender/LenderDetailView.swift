//
// UDT Hackathon Project Gringotts by Team Goblins
// Copyright © 2020 Goblins. all rights reserved.
// 

import SwiftUI

struct LenderDetailView: View {
    @EnvironmentObject var store: Store
    var cell: Cell

    var body: some View {
        List {
            if store.state.settings.holderAddress.isEmpty {
            } else {
                Text("Holder Detail")
                    .font(.largeTitle)
                    .padding()
            }
        }
    }
}

struct LenderDetailView_Previews: PreviewProvider {
    static var previews: some View {
        LenderDetailView(cell: Cell.samples[0]).environmentObject(Store())
    }
}
