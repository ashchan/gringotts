//
// UDT Hackathon Project Gringotts by Team Goblins
// Copyright © 2020 Goblins. all rights reserved.
// 

import Combine

final class Store: ObservableObject {
    @Published var state = AppState()
    private var cancellables = Set<AnyCancellable>()

    init() {
    }
}
