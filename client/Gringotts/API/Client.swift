//
// UDT Hackathon Project Gringotts by Team Goblins
// Copyright © 2020 Goblins. all rights reserved.
// 

import Foundation
import Combine

struct Client {
    private let server: String

    init(_ server: String) {
        if server.last == "/" {
            self.server = String(server.dropLast())
        } else {
            self.server = server
        }
    }

    func publisher(for endpoint: Endpoint) -> AnyPublisher<Data, Never> {
        URLSession.shared
            .dataTaskPublisher(for: makeRequest(endpoint: endpoint))
            .map(\.data)
            .map { d in
                // For debug http response
                // print(String(data: d, encoding: .utf8))
                return d
            }
            .replaceError(with: Data())
            .eraseToAnyPublisher()
    }

    private func makeRequest(endpoint: Endpoint) -> URLRequest {
        var components = URLComponents(string: makeUrl(endpoint: endpoint))!
        components.queryItems = []

        var request = URLRequest(url: components.url!)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")

        request.httpMethod = "POST"
        request.httpBody = endpoint.data

        return request
    }

    private func makeUrl(endpoint: Endpoint) -> String {
        return [server, endpoint.path].joined(separator: "/")
    }
}

extension Client {
    enum Endpoint {
        case holderCells(pubkeyHash: String)
        case builderCells(pubkeyHash: String)
        case changeData(cell: Cell, pubkeyHash: String, data: String)
        case pay(cell: Cell, pubkeyHash: String)
        case claim(cell: Cell, pubkeyHash: String)
        case sendSignedTransaction(message: SignedMessage)

        case createMatch(data: MatchData)
        case listMatches
        case match(id: String, pubkeyHash: String)
        case signMatch(id: String, signatures: [String])
        case signConfirm(id: String, signatures: [String])

        case balance(pubkeyHash: String)
        case tipHeader

        var path: String {
            switch self {
            case .holderCells(let pubkeyHash):
                return "holders/\(pubkeyHash)/cells"
            case .builderCells(let pubkeyHash):
                return "builders/\(pubkeyHash)/cells"
            case .changeData(let cell, let pubkeyHash, _):
                return "builders/\(cellPath(pubkeyHash, cell))/change_data"
            case .pay(let cell, let pubkeyHash):
                return "builders/\(cellPath(pubkeyHash, cell))/pay"
            case .claim(let cell, let pubkeyHash):
                return "holders/\(cellPath(pubkeyHash, cell))/claim"
            case .sendSignedTransaction:
                return "send_signed_transaction"

            case .createMatch:
                return "matches/create"
            case .listMatches:
                return "matches/list"
            case .match(let id, _):
                return "matches/\(id)/match"
            case .signMatch(let id, _):
                return "matches/\(id)/sign_match"
            case .signConfirm(let id, _):
                return "matches/\(id)/sign_confirm"

            case .balance(let pubkeyHash):
                return "balances/\(pubkeyHash)"
            case .tipHeader:
                return "tip_header"
            }
        }

        var data: Data? {
            let toEncode: Encodable?

            switch self {
            case .changeData(_, _, let data):
                toEncode = ["data": data]
            case .sendSignedTransaction(let signedMessage):
                toEncode = signedMessage
            case .createMatch(let data):
                toEncode = data
            case .match(_, let pubkeyHash):
                toEncode = ["holder_pubkey_hash": pubkeyHash]
            case .signMatch(_, let signatures):
                toEncode = ["signatures": signatures]
            case .signConfirm(_, let signatures):
                toEncode = ["signatures": signatures]
            default:
                toEncode = nil
            }

            return toEncode?.toJSON()
        }

        private func cellPath(_ pubkeyHash: String, _ cell: Cell) -> String {
            return "\(pubkeyHash)/cell/\(cell.outPoint.txHash)/\(cell.outPoint.index)"
        }
    }
}
