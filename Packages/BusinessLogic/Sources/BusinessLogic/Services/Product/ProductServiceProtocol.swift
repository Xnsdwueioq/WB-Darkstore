//
//  ProductServiceProtocol.swift
//  BusinessLogic
//
//  Created by Valeriy Solovey on 04.09.2026.
//

public protocol ProductServiceProtocol: Sendable {
    func getProduct(id: String) async throws -> ProductDetails
    func setFavorite(_ isFavorite: Bool, productID: String) async throws
    func submitReview(productID: String, review: NewReview) async throws
}
