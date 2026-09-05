//
//  ProductServiceTests.swift
//  BusinessLogic
//
//  Created by Valeriy Solovey on 05.09.2026.
//

import Foundation
import NetworkPackage
import Testing
@testable import BusinessLogic

@Suite("ProductService")
struct ProductServiceTests {
    @Test("Maps product details and reviews to domain models")
    func mapsProductDetails() async throws {
        let createdAt = Date(timeIntervalSince1970: 1_789_000_000)
        let api = ProductAPIMock(
            fetchResponse: .success(
                ProductDetailsDTO(
                    id: "product-1",
                    name: "Tomatoes",
                    image: "https://example.com/tomatoes.png",
                    weight: 0.5,
                    price: 249,
                    rating: 4.8,
                    description: "Fresh tomatoes",
                    isFavorite: true,
                    discount: 15,
                    reviews: [
                        ReviewDTO(
                            rating: 5,
                            author: "Alex",
                            createdAt: createdAt,
                            content: "Great",
                            images: [
                                "https://example.com/review.png",
                                "http://["
                            ]
                        )
                    ]
                )
            )
        )
        let service = ProductService(productAPI: api)

        let product = try await service.getProduct(id: "product-1")

        #expect(product.id == "product-1")
        #expect(product.name == "Tomatoes")
        #expect(product.imageURL == URL(string: "https://example.com/tomatoes.png"))
        #expect(product.weight == 0.5)
        #expect(product.price == 249)
        #expect(product.rating == 4.8)
        #expect(product.description == "Fresh tomatoes")
        #expect(product.isFavorite)
        #expect(product.discount == 15)

        let review = try #require(product.reviews.first)
        #expect(product.reviews.count == 1)
        #expect(review.rating == 5)
        #expect(review.author == "Alex")
        #expect(review.createdAt == createdAt)
        #expect(review.content == "Great")
        #expect(review.images == [URL(string: "https://example.com/review.png")!])
    }

    @Test("Routes favorite state to the matching API operation")
    func setsFavorite() async throws {
        let api = ProductAPIMock(fetchResponse: .failure(.requestFailed))
        let service = ProductService(productAPI: api)

        try await service.setFavorite(true, productID: "product-1")
        try await service.setFavorite(false, productID: "product-2")

        #expect(await api.addedFavoriteProductIDs == ["product-1"])
        #expect(await api.removedFavoriteProductIDs == ["product-2"])
    }

    @Test("Maps a new review to its DTO")
    func submitsReview() async throws {
        let api = ProductAPIMock(fetchResponse: .failure(.requestFailed))
        let service = ProductService(productAPI: api)
        let imageURL = try #require(URL(string: "https://example.com/new-review.png"))

        try await service.submitReview(
            productID: "product-1",
            review: NewReview(
                rating: 4,
                content: "Good",
                images: [imageURL]
            )
        )

        let submission = try #require(await api.submittedReviews.first)
        #expect(submission.productID == "product-1")
        #expect(
            submission.review == NewReviewDTO(
                rating: 4,
                content: "Good",
                images: ["https://example.com/new-review.png"]
            )
        )
    }

    @Test("Propagates product API errors")
    func propagatesError() async {
        let api = ProductAPIMock(fetchResponse: .failure(.requestFailed))
        let service = ProductService(productAPI: api)

        await #expect(throws: ProductAPIMock.MockError.self) {
            try await service.getProduct(id: "product-1")
        }
    }
}
