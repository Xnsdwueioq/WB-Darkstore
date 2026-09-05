//
//  ProductService.swift
//  BusinessLogic
//
//  Created by Valeriy Solovey on 04.09.2026.
//

import Foundation
import NetworkPackage

public struct ProductService: ProductServiceProtocol, Sendable {
    private let productAPI: any ProductAPIProtocol

    public init(productAPI: any ProductAPIProtocol) {
        self.productAPI = productAPI
    }

    public func getProduct(id: String) async throws -> ProductDetails {
        let dto = try await productAPI.fetchProduct(id: id)

        return .init(
            id: dto.id,
            name: dto.name,
            imageURL: URL(string: dto.image),
            weight: dto.weight,
            price: dto.price,
            rating: dto.rating,
            description: dto.description,
            isFavorite: dto.isFavorite,
            discount: dto.discount,
            reviews: dto.reviews?.map {
                Review(
                    rating: $0.rating,
                    author: $0.author,
                    createdAt: $0.createdAt,
                    content: $0.content,
                    images: $0.images.compactMap(URL.init(string:))
                )
            } ?? []
        )
    }

    public func setFavorite(
        _ isFavorite: Bool,
        productID: String
    ) async throws {
        if isFavorite {
            try await productAPI.addToFavorites(productID: productID)
        } else {
            try await productAPI.removeFromFavorites(productID: productID)
        }
    }

    public func submitReview(productID: String, review: NewReview) async throws {
        try await productAPI.submitReview(
            productID: productID,
            review: .init(
                rating: review.rating,
                content: review.content,
                images: review.images.map { $0.absoluteString }
            )
        )
    }
}
