//
//  ProductAPITests.swift
//  NetworkPackage
//
//  Created by Valeriy Solovey on 06.09.2026.
//

import Foundation
import HTTPTypes
import OpenAPIRuntime
import Testing
@testable import NetworkPackage

@Suite("ProductAPI")
struct ProductAPITests {
    @Test("Decodes product details with reviews")
    func fetchesProduct() async throws {
        let api = makeAPI { request, body in
            #expect(request.method == .get)
            #expect(request.path == "/products/product%201")
            #expect(body == nil)
            return jsonResponse(Self.productJSON)
        }

        let product = try await api.fetchProduct(id: "product 1")

        #expect(product.id == "product-1")
        #expect(product.name == "Tomatoes")
        #expect(product.image == "https://example.com/tomatoes.png")
        #expect(product.weight == 500)
        #expect(product.price == 249)
        #expect(product.rating == 4.8)
        #expect(product.description == "Fresh tomatoes")
        #expect(product.isFavorite)
        #expect(product.discount == 15)

        let reviews = try #require(product.reviews)
        #expect(reviews.count == 1)
        let review = try #require(reviews.first)
        #expect(review.rating == 5)
        #expect(review.author == "Valeriy")
        #expect(review.createdAt == Date(timeIntervalSince1970: 1_788_518_400))
        #expect(review.content == "Excellent")
        #expect(review.images == ["https://example.com/review.png"])
    }

    @Test("Preserves absent optional product fields")
    func fetchesProductWithoutOptionals() async throws {
        let api = makeAPI { _, _ in
            jsonResponse("""
            {
              "id":"product-2","name":"Milk","image":"https://example.com/milk.png",
              "weight":1000,"price":120,"rating":4.5,
              "description":"Fresh milk","isFavorite":false
            }
            """)
        }

        let product = try await api.fetchProduct(id: "product-2")

        #expect(product.discount == nil)
        #expect(product.reviews == nil)
    }

    @Test("Adds and removes an encoded product ID from favorites", arguments: [false, true])
    func changesFavoriteState(removing: Bool) async throws {
        let api = makeAPI { request, body in
            #expect(request.method == (removing ? .delete : .post))
            #expect(request.path == "/products/product%201/favourite")
            #expect(body == nil)
            return (HTTPResponse(status: .ok), nil)
        }

        if removing {
            try await api.removeFromFavorites(productID: "product 1")
        } else {
            try await api.addToFavorites(productID: "product 1")
        }
    }

    @Test("Sends a review JSON body for an encoded product ID")
    func submitsReview() async throws {
        let api = makeAPI { request, body in
            #expect(request.method == .post)
            #expect(request.path == "/products/product%201/reviews")
            let contentType = try #require(request.headerFields[.contentType])
            #expect(contentType.split(separator: ";").first == "application/json")
            let body = try #require(body)
            let data = try await Data(collecting: body, upTo: 4096)
            let json = try #require(
                try JSONSerialization.jsonObject(with: data) as? [String: Any]
            )
            #expect(json["rating"] as? Int == 5)
            #expect(json["content"] as? String == "Excellent")
            #expect(json["images"] as? [String] == [
                "https://example.com/review-1.png",
                "https://example.com/review-2.png"
            ])
            return (HTTPResponse(status: .ok), nil)
        }

        try await api.submitReview(
            productID: "product 1",
            review: NewReviewDTO(
                rating: 5,
                content: "Excellent",
                images: [
                    "https://example.com/review-1.png",
                    "https://example.com/review-2.png"
                ]
            )
        )
    }

    enum Operation: CaseIterable, Sendable {
        case fetch, addFavorite, removeFavorite, submitReview

        func call(_ api: ProductAPI) async throws {
            switch self {
            case .fetch:
                _ = try await api.fetchProduct(id: "product-1")
            case .addFavorite:
                try await api.addToFavorites(productID: "product-1")
            case .removeFavorite:
                try await api.removeFromFavorites(productID: "product-1")
            case .submitReview:
                try await api.submitReview(
                    productID: "product-1",
                    review: NewReviewDTO(
                        rating: 5,
                        content: "Excellent",
                        images: []
                    )
                )
            }
        }
    }

    @Test(
        "Maps HTTP errors and preserves backend messages",
        arguments: Operation.allCases,
        [400, 401, 404, 503]
    )
    func mapsErrors(operation: Operation, statusCode: Int) async throws {
        let api = makeAPI { _, _ in
            jsonResponse(
                #"{"error":"Product request failed"}"#,
                statusCode: statusCode
            )
        }

        do {
            try await operation.call(api)
            Issue.record("Expected APIError for HTTP \(statusCode)")
        } catch let error as APIError {
            switch (statusCode, error) {
            case (400, .badRequest(let message)) where operation == .submitReview:
                #expect(message == "Product request failed")
            case (401, .unauthorized(let message)):
                #expect(message == "Product request failed")
            case (404, .notFound(let message)) where operation != .submitReview:
                #expect(message == "Product request failed")
            case (_, .server(let actualStatus, let message)):
                #expect(
                    statusCode == 503
                        || (statusCode == 400 && operation != .submitReview)
                        || (statusCode == 404 && operation == .submitReview)
                )
                #expect(actualStatus == statusCode)
                #expect(message == "Product request failed")
            default:
                Issue.record("Unexpected error: \(error)")
            }
        }
    }

    @Test("Rejects malformed or incomplete product JSON", arguments: ["not json", "{}"])
    func rejectsInvalidProduct(json: String) async {
        let api = makeAPI { _, _ in jsonResponse(json) }

        await #expect(throws: (any Error).self) {
            try await api.fetchProduct(id: "product-1")
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
        handler: @escaping @Sendable (
            HTTPRequest,
            HTTPBody?
        ) async throws -> (HTTPResponse, HTTPBody?)
    ) -> ProductAPI {
        let transport = StubTransport { request, body in
            #expect(request.headerFields[.authorization] == "Bearer test-token")
            return try await handler(request, body)
        }
        return ProductAPI(apiClient: APIClient(
            serverURL: URL(string: "https://example.com")!,
            token: "test-token",
            transport: transport
        ))
    }

    private struct StubTransport: ClientTransport {
        let handler: @Sendable (
            HTTPRequest,
            HTTPBody?
        ) async throws -> (HTTPResponse, HTTPBody?)

        func send(
            _ request: HTTPRequest,
            body: HTTPBody?,
            baseURL: URL,
            operationID: String
        ) async throws -> (HTTPResponse, HTTPBody?) {
            try await handler(request, body)
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

    private static let productJSON = """
    {
      "id":"product-1","name":"Tomatoes","image":"https://example.com/tomatoes.png",
      "weight":500,"price":249,"rating":4.8,"description":"Fresh tomatoes",
      "isFavorite":true,"discount":15,
      "reviews":[
        {
          "rating":5,"author":"Valeriy","createdAt":"2026-09-04T10:40:00Z",
          "content":"Excellent","images":["https://example.com/review.png"]
        }
      ]
    }
    """
}
