//
//  CartItemDTO.swift
//  NetworkPackage
//
//  Created by Valeriy Solovey on 05.09.2026.
//

public struct CartItemDTO: Sendable, Equatable, Identifiable {
    public let id: String
    public let name: String
    public let image: String
    public let weight: Int
    public let price: Int
    public let quantity: Int
    public let available: Bool

    public init(
        id: String,
        name: String,
        image: String,
        weight: Int,
        price: Int,
        quantity: Int,
        available: Bool
    ) {
        self.id = id
        self.name = name
        self.image = image
        self.weight = weight
        self.price = price
        self.quantity = quantity
        self.available = available
    }
}
