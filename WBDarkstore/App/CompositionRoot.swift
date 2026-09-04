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

    init(token: String) throws {
        let apiClient = try APIClient(token: token)
        let catalogAPI = CatalogAPI(apiClient: apiClient)

        catalogService = CatalogService(api: catalogAPI)
    }
}
