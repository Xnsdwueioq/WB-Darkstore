//
//  CartItem.swift
//  BusinessLogic
//
//  Created by Valeriy Solovey on 05.09.2026.
//

import Foundation

public struct CartItem: Sendable, Equatable, Identifiable {
    public let id: String
    public let name: String
    public let imageURL: URL?
    public let weight: Int
    public let price: Int
    public let quantity: Int
    public let available: Bool

    public init(
        id: String,
        name: String,
        imageURL: URL?,
        weight: Int,
        price: Int,
        quantity: Int,
        available: Bool
    ) {
        self.id = id
        self.name = name
        self.imageURL = imageURL
        self.weight = weight
        self.price = price
        self.quantity = quantity
        self.available = available
    }
}
