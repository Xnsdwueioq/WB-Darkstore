//
//  CatalogServiceMock.swift
//  BusinessLogic
//
//  Created by Илья Ермаков on 09.09.2026.
//

import Foundation
@testable import BusinessLogic

struct CatalogServiceMock: CatalogServiceProtocol {
    enum MockError: Error {
        case requestFailed
    }

    enum CategoriesResult {
        case success([BusinessLogic.Category])
        case failure(MockError)
    }

    enum ProductsResult {
        case success(ProductList)
        case failure(MockError)
    }

    let categoriesResult: CategoriesResult
    let productsResult: ProductsResult

    init(
        categoriesResult: CategoriesResult = .success([]),
        productsResult: ProductsResult = .failure(.requestFailed)
    ) {
        self.categoriesResult = categoriesResult
        self.productsResult = productsResult
    }

    func getCategories() async throws -> [BusinessLogic.Category] {
        switch categoriesResult {
        case .success(let categories):
            categories
        case .failure(let error):
            throw error
        }
    }

    func getProducts(
        categoryID: String?,
        page: Int?,
        pageSize: Int?
    ) async throws -> ProductList {
        switch productsResult {
        case .success(let productList):
            productList
        case .failure(let error):
            throw error
        }
    }
}
