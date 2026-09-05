//
//  CartServiceProtocol.swift
//  BusinessLogic
//
//  Created by Valeriy Solovey on 05.09.2026.
//

public protocol CartServiceProtocol: Sendable {
    func getCart() async throws -> Cart

    func addToCart(productID: String) async throws -> Int

    func removeFromCart(productID: String) async throws -> Int
}
