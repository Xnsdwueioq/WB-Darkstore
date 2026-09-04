//
//  CatalogAPI.swift
//  NetworkPackage
//
//  Created by Valeriy Solovey on 04.09.2026.
//

public struct CatalogAPI: CatalogAPIProtocol {
    private let apiClient: APIClient

    public init(apiClient: APIClient) {
        self.apiClient = apiClient
    }

    public func fetchCategories() async throws -> [CategoryDTO] {
        let output = try await apiClient.client.getCategories(.init())
        
        switch output {
        case .ok(let response):
            let categories = try response.body.json

            return categories.map {
                CategoryDTO(
                    id: $0.id,
                    name: $0.name,
                    image: $0.image
                )
            }

        case .unauthorized(let response):
            let error = try response.body.json
            throw APIError.unauthorized(message: error.error)

        case .default(statusCode: let statusCode, let response):
            let error = try response.body.json
            throw APIError.server(
                statusCode: statusCode,
                message: error.error
            )
        }
    }
}
