//
//  CompositionRoot.swift
//  WBDarkstore
//
//  Created by Valeriy Solovey on 04.09.2026.
//

import BusinessLogic
import NetworkPackage

struct CompositionRoot {
    let catalogService: CatalogService
    let productService: ProductService

    init(token: String) throws {
        let apiClient = try APIClient(token: token)
        let catalogAPI = CatalogAPI(apiClient: apiClient)
        let productAPI = ProductAPI(apiClient: apiClient)

        catalogService = CatalogService(api: catalogAPI)
        productService = ProductService(productAPI: productAPI)
    }
}
