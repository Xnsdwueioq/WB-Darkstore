//
//  FavoritesModelTests.swift
//  BusinessLogic
//
//  Created by Илья Ермаков on 11.09.2026.
//

import Foundation
import Testing
@testable import BusinessLogic

@Suite("FavoritesModel")
@MainActor
struct FavoritesModelTests {
    @Test("Initial state is loading")
    func initialStateIsLoading() {
        let service = ProductServiceMock()
        let model = FavoritesModel(productService: service)

        guard case .loading = model.state else {
            Issue.record("Expected initial state to be .loading")
            return
        }
    }

    @Test("Marking as favorite updates state to content with true")
    func setFavoriteTrueSuccess() async {
        let service = ProductServiceMock(setFavoriteResult: .success)
        let model = FavoritesModel(productService: service)

        await model.setFavorite(true, productID: "product-1")

        guard case .content(let isFavorite) = model.state else {
            Issue.record("Expected state to be .content after successful update")
            return
        }
        #expect(isFavorite)
    }

    @Test("Unmarking as favorite updates state to content with false")
    func setFavoriteFalseSuccess() async {
        let service = ProductServiceMock(setFavoriteResult: .success)
        let model = FavoritesModel(productService: service)

        await model.setFavorite(false, productID: "product-1")

        guard case .content(let isFavorite) = model.state else {
            Issue.record("Expected state to be .content after successful update")
            return
        }
        #expect(!isFavorite)
    }

    @Test("Failed update with no prior content moves to error")
    func setFavoriteFailureWithNoPriorContent() async {
        let service = ProductServiceMock(setFavoriteResult: .failure(.requestFailed))
        let model = FavoritesModel(productService: service)

        await model.setFavorite(true, productID: "product-1")

        guard case .error = model.state else {
            Issue.record("Expected state to be .error after failed update with no prior content")
            return
        }
    }
}
