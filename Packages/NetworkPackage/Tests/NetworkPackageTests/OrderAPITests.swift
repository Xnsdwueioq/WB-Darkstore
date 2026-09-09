//
//  OrderAPITests.swift
//  NetworkPackage
//
//  Created by Valeriy Solovey on 05.09.2026.
//

import Foundation
import HTTPTypes
import OpenAPIRuntime
import Testing
@testable import NetworkPackage

@Suite("OrderAPI")
struct OrderAPITests {
    @Test("Creates an order with a JSON body and accepts an empty success response")
    func createsOrder() async throws {
        let api = makeAPI { request, body in
            #expect(request.method == .post)
            #expect(request.path == "/orders")
            let contentType = try #require(request.headerFields[.contentType])
            #expect(contentType.split(separator: ";").first == "application/json")
            let body = try #require(body)
            let data = try await Data(collecting: body, upTo: 4096)
            let json = try JSONSerialization.jsonObject(with: data) as? [String: String]
            #expect(json == ["paymentMethod": "card", "addressID": "address-1"])
            return (HTTPResponse(status: .ok), nil)
        }

        try await api.createOrder(paymentMethod: "card", addressID: "address-1")
    }

    @Test("Decodes order statuses, totals, items and address fields in server order")
    func fetchesOrders() async throws {
        let api = makeAPI { request, body in
            #expect(request.method == .get)
            #expect(request.path == "/orders")
            #expect(body == nil)
            return jsonResponse(Self.ordersJSON)
        }

        let orders = try await api.fetchOrders()

        #expect(orders.map(\.id) == ["order-2", "order-1"])
        #expect(orders.map(\.status) == [.completed, .active])
        let completed = try #require(orders.first)
        #expect(completed.deliveryDate == "5 сентября, 18:30")
        #expect(completed.address == AddressDTO(
            coordinates: [92.87, 56.01], addressLine: "Мира, 10",
            floor: "5", entrance: "2", intercomCode: "42", comment: "Позвонить"
        ))
        #expect(completed.orderPrice == 498)
        #expect(completed.deliveryPrice == 99)
        #expect(completed.totalPrice == 597)
        #expect(completed.totalItems == 2)
        #expect(completed.items == [OrderItemDTO(
            id: "product-1", name: "Tomatoes", image: "https://example.com/tomatoes.png",
            weight: 500, price: 249, quantity: 2
        )])
        let active = try #require(orders.last)
        #expect(active.deliveryDate == nil)
        #expect(active.address == AddressDTO(
            coordinates: [92.87, 56.01], addressLine: "Мира, 10",
            floor: nil, entrance: nil, intercomCode: nil, comment: nil
        ))
        #expect(active.items.isEmpty)
    }

    @Test("Decodes an empty order history")
    func fetchesEmptyOrders() async throws {
        let api = makeAPI { _, _ in jsonResponse("[]") }

        #expect(try await api.fetchOrders().isEmpty)
    }

    enum Operation: CaseIterable, Sendable {
        case create, fetch

        func call(_ api: OrderAPI) async throws {
            switch self {
            case .create: try await api.createOrder(paymentMethod: "card", addressID: "address-1")
            case .fetch: _ = try await api.fetchOrders()
            }
        }
    }

    @Test("Maps HTTP errors and preserves backend messages", arguments: Operation.allCases, [400, 401, 503])
    func mapsErrors(operation: Operation, statusCode: Int) async throws {
        let api = makeAPI { _, _ in
            jsonResponse(#"{"error":"Order request failed"}"#, statusCode: statusCode)
        }

        do {
            try await operation.call(api)
            Issue.record("Expected APIError for HTTP \(statusCode)")
        } catch let error as APIError {
            switch (statusCode, error) {
            case (400, .badRequest(let message)) where operation == .create:
                #expect(message == "Order request failed")
            case (401, .unauthorized(let message)):
                #expect(message == "Order request failed")
            case (_, .server(let actualStatus, let message)):
                #expect(statusCode == 503 || (statusCode == 400 && operation == .fetch))
                #expect(actualStatus == statusCode)
                #expect(message == "Order request failed")
            default:
                Issue.record("Unexpected error: \(error)")
            }
        }
    }

    @Test("Rejects malformed JSON, missing fields and unknown statuses", arguments: [
        "not json", "[{}]", ordersJSON.replacingOccurrences(of: "completed", with: "unknown")
    ])
    func rejectsInvalidOrders(json: String) async {
        let api = makeAPI { _, _ in jsonResponse(json) }

        await #expect(throws: (any Error).self) {
            try await api.fetchOrders()
        }
    }

    @Test("Preserves transport failures", arguments: Operation.allCases)
    func propagatesTransportErrors(operation: Operation) async throws {
        let api = makeAPI { _, _ in throw TransportError.offline }

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
        handler: @escaping @Sendable (HTTPRequest, HTTPBody?) async throws -> (HTTPResponse, HTTPBody?)
    ) -> OrderAPI {
        let transport = StubTransport { request, body in
            #expect(request.headerFields[.authorization] == "Bearer test-token")
            return try await handler(request, body)
        }
        return OrderAPI(apiClient: APIClient(
            serverURL: URL(string: "https://example.com")!,
            token: "test-token",
            transport: transport
        ))
    }

    private struct StubTransport: ClientTransport {
        let handler: @Sendable (HTTPRequest, HTTPBody?) async throws -> (HTTPResponse, HTTPBody?)

        func send(
            _ request: HTTPRequest,
            body: HTTPBody?,
            baseURL: URL,
            operationID: String
        ) async throws -> (HTTPResponse, HTTPBody?) {
            try await handler(request, body)
        }
    }

    private func jsonResponse(_ json: String, statusCode: Int = 200) -> (HTTPResponse, HTTPBody?) {
        (HTTPResponse(status: .init(code: statusCode), headerFields: [.contentType: "application/json"]), HTTPBody(json))
    }

    private static let ordersJSON = """
    [
      {
        "id":"order-2","status":"completed","deliveryDate":"5 сентября, 18:30",
        "address":{"coordinates":[92.87,56.01],"addressLine":"Мира, 10",
                   "floor":"5","entrance":"2","intercomCode":"42","comment":"Позвонить"},
        "orderPrice":498,"deliveryPrice":99,"totalPrice":597,"totalItems":2,
        "items":[{"id":"product-1","name":"Tomatoes","image":"https://example.com/tomatoes.png",
                  "weight":500,"price":249,"quantity":2}]
      },
      {
        "id":"order-1","status":"active",
        "address":{"coordinates":[92.87,56.01],"addressLine":"Мира, 10"},
        "orderPrice":0,"deliveryPrice":0,"totalPrice":0,"totalItems":0,"items":[]
      }
    ]
    """
}
