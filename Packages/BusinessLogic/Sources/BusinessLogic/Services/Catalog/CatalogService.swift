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
}
