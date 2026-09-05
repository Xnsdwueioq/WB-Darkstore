//
//  ProductAPIProtocol.swift
//  NetworkPackage
//
//  Created by Valeriy Solovey on 04.09.2026.
//

public protocol ProductAPIProtocol: Sendable {
    func fetchProduct(id: String) async throws -> ProductDetailsDTO
    func addToFavorites(productID: String) async throws
    func removeFromFavorites(productID: String) async throws
    func submitReview(productID: String, review: NewReviewDTO) async throws
}
