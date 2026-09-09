//
//  CatalogService.swift
//  BusinessLogic
//
//  Created by Valeriy Solovey on 04.09.2026.
//

import Foundation
import NetworkPackage

public struct CatalogService: CatalogServiceProtocol, Sendable {
    private let api: any CatalogAPIProtocol

    public init(api: any CatalogAPIProtocol) {
        self.api = api
    }

    public func getCategories() async throws -> [Category] {
        let categoriesRaw = try await api.fetchCategories()
        let categories = categoriesRaw.map {
            Category(
                id: $0.id,
                name: $0.name,
                imageURL: URL(string: $0.image)
            )
        }
        return categories
    }

    public func getProducts(
        categoryID: String? = nil,
        page: Int? = nil,
        pageSize: Int? = nil
    ) async throws -> ProductList {
        let productListRaw = try await api.fetchProducts(
            categoryID: categoryID,
            page: page,
            pageSize: pageSize
        )

        return ProductList(
            currentPage: productListRaw.currentPage,
            totalPages: productListRaw.totalPages,
            products: productListRaw.products.map {
                Product(
                    id: $0.id,
                    name: $0.name,
                    imageURL: URL(string: $0.image),
                    weight: $0.weight,
                    price: $0.price,
                    rating: $0.rating,
                    reviewCount: $0.reviewCount,
                    isFavorite: $0.isFavorite,
                    discount: $0.discount
                )
            }
        )
    }
}
