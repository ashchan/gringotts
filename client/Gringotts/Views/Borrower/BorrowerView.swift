//
// UDT Hackathon Project Gringotts by Team Goblins
// Copyright © 2020 Goblins. all rights reserved.
// 

import SwiftUI

struct BorrowerView: View {
    @EnvironmentObject var store: Store
    @State private var selectedCell: Cell?
    var cells: [Cell] = []

    var body: some View {
        NavigationView {
            if store.state.settings.builderAddress.isEmpty {
                Logo()
                    .padding()
                EmptyAccountView(prompt: "You haven't configured BUILDER account yet.")
                    .padding()
            } else {
                BorrowerMasterView()
                BorrowerDetailView()
            }
        }
    }
}

struct BorrowerView_Previews: PreviewProvider {
    static var previews: some View {
        BorrowerView()
    }
}
