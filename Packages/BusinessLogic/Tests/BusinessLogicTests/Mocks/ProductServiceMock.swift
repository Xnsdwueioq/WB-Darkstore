//
//  ProductServiceMock.swift
//  BusinessLogic
//
//  Created by Илья Ермаков on 11.09.2026.
//

import Foundation
@testable import BusinessLogic

struct ProductServiceMock: ProductServiceProtocol {
    enum MockError: Error {
        case requestFailed
    }

    enum SetFavoriteResult {
        case success
        case failure(MockError)
    }

    let setFavoriteResult: SetFavoriteResult

    init(setFavoriteResult: SetFavoriteResult = .success) {
        self.setFavoriteResult = setFavoriteResult
    }

    func getProduct(id: String) async throws -> ProductDetails {
        throw MockError.requestFailed
    }

    func setFavorite(_ isFavorite: Bool, productID: String) async throws {
        switch setFavoriteResult {
        case .success:
            return
        case .failure(let error):
            throw error
        }
    }

    func submitReview(productID: String, review: NewReview) async throws {
        throw MockError.requestFailed
    }
}
