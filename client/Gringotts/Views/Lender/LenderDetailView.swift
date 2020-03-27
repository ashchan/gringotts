//
// UDT Hackathon Project Gringotts by Team Goblins
// Copyright © 2020 Goblins. all rights reserved.
// 

import SwiftUI

struct LenderDetailView: View {
    @EnvironmentObject var store: Store

    var body: some View {
        List {
            if store.state.settings.holderAddress.isEmpty {
                HStack() {
                    Text("You haven't configured account yet.")
                        .font(.title)

                    Button(action: {
                        self.store.showSettingsView()
                    }) {
                        Text("+ Add Your Account")
                    }
                }
                .padding()
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
        LenderDetailView().environmentObject(Store())
    }
}
