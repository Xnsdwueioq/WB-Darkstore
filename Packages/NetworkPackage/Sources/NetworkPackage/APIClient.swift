//
//  APIClient.swift
//  NetworkPackage
//
//  Created by Valeriy Solovey on 04.09.2026.
//

import Foundation
import OpenAPIURLSession

// В CompositionRoot:
// let token = ProcessInfo.processInfo.environment["BEARER_TOKEN"]

public struct APIClient: Sendable {
    let client: Client

    public init(serverURL: URL, token: String) {
        client = Client(
            serverURL: serverURL,
            configuration: .init(
                dateTranscoder: FlexibleISO8601DateTranscoder()
            ),
            transport: URLSessionTransport(),
            middlewares: [
                BearerTokenMiddleware(token: token)
            ]
        )
    }

    public init(token: String) throws {
        try self.init(
            serverURL: Servers.Server1.url(),
            token: token
        )
    }
}
