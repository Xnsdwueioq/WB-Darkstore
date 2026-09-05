//
//  ProductPreviewDTO.swift
//  NetworkPackage
//
//  Created by Valeriy Solovey on 04.09.2026.
//

public struct ProductPreviewDTO: Sendable, Equatable {
    public let id: String
    public let name: String
    public let image: String
    public let weight: Double
    public let price: Int
    public let rating: Float
    public let reviewCount: Int
    public let isFavorite: Bool
    public let discount: Double?

    public init(
        id: String,
        name: String,
        image: String,
        weight: Double,
        price: Int,
        rating: Float,
        reviewCount: Int,
        isFavorite: Bool,
        discount: Double?
    ) {
        self.id = id
        self.name = name
        self.image = image
        self.weight = weight
        self.price = price
        self.rating = rating
        self.reviewCount = reviewCount
        self.isFavorite = isFavorite
        self.discount = discount
    }
}
