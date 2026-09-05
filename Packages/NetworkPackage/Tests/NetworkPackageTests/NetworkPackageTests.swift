//
//  NetworkPackageTests.swift
//  NetworkPackage
//
//  Created by Valeriy Solovey on 05.09.2026.
//

import Foundation
import Testing
@testable import NetworkPackage

@Suite
struct NetworkPackageTests {
    @Test
    func testServerConnection() async throws {
        let token = try #require(
            ProcessInfo.processInfo.environment["BEARER_TOKEN"]
        )

        let apiClient = try APIClient(token: token)
        let catalogAPI = CatalogAPI(apiClient: apiClient)

        let categories = try await catalogAPI.fetchCategories()

        #expect(!categories.isEmpty)
    }
}
