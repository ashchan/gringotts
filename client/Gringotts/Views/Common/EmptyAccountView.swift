//
// UDT Hackathon Project Gringotts by Team Goblins
// Copyright © 2020 Goblins. all rights reserved.
// 

import SwiftUI

struct EmptyAccountView: View {
    @EnvironmentObject var store: Store
    var prompt: String = "You haven't configured account yet."

    var body: some View {
        VStack() {
            Text(prompt)
                .font(.subheadline)

            Button(action: {
                self.store.showSettingsView()
            }) {
                Text("+ Add Your Account")
            }
        }
    }
}

struct EmptyAccountView_Previews: PreviewProvider {
    static var previews: some View {
        EmptyAccountView()
    }
}
