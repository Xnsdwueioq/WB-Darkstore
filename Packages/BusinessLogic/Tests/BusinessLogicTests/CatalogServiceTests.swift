import Foundation
import NetworkPackage
import Testing
@testable import BusinessLogic

@Suite("CatalogService")
struct CatalogServiceTests {
    @Test("Maps category DTOs to domain models")
    func mapsCategories() async throws {
        let api = CatalogAPIMock(
            response: .success([
                CategoryDTO(
                    id: "category-1",
                    name: "Vegetables",
                    image: "https://example.com/vegetables.png"
                )
            ])
        )
        let service = CatalogService(api: api)

        let categories = try await service.getCategories()

        let category = try #require(categories.first)
        #expect(categories.count == 1)
        #expect(category.id == "category-1")
        #expect(category.name == "Vegetables")
        #expect(category.imageURL == URL(string: "https://example.com/vegetables.png"))
    }

    @Test("Propagates API errors")
    func propagatesError() async {
        let api = CatalogAPIMock(response: .failure(.requestFailed))
        let service = CatalogService(api: api)

        await #expect(throws: CatalogAPIMock.MockError.self) {
            try await service.getCategories()
        }
    }
}
