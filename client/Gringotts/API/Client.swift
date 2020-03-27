//
// UDT Hackathon Project Gringotts by Team Goblins
// Copyright © 2020 Goblins. all rights reserved.
// 

import Foundation
import Combine

struct Client {
    private let server: String

    init(_ server: String = "http://127.0.0.1:8114") {
        self.server = server
    }

    private func makeRequest(endpoint: Endpoint) -> URLRequest {
        // TODO: construct url components
        var components = URLComponents(string: server)!
        components.queryItems = [
            // URLQueryItem(name: "name", value: "value"),
        ]

        var request = URLRequest(url: components.url!)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")

        request.httpMethod = "POST"
        // TODO: build http body
        request.httpBody = "todo".data(using: .utf8)

        return request
    }
}

extension Client {
    enum Endpoint {
        case lenderCells
        case borrowerCells
        // TODO
    }
}
