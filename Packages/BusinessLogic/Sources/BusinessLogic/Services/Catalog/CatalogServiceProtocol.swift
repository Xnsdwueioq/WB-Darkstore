//
//  CatalogServiceProtocol.swift
//  BusinessLogic
//
//  Created by Valeriy Solovey on 04.09.2026.
//

public protocol CatalogServiceProtocol {
    func getCategories() async throws -> [Category]
    func getProducts(
        categoryID: String?,
        page: Int?,
        pageSize: Int?
    ) async throws -> ProductList
}
