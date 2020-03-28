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
                .map { $0.tipNumber.numberFromHex }
                .replaceError(with: 0)
                .receive(on: DispatchQueue.main)
                .sink { tipNumber in
                    // Do not use assign here to avoid setting tip number to 0 when api call fails
                    if tipNumber > 0 {
                        self.state.tipNumber = tipNumber
                    }
                }
        }
        tipNumberTimer?.fire()
    }

    func loadHolderCells() {
        client?.publisher(for: .holderCells(pubkeyHash: KeyManager.pubkeyPash(for: state.settings.holderAddress)))
            .decode(type: [Cell].self, decoder: JSONDecoder.apiDecoder)
            .replaceError(with: [])
            .receive(on: DispatchQueue.main)
            .assign(to: \.state.holderCells, on: self)
            .store(in: &cancellables)
    }

    func loadBuilderCells() {
        client?.publisher(for: .builderCells(pubkeyHash: KeyManager.pubkeyPash(for: state.settings.builderAddress)))
            .decode(type: [Cell].self, decoder: JSONDecoder.apiDecoder)
            .replaceError(with: [])
            .receive(on: DispatchQueue.main)
            .assign(to: \.state.builderCells, on: self)
            .store(in: &cancellables)
    }

    func loadBalance(address: String) {
        client?.publisher(for: .balance(pubkeyHash: KeyManager.pubkeyPash(for: address)))
            .decode(type: Balance.self, decoder: JSONDecoder.apiDecoder)
            .map(\.balance)
            .replaceError(with: "0")
            .receive(on: DispatchQueue.main)
            .assign(to: \.state.balance, on: self)
            .store(in: &cancellables)
    }

    func changeData(cell: Cell, data: String) {
        client?.publisher(for: .changeData(cell: cell, pubkeyHash: KeyManager.pubkeyPash(for: state.settings.builderAddress), data: data))
            .decode(type: SigningMessage.self, decoder: JSONDecoder.apiDecoder)
            .sink(receiveCompletion: { completion in
            }) { signingMessage in
                self.sendSignedTransaction(signingMessage: signingMessage, privateKey: self.state.settings.builderPrivateKey)
            }
            .store(in: &cancellables)
    }

    func pay(cell: Cell) {
        client?.publisher(for: .pay(cell: cell, pubkeyHash: KeyManager.pubkeyPash(for: state.settings.builderAddress)))
            .decode(type: SigningMessage.self, decoder: JSONDecoder.apiDecoder)
            .sink(receiveCompletion: { completion in
            }) { signingMessage in
                self.sendSignedTransaction(signingMessage: signingMessage, privateKey: self.state.settings.builderPrivateKey)
            }
            .store(in: &cancellables)
    }

    func claim(cell: Cell) {
        client?.publisher(for: .claim(cell: cell, pubkeyHash: KeyManager.pubkeyPash(for: state.settings.holderAddress)))
            .decode(type: SigningMessage.self, decoder: JSONDecoder.apiDecoder)
            .sink(receiveCompletion: { completion in
            }) { signingMessage in
                self.sendSignedTransaction(signingMessage: signingMessage, privateKey: self.state.settings.holderPrivatekey)
            }
            .store(in: &cancellables)
    }

    func sendSignedTransaction(signingMessage: SigningMessage, privateKey: String) {
        let signedMessage = signingMessage.sign(with: privateKey)
        client?.publisher(for: .sendSignedTransaction(message: signedMessage))
            .decode(type: SignMessageResult.self, decoder: JSONDecoder.apiDecoder)
            .sink(receiveCompletion: { completion in
                print(completion)
            }) { result in
                // TODO: notify user
                print(result)
            }
            .store(in: &cancellables)
    }
}

extension Notification.Name {
    static let showSettingsView = Notification.Name("showSettingsView")
}
