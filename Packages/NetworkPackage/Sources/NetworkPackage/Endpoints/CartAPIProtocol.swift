//
//  CartAPIProtocol.swift
//  NetworkPackage
//
//  Created by Valeriy Solovey on 05.09.2026.
//

public protocol CartAPIProtocol: Sendable {
    func fetchCart() async throws -> CartDTO

    func addItem(productID: String) async throws -> Int

    func removeItem(productID: String) async throws -> Int
}
