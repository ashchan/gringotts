//
// UDT Hackathon Project Gringotts by Team Goblins
// Copyright © 2020 Goblins. all rights reserved.
// 

import SwiftUI

struct BorrowerDetailView: View {
    @EnvironmentObject var store: Store

    var body: some View {
        List {
            if store.state.settings.builderAddress.isEmpty {
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
                Text("Builder Detail")
                    .font(.largeTitle)
                    .padding()
            }
        }
    }
}

struct BorrowerDetailView_Previews: PreviewProvider {
    static var previews: some View {
        BorrowerDetailView().environmentObject(Store())
    }
}
