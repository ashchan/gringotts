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
            .replaceError(with: Data())
            .eraseToAnyPublisher()
    }

    private func makeRequest(endpoint: Endpoint) -> URLRequest {
        var components = URLComponents(string: makeUrl(endpoint: endpoint))!
        components.queryItems = [
            // URLQueryItem(name: "name", value: "value"),
        ]

        var request = URLRequest(url: components.url!)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")

        request.httpMethod = "POST"
        // TODO: build http body
        request.httpBody = "".data(using: .utf8)

        return request
    }

    private func makeUrl(endpoint: Endpoint) -> String {
        switch endpoint {
        case .holderCells(let pubkeyHash):
            return "\(server)/holders/\(pubkeyHash)/cells"
        case .builderCells(let pubkeyHash):
            return "\(server)/builders/\(pubkeyHash)/cells"
        }
    }
}

extension Client {
    enum Endpoint {
        case holderCells(pubkeyHash: String)
        case builderCells(pubkeyHash: String)
        // TODO
    }
}
