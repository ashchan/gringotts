//
// UDT Hackathon Project Gringotts by Team Goblins
// Copyright © 2020 Goblins. all rights reserved.
// 

import Foundation
import Combine

final class Store: ObservableObject {
    @Published var state = AppState()
    private var cancellables = Set<AnyCancellable>()

    init() {
    }
}

// Some actions
extension Store {
    func showSettingsView() {
        NotificationCenter.default.post(name: .showSettingsView, object: nil)
    }

    func testApiServer() {
        let client = Client(state.settings.apiServer)
        client.publisher(for: .holderCells(pubkeyHash: "0xc8328aabcd9b9e8e64fbc566c4385c3bdeb219d7"))
            .decode(type: [Cell].self, decoder: JSONDecoder.appDecoder)
            .print()
            .replaceError(with: [])
            .receive(on: DispatchQueue.main)
            .sink() {
                print($0)
            }
            .store(in: &cancellables)
    }
}

extension Notification.Name {
    static let showSettingsView = Notification.Name("showSettingsView")
}
