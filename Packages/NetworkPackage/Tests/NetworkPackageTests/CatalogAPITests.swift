//
//  CatalogAPITests.swift
//  NetworkPackage
//
//  Created by Valeriy Solovey on 06.09.2026.
//

import Foundation
import HTTPTypes
import OpenAPIRuntime
import Testing
@testable import NetworkPackage

@Suite("CatalogAPI")
struct CatalogAPITests {
    @Test("Decodes categories and sends an authorized GET")
    func fetchesCategories() async throws {
        let api = makeAPI { request in
            #expect(request.method == .get)
            #expect(request.path == "/categories")
            return jsonResponse(Self.categoriesJSON)
        }

        let categories = try await api.fetchCategories()

        #expect(categories == [
            CategoryDTO(
                id: "category-1",
                name: "Vegetables",
                image: "https://example.com/vegetables.png"
            ),
            CategoryDTO(
                id: "category-2",
                name: "Dairy",
                image: "https://example.com/dairy.png"
            )
        ])
    }

    @Test("Sends product filters and decodes the complete page")
    func fetchesProducts() async throws {
        let api = makeAPI { request in
            #expect(request.method == .get)
            let path = try #require(request.path)
            let components = try #require(URLComponents(string: path))
            #expect(components.path == "/products")
            #expect(Set(components.queryItems ?? []) == Set([
                URLQueryItem(name: "category", value: "fruit & vegetables"),
                URLQueryItem(name: "page", value: "2"),
                URLQueryItem(name: "pageSize", value: "10")
            ]))
            return jsonResponse(Self.productsJSON)
        }

        let products = try await api.fetchProducts(
            categoryID: "fruit & vegetables",
            page: 2,
            pageSize: 10
        )

        #expect(products == ProductListDTO(
            currentPage: 2,
            totalPages: 4,
            products: [
                ProductPreviewDTO(
                    id: "product-1",
                    name: "Tomatoes",
                    image: "https://example.com/tomatoes.png",
                    weight: 500,
                    price: 249,
                    rating: 4.8,
                    reviewCount: 42,
                    isFavorite: true,
                    discount: 15
                ),
                ProductPreviewDTO(
                    id: "product-2",
                    name: "Milk",
                    image: "https://example.com/milk.png",
                    weight: 1000,
                    price: 120,
                    rating: 4.5,
                    reviewCount: 18,
                    isFavorite: false,
                    discount: nil
                )
            ]
        ))
    }

    @Test("Omits optional product filters")
    func omitsProductFilters() async throws {
        let api = makeAPI { request in
            #expect(request.method == .get)
            #expect(request.path == "/products")
            return jsonResponse(#"{"currentPage":1,"totalPages":0,"data":[]}"#)
        }

        let products = try await api.fetchProducts()

        #expect(products == ProductListDTO(
            currentPage: 1,
            totalPages: 0,
            products: []
        ))
    }

    enum Operation: CaseIterable, Sendable {
        case categories, products

        func call(_ api: CatalogAPI) async throws {
            switch self {
            case .categories:
                _ = try await api.fetchCategories()
            case .products:
                _ = try await api.fetchProducts()
            }
        }
    }

    @Test(
        "Maps HTTP errors and preserves backend messages",
        arguments: Operation.allCases,
        [400, 401, 503]
    )
    func mapsErrors(operation: Operation, statusCode: Int) async throws {
        let api = makeAPI { _ in
            jsonResponse(
                #"{"error":"Catalog request failed"}"#,
                statusCode: statusCode
            )
        }

        do {
            try await operation.call(api)
            Issue.record("Expected APIError for HTTP \(statusCode)")
        } catch let error as APIError {
            switch (statusCode, error) {
            case (400, .badRequest(let message)) where operation == .products:
                #expect(message == "Catalog request failed")
            case (401, .unauthorized(let message)):
                #expect(message == "Catalog request failed")
            case (_, .server(let actualStatus, let message)):
                #expect(
                    statusCode == 503
                        || (statusCode == 400 && operation == .categories)
                )
                #expect(actualStatus == statusCode)
                #expect(message == "Catalog request failed")
            default:
                Issue.record("Unexpected error: \(error)")
            }
        }
    }

    @Test(
        "Rejects malformed or incomplete success JSON",
        arguments: Operation.allCases,
        ["not json", "{}"]
    )
    func rejectsInvalidJSON(operation: Operation, json: String) async {
        let api = makeAPI { _ in jsonResponse(json) }

        await #expect(throws: (any Error).self) {
            try await operation.call(api)
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
    ) -> CatalogAPI {
        let transport = StubTransport { request in
            #expect(request.headerFields[.authorization] == "Bearer test-token")
            return try handler(request)
        }
        return CatalogAPI(apiClient: APIClient(
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

    private func jsonResponse(
        _ json: String,
        statusCode: Int = 200
    ) -> (HTTPResponse, HTTPBody?) {
        (
            HTTPResponse(
                status: .init(code: statusCode),
                headerFields: [.contentType: "application/json"]
            ),
            HTTPBody(json)
        )
    }

    private static let categoriesJSON = """
    [
      {"id":"category-1","name":"Vegetables","image":"https://example.com/vegetables.png"},
      {"id":"category-2","name":"Dairy","image":"https://example.com/dairy.png"}
    ]
    """

    private static let productsJSON = """
    {
      "currentPage": 2,
      "totalPages": 4,
      "data": [
        {
          "id":"product-1","name":"Tomatoes","image":"https://example.com/tomatoes.png",
          "weight":500,"price":249,"rating":4.8,"reviewCount":42,"isFavorite":true,"discount":15
        },
        {
          "id":"product-2","name":"Milk","image":"https://example.com/milk.png",
          "weight":1000,"price":120,"rating":4.5,"reviewCount":18,"isFavorite":false
        }
      ]
    }
    """
}
