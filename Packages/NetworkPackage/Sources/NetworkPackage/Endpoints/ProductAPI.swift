//
//  ProductAPI.swift
//  NetworkPackage
//
//  Created by Valeriy Solovey on 04.09.2026.
//

public struct ProductAPI: ProductAPIProtocol {
    private let apiClient: APIClient

    public init(apiClient: APIClient) {
        self.apiClient = apiClient
    }

    public func fetchProduct(id: String) async throws -> ProductDetailsDTO {
        let output = try await apiClient.client.getProductsId(
            .init(path: .init(id: id))
        )

        switch output {
        case .ok(let response):
            let product = try response.body.json

            return ProductDetailsDTO(
                id: product.id,
                name: product.name,
                image: product.image,
                weight: product.weight,
                price: product.price,
                rating: product.rating,
                description: product.description,
                isFavorite: product.isFavorite,
                discount: product.discount,
                reviews: product.reviews?.map {
                    ReviewDTO(
                        rating: $0.rating,
                        author: $0.author,
                        createdAt: $0.createdAt,
                        content: $0.content,
                        images: $0.images
                    )
                }
            )

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

    public func addToFavorites(productID: String) async throws {
        let output = try await apiClient.client.postProductsIdFavourite(
            .init(path: .init(id: productID))
        )

        switch output {
        case .ok:
            return

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

    public func removeFromFavorites(productID: String) async throws {
        let output = try await apiClient.client.deleteProductsIdFavourite(
            .init(path: .init(id: productID))
        )

        switch output {
        case .ok:
            return

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

    public func submitReview(
        productID: String,
        review: NewReviewDTO
    ) async throws {
        let output = try await apiClient.client.postProductsIdReviews(
            .init(
                path: .init(id: productID),
                body: .json(
                    .init(
                        rating: review.rating,
                        content: review.content,
                        images: review.images
                    )
                )
            )
        )

        switch output {
        case .ok:
            return

        case .badRequest(let response):
            let error = try response.body.json
            throw APIError.badRequest(message: error.error)

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
}
