//
// UDT Hackathon Project Gringotts by Team Goblins
// Copyright © 2020 Goblins. all rights reserved.
// 

import Foundation
import Combine

final class Store: ObservableObject {
    @Published var state = AppState()
    private var client: Client?
    private var cancellables = Set<AnyCancellable>()

    private var tipNumberTimer: Timer?
    private var tipNumberCancellable: AnyCancellable?

    init() {
        updateClient()
    }
}

// Some actions
extension Store {
    func showSettingsView() {
        NotificationCenter.default.post(name: .showSettingsView, object: nil)
    }

    func updateClient() {
        client = Client(state.settings.apiServer)
    }

    func updateTipNumberPublisher() {
        tipNumberTimer = Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { timer in
            self.tipNumberCancellable?.cancel()
            self.tipNumberCancellable = self.client!.publisher(for: .tipHeader)
                .decode(type: TipNumber.self, decoder: JSONDecoder.apiDecoder)
                .print()
                .map { $0.tipNumber.numberFromHex }
                .replaceError(with: 0)
                .receive(on: DispatchQueue.main)
                .assign(to: \.state.tipNumber, on: self)
        }
        tipNumberTimer?.fire()
    }

    func testApiServer() {
        client?.publisher(for: .holderCells(pubkeyHash: "0xc8328aabcd9b9e8e64fbc566c4385c3bdeb219d7"))
            .decode(type: [Cell].self, decoder: JSONDecoder.apiDecoder)
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
