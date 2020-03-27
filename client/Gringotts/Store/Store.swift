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
}

extension Notification.Name {
    static let showSettingsView = Notification.Name("showSettingsView")
}
