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

    @Test("Maps product list DTOs to domain models")
    func mapsProducts() async throws {
        let api = CatalogAPIMock(
            productsResponse: .success(
                ProductListDTO(
                    currentPage: 2,
                    totalPages: 4,
                    products: [
                        ProductPreviewDTO(
                            id: "product-1",
                            name: "Tomatoes",
                            image: "https://example.com/tomatoes.png",
                            weight: 0.5,
                            price: 249,
                            rating: 4.8,
                            reviewCount: 42,
                            isFavorite: true,
                            discount: 15
                        )
                    ]
                )
            )
        )
        let service = CatalogService(api: api)

        let productList = try await service.getProducts(
            categoryID: "category-1",
            page: 2,
            pageSize: 20
        )

        let product = try #require(productList.products.first)
        #expect(productList.currentPage == 2)
        #expect(productList.totalPages == 4)
        #expect(productList.products.count == 1)
        #expect(product.id == "product-1")
        #expect(product.name == "Tomatoes")
        #expect(product.imageURL == URL(string: "https://example.com/tomatoes.png"))
        #expect(product.weight == 0.5)
        #expect(product.price == 249)
        #expect(product.rating == 4.8)
        #expect(product.reviewCount == 42)
        #expect(product.isFavorite)
        #expect(product.discount == 15)
    }

    @Test("Propagates product API errors")
    func propagatesProductError() async {
        let api = CatalogAPIMock(productsResponse: .failure(.requestFailed))
        let service = CatalogService(api: api)

        await #expect(throws: CatalogAPIMock.MockError.self) {
            try await service.getProducts(
                categoryID: nil,
                page: nil,
                pageSize: nil
            )
        }
    }
}
