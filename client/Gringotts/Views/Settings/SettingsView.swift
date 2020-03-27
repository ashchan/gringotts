//
// UDT Hackathon Project Gringotts by Team Goblins
// Copyright © 2020 Goblins. all rights reserved.
// 

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var store: Store
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        Form {
            Section {
                Text("API Server")
                TextField("API Server", text: $store.state.settings.apiServer)
            }

            Spacer()

            HStack {
                Spacer()

                Button(action: {
                    self.presentationMode.wrappedValue.dismiss()
                }) {
                    Text("OK")
                }
            }
        }
        .padding()
        .frame(width: 400, height: 300)
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView().environmentObject(Store())
    }
}
