//
//  File.swift
//  BusinessLogic
//
//  Created by Илья Ермаков on 09.09.2026.
//

import Foundation
import Testing
@testable import BusinessLogic

@Suite("CatalogModel")
@MainActor
struct CatalogModelTests {
    @Test("Initial state is loading")
    func initialStateIsLoading() {
        let service = CatalogServiceMock()
        let model = CatalogModel(catalogService: service)

        guard case .loading = model.state else {
            Issue.record("Expected initial state to be .loading")
            return
        }
    }

    @Test("Loads categories and updates state to content")
    func loadCategoriesSuccess() async {
        let expectedCategories = [
            BusinessLogic.Category(
                id: "category-1",
                name: "Vegetables",
                imageURL: URL(string: "https://example.com/vegetables.png")
            )
        ]
        let service = CatalogServiceMock(categoriesResult: .success(expectedCategories))
        let model = CatalogModel(catalogService: service)

        await model.loadCategories()

        guard case .content(let categories) = model.state else {
            Issue.record("Expected state to be .content after successful load")
            return
        }
        #expect(categories.count == 1)
        #expect(categories.first?.id == "category-1")
        #expect(categories.first?.name == "Vegetables")
    }

    @Test("Propagates service error into error state")
    func loadCategoriesFailure() async {
        let service = CatalogServiceMock(categoriesResult: .failure(.requestFailed))
        let model = CatalogModel(catalogService: service)

        await model.loadCategories()

        guard case .error = model.state else {
            Issue.record("Expected state to be .error after failed load")
            return
        }
    }
    
    @Test("Initial products state is loading")
    func initialProductsStateIsLoading() {
        let service = CatalogServiceMock()
        let model = CatalogModel(catalogService: service)

        guard case .loading = model.productsState else {
            Issue.record("Expected initial products state to be .loading")
            return
        }
    }

    @Test("Loads products and updates productsState to content")
    func loadProductsSuccess() async {
        let expectedList = ProductList(
            currentPage: 1,
            totalPages: 1,
            products: [
                Product(
                    id: "product-1",
                    name: "Tomatoes",
                    imageURL: URL(string: "https://example.com/tomatoes.png"),
                    weight: 0.5,
                    price: 249,
                    rating: 4.8,
                    reviewCount: 42,
                    isFavorite: false,
                    discount: nil
                )
            ]
        )
        let service = CatalogServiceMock(productsResult: .success(expectedList))
        let model = CatalogModel(catalogService: service)

        await model.loadProducts(categoryID: "category-1", page: 1, pageSize: 20)

        guard case .content(let productList) = model.productsState else {
            Issue.record("Expected productsState to be .content after successful load")
            return
        }
        #expect(productList == expectedList)
    }

    @Test("Propagates service error into productsState error case")
    func loadProductsFailure() async {
        let service = CatalogServiceMock(productsResult: .failure(.requestFailed))
        let model = CatalogModel(catalogService: service)

        await model.loadProducts(categoryID: nil, page: nil, pageSize: nil)

        guard case .error = model.productsState else {
            Issue.record("Expected productsState to be .error after failed load")
            return
        }
    }
}
