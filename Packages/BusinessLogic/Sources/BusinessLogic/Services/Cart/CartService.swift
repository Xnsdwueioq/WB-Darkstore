//
//  CartService.swift
//  BusinessLogic
//
//  Created by Valeriy Solovey on 05.09.2026.
//

import Foundation
import NetworkPackage

public struct CartService: CartServiceProtocol {
    private let cartAPI: any CartAPIProtocol

    public init(cartAPI: any CartAPIProtocol) {
        self.cartAPI = cartAPI
    }

    public func getCart() async throws -> Cart {
        let dto = try await cartAPI.fetchCart()

        return Cart(
            deliveryTime: dto.deliveryTime,
            orderPrice: dto.orderPrice,
            deliveryPrice: dto.deliveryPrice,
            totalPrice: dto.totalPrice,
            totalItems: dto.totalItems,
            items: dto.items.map {
                .init(
                    id: $0.id,
                    name: $0.name,
                    imageURL: URL(string: $0.image),
                    weight: $0.weight,
                    price: $0.price,
                    quantity: $0.quantity,
                    available: $0.available
                )
            }
        )
    }

    public func addToCart(productID: String) async throws -> Int {
        try await cartAPI.addItem(productID: productID)
    }

    public func removeFromCart(productID: String) async throws -> Int {
        try await cartAPI.removeItem(productID: productID)
    }
}
