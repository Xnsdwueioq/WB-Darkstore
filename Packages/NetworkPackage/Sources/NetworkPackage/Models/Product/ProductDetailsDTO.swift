//
//  ProductDetailsDTO.swift
//  NetworkPackage
//
//  Created by Valeriy Solovey on 04.09.2026.
//

public struct ProductDetailsDTO: Sendable, Equatable {
    public let id: String
    public let name: String
    public let image: String
    public let weight: Double
    public let price: Int
    public let rating: Float
    public let description: String
    public let isFavorite: Bool
    public let discount: Double?
    public let reviews: [ReviewDTO]?

    public init(
        id: String,
        name: String,
        image: String,
        weight: Double,
        price: Int,
        rating: Float,
        description: String,
        isFavorite: Bool,
        discount: Double?,
        reviews: [ReviewDTO]?
    ) {
        self.id = id
        self.name = name
        self.image = image
        self.weight = weight
        self.price = price
        self.rating = rating
        self.description = description
        self.isFavorite = isFavorite
        self.discount = discount
        self.reviews = reviews
    }
}
