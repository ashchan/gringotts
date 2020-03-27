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
        client.publisher(for: .holderCells(pubkeyHash: "0x32e555f3ff8e135cece1351a6a2971518392c1e30375c1e006ad0ce8eac07947"))
            .decode(type: [Cell].self, decoder: JSONDecoder.appDecoder)
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
