//
//  CatalogAPIProtocol.swift
//  NetworkPackage
//
//  Created by Valeriy Solovey on 04.09.2026.
//

public protocol CatalogAPIProtocol: Sendable {
    func fetchCategories() async throws -> [CategoryDTO]
    func fetchProducts(
        categoryID: String?,
        page: Int?,
        pageSize: Int?
    ) async throws -> ProductListDTO
}
