//
// UDT Hackathon Project Gringotts by Team Goblins
// Copyright © 2020 Goblins. all rights reserved.
// 

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var store: Store
    @Environment(\.presentationMode) var presentationMode

    @State private var apiServer = ""
    @State private var holderAddress = ""
    @State private var builderAddress = ""
    @State private var errorMessage = ""

    var body: some View {
        Form {
            Section {
                HStack {
                    Text("API Server")
                        .font(.caption)
                        .frame(width: 100, alignment: .trailing)
                    TextField("API Server", text: $apiServer)
                }
            }

            Section {
                HStack {
                    Text("Holder Address")
                        .font(.caption)
                        .frame(width: 100, alignment: .trailing)
                    TextField("Holder Address", text: $holderAddress)
                }
            }

            Section {
                HStack {
                    Text("Builder Address")
                        .font(.caption)
                        .frame(width: 100, alignment: .trailing)
                    TextField("Builder Address", text: $builderAddress)
                }
            }

            Spacer().frame(minHeight: 30)

            Section {
                HStack {
                    if !errorMessage.isEmpty {
                        Text(errorMessage)
                            .foregroundColor(.red).opacity(0.9)
                    }
                }

                HStack {
                    Spacer()

                    Button(action: {
                        self.presentationMode.wrappedValue.dismiss()
                    }) {
                        Text("Cancel").frame(width: 50)
                    }

                    Button(action: {
                        if self.isFormValid {
                            self.presentationMode.wrappedValue.dismiss()
                            self.submit()
                        }
                    }) {
                        Text("OK").frame(width: 50)
                    }
                }
            }
        }
        .padding()
        .frame(minWidth: 500)
        .onAppear() {
            self.apiServer = self.store.state.settings.apiServer
            self.holderAddress = self.store.state.settings.holderAddress
            self.builderAddress = self.store.state.settings.builderAddress
        }
    }
}

private extension SettingsView {
    func submit() {
        store.state.settings.apiServer = apiServer
        store.state.settings.holderAddress = holderAddress
        store.state.settings.builderAddress = builderAddress
        store.updateClient()
    }

    var isFormValid: Bool {
        if !isApiServerValid {
            errorMessage = "Invalid API Server."
            return false
        }

        if !holderAddress.isEmpty && !isHolderAddressValid {
            errorMessage = "Invalid Holder Address."
            return false
        }

        if !builderAddress.isEmpty && !isBuilderAddressValid {
            errorMessage = "Invaid Builder Address."
            return false
        }

        return true
    }

    var isApiServerValid: Bool {
        let regexUrl = "((?:http|https)://)?(?:www\\.)?[\\w\\d\\-_]+\\.\\w{2,3}(\\.\\w{2})?(/(?<=/)(?:[\\w\\d\\-./_]+)?)?"
        let regexIp = "^http://(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)(:\\d+)?$"
        return NSPredicate(format:"SELF MATCHES %@", argumentArray:[regexUrl]).evaluate(with: apiServer) ||
            NSPredicate(format:"SELF MATCHES %@", argumentArray:[regexIp]).evaluate(with: apiServer)
    }

    var isHolderAddressValid: Bool {
        // TODO: check more
        return (holderAddress.starts(with: "ckt1qyq") || holderAddress.starts(with: "ckb1qy")) &&
            holderAddress.count == 46
    }

    var isBuilderAddressValid: Bool {
        // TODO: check more
        return (builderAddress.starts(with: "ckt1qyq") || builderAddress.starts(with: "ckb1qy")) &&
            builderAddress.count == 46
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView().environmentObject(Store())
    }
}
