//
//  CartAPI.swift
//  NetworkPackage
//
//  Created by Valeriy Solovey on 05.09.2026.
//

public struct CartAPI: CartAPIProtocol {
    private let apiClient: APIClient

    public init(apiClient: APIClient) {
        self.apiClient = apiClient
    }

    public func fetchCart() async throws -> CartDTO {
        let output = try await apiClient.client.getCart()

        switch output {
        case .ok(let response):
            let cart = try response.body.json

            return CartDTO(
                deliveryTime: cart.deliveryTime,
                orderPrice: cart.orderPrice,
                deliveryPrice: cart.deliveryPrice,
                totalPrice: cart.totalPrice,
                totalItems: cart.totalItems,
                items: cart.items.map {
                    let item = $0.value1
                    let availableInfo = $0.value2

                    return .init(
                        id: item.id,
                        name: item.name,
                        image: item.image,
                        weight: item.weight,
                        price: item.price,
                        quantity: item.quantity,
                        available: availableInfo.available
                    )
                }
            )

        case .unauthorized(let response):
            let error = try response.body.json
            throw APIError.unauthorized(message: error.error)

        case .default(statusCode: let statusCode, let response):
            let error = try response.body.json
            throw APIError.server(
                statusCode: statusCode,
                message: error.error
            )
        }
    }

    public func addItem(productID: String) async throws -> Int {
        let output = try await apiClient.client.postCartItems(
            .init(query: .init(id: productID))
        )

        switch output {
        case .ok(let response):
            return try response.body.json.total

        case .unauthorized(let response):
            let error = try response.body.json
            throw APIError.unauthorized(message: error.error)

        case .notFound(let response):
            let error = try response.body.json
            throw APIError.notFound(message: error.error)

        case .default(statusCode: let statusCode, let response):
            let error = try response.body.json
            throw APIError.server(
                statusCode: statusCode,
                message: error.error
            )
        }
    }

    public func removeItem(productID: String) async throws -> Int {
        let output = try await apiClient.client.deleteCartItemsId(
            .init(path: .init(id: productID))
        )

        switch output {
        case .ok(let response):
            if let total = try response.body.json.total {
                return total
            }

            return try await fetchCart().totalItems

        case .unauthorized(let response):
            let error = try response.body.json
            throw APIError.unauthorized(message: error.error)

        case .notFound(let response):
            let error = try response.body.json
            throw APIError.notFound(message: error.error)

        case .default(statusCode: let statusCode, let response):
            let error = try response.body.json
            throw APIError.server(
                statusCode: statusCode,
                message: error.error
            )
        }
    }
}
