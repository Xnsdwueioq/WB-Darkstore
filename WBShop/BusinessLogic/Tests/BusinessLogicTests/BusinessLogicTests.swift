import XCTest
import SwiftData
import NetworkPackage
@testable import BusinessLogic

final class MockCatalogAPI: CatalogAPIProtocol, @unchecked Sendable {
    var productsResult: Result<ProductPageDTO, NetworkError> = .success(ProductPageDTO(currentPage: 1, totalPages: 1, data: []))
    var setFavoriteError: NetworkError?
    var setFavoriteCalls: [(id: String, isFavorite: Bool)] = []

    func fetchProducts(categoryID: String?, page: Int?, pageSize: Int?) async throws -> ProductPageDTO {
        try productsResult.get()
    }

    func fetchProduct(id: String) async throws -> ProductDTO {
        ProductDTO(id: id, name: "Test", image: "", weight: 1.0, price: 100, rating: 5.0, description: "Desc", isFavorite: false)
    }

    func fetchCategories() async throws -> [CategoryDTO] {
        [CategoryDTO(id: "1", name: "Cat1", image: "img")]
    }

    func setFavorite(id: String, isFavorite: Bool) async throws {
        setFavoriteCalls.append((id, isFavorite))
        if let error = setFavoriteError {
            throw error
        }
    }

    func addReview(productID: String, rating: Int, comment: String, images: [String]) async throws {}
}

@MainActor
final class BusinessLogicTests: XCTestCase {
    func testAuthServiceLogin() {
        let auth = AuthService()
        XCTAssertTrue(auth.login(username: "user", password: "pwd"))
        XCTAssertFalse(auth.login(username: "", password: "pwd"))
        XCTAssertFalse(auth.login(username: "user", password: ""))
    }

    func testSearchService() {
        let mockCatalog = MockCatalogAPI()
        let productService = ProductService(catalogAPI: mockCatalog)
        let searchService = SearchService(productService: productService)

        let preview1 = ProductPreview(id: "1", name: "Молоко 3.2%", image: "", weight: 1.0, price: 80, rating: 4.5, reviewCount: 10, isFavorite: false)
        let preview2 = ProductPreview(id: "2", name: "Хлеб белый", image: "", weight: 0.5, price: 40, rating: 4.8, reviewCount: 5, isFavorite: false)

        mockCatalog.productsResult = .success(ProductPageDTO(
            currentPage: 1,
            totalPages: 1,
            data: [
                ProductPreviewDTO(id: preview1.id, name: preview1.name, image: preview1.image, weight: preview1.weight, price: preview1.price, rating: preview1.rating, reviewCount: preview1.reviewCount, isFavorite: preview1.isFavorite),
                ProductPreviewDTO(id: preview2.id, name: preview2.name, image: preview2.image, weight: preview2.weight, price: preview2.price, rating: preview2.rating, reviewCount: preview2.reviewCount, isFavorite: preview2.isFavorite)
            ]
        ))

        Task {
            await productService.fetchProducts()
            let results = searchService.search(query: "мол")
            XCTAssertEqual(results.count, 1)
            XCTAssertEqual(results.first?.name, "Молоко 3.2%")
        }
    }

    func testFavoriteRollbackOnError() async {
        let mockCatalog = MockCatalogAPI()
        mockCatalog.setFavoriteError = NetworkError.http(statusCode: 500, message: "Server error")
        let productService = ProductService(catalogAPI: mockCatalog)

        XCTAssertFalse(productService.isFavorite(id: "item1"))
        await productService.toggleFavorite(id: "item1")

        // Should roll back to false because API failed
        XCTAssertFalse(productService.isFavorite(id: "item1"))
        XCTAssertNotNil(productService.errorMessage)
    }

    func testModelMappers() {
        let catDTO = CategoryDTO(id: "10", name: "Фрукты", image: "http://example.com/fruits.png")
        let cat = CatalogMapper.mapCategory(catDTO)
        XCTAssertEqual(cat.id, "10")
        XCTAssertEqual(cat.name, "Фрукты")

        let itemDTO = CartItemDTO(id: "p1", image: "img", name: "Apple", weight: 200, price: 50, quantity: 3, isAvailable: true)
        let item = CartMapper.mapCartItem(itemDTO)
        XCTAssertEqual(item.id, "p1")
        XCTAssertEqual(item.quantity, 3)

        let cartModel = CartModel(from: [item])
        XCTAssertEqual(cartModel.totalQuantity, 3)
    }
}
