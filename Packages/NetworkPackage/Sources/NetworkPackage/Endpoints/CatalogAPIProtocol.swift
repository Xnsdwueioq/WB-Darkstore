//
//  CatalogAPIProtocol.swift
//  NetworkPackage
//
//  Created by Valeriy Solovey on 04.09.2026.
//

public protocol CatalogAPIProtocol: Sendable {
    func fetchCategories() async throws -> [CategoryDTO]
}
