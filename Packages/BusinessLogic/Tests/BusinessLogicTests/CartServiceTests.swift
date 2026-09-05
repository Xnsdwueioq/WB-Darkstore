//
//  CartServiceTests.swift
//  BusinessLogic
//
//  Created by Valeriy Solovey on 05.09.2026.
//

import Foundation
import NetworkPackage
import Testing
@testable import BusinessLogic

@Suite("CartService")
struct CartServiceTests {
    @Test("Maps totals and items, preserving unavailable products and invalid image URLs")
    func mapsCart() async throws {
        let api = CartAPIMock(fetchResponse: .success(CartDTO(
            deliveryTime: 25,
            orderPrice: 498,
            deliveryPrice: 99,
            totalPrice: 597,
            totalItems: 3,
            items: [
                CartItemDTO(
                    id: "product-1", name: "Tomatoes",
                    image: "https://example.com/tomatoes.png",
                    weight: 500, price: 249, quantity: 2, available: true
                ),
                CartItemDTO(
                    id: "product-2", name: "Milk", image: "http://[",
                    weight: 1000, price: 120, quantity: 1, available: false
                )
            ]
        )))
        let service = CartService(cartAPI: api)

        let cart = try await service.getCart()

        #expect(cart == Cart(
            deliveryTime: 25,
            orderPrice: 498,
            deliveryPrice: 99,
            totalPrice: 597,
            totalItems: 3,
            items: [
                CartItem(
                    id: "product-1", name: "Tomatoes",
                    imageURL: URL(string: "https://example.com/tomatoes.png"),
                    weight: 500, price: 249, quantity: 2, available: true
                ),
                CartItem(
                    id: "product-2", name: "Milk", imageURL: nil,
                    weight: 1000, price: 120, quantity: 1, available: false
                )
            ]
        ))
    }

    @Test("Maps an empty cart without inventing items or recalculating delivery")
    func mapsEmptyCart() async throws {
        let api = CartAPIMock(fetchResponse: .success(CartDTO(
            deliveryTime: 25, orderPrice: 0, deliveryPrice: 99,
            totalPrice: 99, totalItems: 0, items: []
        )))
        let service = CartService(cartAPI: api)

        let cart = try await service.getCart()

        #expect(cart == Cart(
            deliveryTime: 25, orderPrice: 0, deliveryPrice: 99,
            totalPrice: 99, totalItems: 0, items: []
        ))
    }

    @Test("Routes mutations with the product ID and returns the server totals")
    func routesMutations() async throws {
        let api = CartAPIMock(addedTotal: 7, removedTotal: 0)
        let service = CartService(cartAPI: api)

        let addedTotal = try await service.addToCart(productID: "product-1")
        let removedTotal = try await service.removeFromCart(productID: "product-2")

        #expect(addedTotal == 7)
        #expect(removedTotal == 0)
        #expect(await api.addedProductIDs == ["product-1"])
        #expect(await api.removedProductIDs == ["product-2"])
    }

    enum Operation: CaseIterable, Sendable {
        case fetch, add, remove
    }

    @Test("Propagates errors from every cart operation", arguments: Operation.allCases)
    func propagatesErrors(operation: Operation) async {
        let api = CartAPIMock(mutationError: .requestFailed)
        let service = CartService(cartAPI: api)

        await #expect(throws: CartAPIMock.MockError.requestFailed) {
            switch operation {
            case .fetch: _ = try await service.getCart()
            case .add: _ = try await service.addToCart(productID: "product-1")
            case .remove: _ = try await service.removeFromCart(productID: "product-1")
            }
        }
    }
}
