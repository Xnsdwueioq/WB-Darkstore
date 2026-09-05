//
//  CartAPITests.swift
//  NetworkPackage
//
//  Created by Valeriy Solovey on 05.09.2026.
//

import Foundation
import HTTPTypes
import OpenAPIRuntime
import Testing
@testable import NetworkPackage

@Suite("CartAPI")
struct CartAPITests {
    @Test("Decodes flat allOf JSON into cart DTOs and sends an authorized GET")
    func fetchesCart() async throws {
        let api = makeAPI { request in
            #expect(request.method == .get)
            #expect(request.path == "/cart")
            return jsonResponse(Self.cartJSON)
        }

        let cart = try await api.fetchCart()

        #expect(cart == CartDTO(
            deliveryTime: 25, orderPrice: 498, deliveryPrice: 99,
            totalPrice: 597, totalItems: 3,
            items: [
                CartItemDTO(
                    id: "product-1", name: "Tomatoes",
                    image: "https://example.com/tomatoes.png",
                    weight: 500, price: 249, quantity: 2, available: true
                ),
                CartItemDTO(
                    id: "product-2", name: "Milk",
                    image: "https://example.com/milk.png",
                    weight: 1000, price: 120, quantity: 1, available: false
                )
            ]
        ))
    }

    @Test("Decodes an empty cart")
    func fetchesEmptyCart() async throws {
        let api = makeAPI { _ in
            jsonResponse("""
            {"deliveryTime":0,"orderPrice":0,"deliveryPrice":0,
             "totalPrice":0,"totalItems":0,"items":[]}
            """)
        }

        let cart = try await api.fetchCart()

        #expect(cart == CartDTO(
            deliveryTime: 0, orderPrice: 0, deliveryPrice: 0,
            totalPrice: 0, totalItems: 0, items: []
        ))
    }

    @Test("Sends product ID as a query parameter and returns the added total")
    func addsItem() async throws {
        let api = makeAPI { request in
            #expect(request.method == .post)
            let path = try #require(request.path)
            let components = try #require(URLComponents(string: path))
            #expect(components.path == "/cart/items")
            #expect(components.queryItems == [URLQueryItem(name: "id", value: "product & 1")])
            return jsonResponse(#"{"total":3}"#)
        }

        let total = try await api.addItem(productID: "product & 1")

        #expect(total == 3)
    }

    @Test("Sends product ID in the path and returns the removed total without a GET", arguments: [0, 1])
    func removesItem(expectedTotal: Int) async throws {
        let api = makeAPI { request in
            #expect(request.method == .delete)
            #expect(request.path == "/cart/items/product%201")
            return jsonResponse("{\"total\":\(expectedTotal)}")
        }

        let total = try await api.removeItem(productID: "product 1")

        #expect(total == expectedTotal)
    }

    @Test("Fetches the cart total when DELETE omits it")
    func fetchesMissingRemovalTotal() async throws {
        let api = makeAPI { request in
            if request.method == .delete {
                #expect(request.path == "/cart/items/product-1")
                return jsonResponse("{}")
            }
            #expect(request.method == .get)
            #expect(request.path == "/cart")
            return jsonResponse(Self.cartJSON)
        }

        let total = try await api.removeItem(productID: "product-1")

        #expect(total == 3)
    }

    @Test("Propagates a failed count refresh after DELETE instead of returning zero")
    func propagatesRemovalRefreshError() async throws {
        let api = makeAPI { request in
            if request.method == .delete {
                return jsonResponse("{}")
            }
            #expect(request.method == .get)
            #expect(request.path == "/cart")
            return jsonResponse(#"{"error":"Refresh failed"}"#, statusCode: 503)
        }

        do {
            _ = try await api.removeItem(productID: "product-1")
            Issue.record("Expected the cart refresh to fail")
        } catch let error as APIError {
            guard case .server(let statusCode, let message) = error else {
                Issue.record("Unexpected error: \(error)")
                return
            }
            #expect(statusCode == 503)
            #expect(message == "Refresh failed")
        }
    }

    @Test("Rejects an add response without its required total")
    func rejectsMissingAddedTotal() async {
        let api = makeAPI { _ in jsonResponse("{}") }

        await #expect(throws: (any Error).self) {
            try await api.addItem(productID: "product-1")
        }
    }

    enum Operation: CaseIterable, Sendable {
        case fetch, add, remove

        func call(_ api: CartAPI) async throws {
            switch self {
            case .fetch: _ = try await api.fetchCart()
            case .add: _ = try await api.addItem(productID: "product-1")
            case .remove: _ = try await api.removeItem(productID: "product-1")
            }
        }
    }

    @Test("Maps HTTP errors and preserves backend messages", arguments: Operation.allCases, [401, 404, 503])
    func mapsErrors(operation: Operation, statusCode: Int) async throws {
        let api = makeAPI { _ in
            jsonResponse(#"{"error":"Cart request failed"}"#, statusCode: statusCode)
        }

        do {
            try await operation.call(api)
            Issue.record("Expected APIError for HTTP \(statusCode)")
        } catch let error as APIError {
            switch (statusCode, error) {
            case (401, .unauthorized(let message)):
                #expect(message == "Cart request failed")
            case (404, .notFound(let message)) where operation != .fetch:
                #expect(message == "Cart request failed")
            case (_, .server(let actualStatus, let message)):
                #expect(statusCode == 503 || (statusCode == 404 && operation == .fetch))
                #expect(actualStatus == statusCode)
                #expect(message == "Cart request failed")
            default:
                Issue.record("Unexpected error: \(error)")
            }
        }
    }

    @Test("Rejects malformed or incomplete cart JSON", arguments: ["not json", "{}"])
    func rejectsInvalidCart(json: String) async {
        let api = makeAPI { _ in jsonResponse(json) }

        await #expect(throws: (any Error).self) {
            try await api.fetchCart()
        }
    }

    @Test("Preserves transport failures", arguments: Operation.allCases)
    func propagatesTransportErrors(operation: Operation) async throws {
        let api = makeAPI { _ in throw TransportError.offline }

        do {
            try await operation.call(api)
            Issue.record("Expected a transport failure")
        } catch let error as ClientError {
            #expect(error.underlyingError as? TransportError == .offline)
        }
    }

    private enum TransportError: Error {
        case offline
    }

    private func makeAPI(
        handler: @escaping @Sendable (HTTPRequest) throws -> (HTTPResponse, HTTPBody?)
    ) -> CartAPI {
        let transport = StubTransport { request in
            #expect(request.headerFields[.authorization] == "Bearer test-token")
            return try handler(request)
        }
        return CartAPI(apiClient: APIClient(
            serverURL: URL(string: "https://example.com")!,
            token: "test-token",
            transport: transport
        ))
    }

    private struct StubTransport: ClientTransport {
        let handler: @Sendable (HTTPRequest) throws -> (HTTPResponse, HTTPBody?)

        func send(
            _ request: HTTPRequest,
            body: HTTPBody?,
            baseURL: URL,
            operationID: String
        ) async throws -> (HTTPResponse, HTTPBody?) {
            #expect(body == nil)
            return try handler(request)
        }
    }

    private func jsonResponse(_ json: String, statusCode: Int = 200) -> (HTTPResponse, HTTPBody?) {
        (HTTPResponse(status: .init(code: statusCode), headerFields: [.contentType: "application/json"]), HTTPBody(json))
    }

    private static let cartJSON = """
    {
      "deliveryTime": 25, "orderPrice": 498, "deliveryPrice": 99,
      "totalPrice": 597, "totalItems": 3,
      "items": [
        {"id":"product-1","name":"Tomatoes","image":"https://example.com/tomatoes.png",
         "weight":500,"price":249,"quantity":2,"available":true},
        {"id":"product-2","name":"Milk","image":"https://example.com/milk.png",
         "weight":1000,"price":120,"quantity":1,"available":false}
      ]
    }
    """
}
