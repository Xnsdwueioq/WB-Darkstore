import Foundation
import NetworkPackage

@MainActor
public protocol ProductServicing: AnyObject {
    var products: [ProductPreview] { get }
    var errorMessage: String? { get }
    var favProducts: [ProductPreview] { get }
    var categoryProducts: [ProductPreview] { get }
    var favoriteIds: Set<String> { get }

    func fetchProducts() async
    func fetchFavProducts() async
    func fetchProductDetail(id: String) async -> Product?
    func fetchCategoryProducts(categoryId: String) async
    func toggleFavorite(id: String) async
    func isFavorite(id: String) -> Bool
    func addReviewToProduct(productId: String, rating: Int, comment: String, images: [String]) async -> Product?
    func clearError()
}

@Observable
@MainActor
public final class ProductService: ProductServicing {
    public private(set) var products: [ProductPreview] = []
    public var errorMessage: String?
    public private(set) var favProducts: [ProductPreview] = []
    public private(set) var categoryProducts: [ProductPreview] = []
    public private(set) var favoriteIds: Set<String> = []

    private let catalogAPI: any CatalogAPIProtocol

    public init(catalogAPI: any CatalogAPIProtocol) {
        self.catalogAPI = catalogAPI
    }

    public func isFavorite(id: String) -> Bool {
        favoriteIds.contains(id)
    }

    public func fetchProducts() async {
        do {
            let pageDTO = try await catalogAPI.fetchProducts(categoryID: nil, page: nil, pageSize: nil)
            let mappedProducts = CatalogMapper.mapProductPreviews(pageDTO.data)

            self.products = mappedProducts
            self.favoriteIds = Set(
                mappedProducts
                    .filter(\.isFavorite)
                    .map(\.id)
            )
            self.favProducts = mappedProducts.filter {
                self.favoriteIds.contains($0.id)
            }
            self.clearError()
        } catch let error as NetworkError {
            self.errorMessage = error.localizedDescription
        } catch {
            self.errorMessage = "Ошибка сети: \(error.localizedDescription)"
        }
    }

    public func fetchProductDetail(id: String) async -> Product? {
        do {
            let productDTO = try await catalogAPI.fetchProduct(id: id)
            self.clearError()
            return CatalogMapper.mapProduct(productDTO)
        } catch let error as NetworkError {
            self.errorMessage = error.localizedDescription
            return nil
        } catch {
            self.errorMessage = "Ошибка сети: \(error.localizedDescription)"
            return nil
        }
    }

    public func fetchFavProducts() async {
        await fetchProducts()
    }

    public func fetchCategoryProducts(categoryId: String) async {
        do {
            let pageDTO = try await catalogAPI.fetchProducts(categoryID: categoryId, page: nil, pageSize: nil)
            self.categoryProducts = CatalogMapper.mapProductPreviews(pageDTO.data)
            self.clearError()
        } catch let error as NetworkError {
            self.errorMessage = error.localizedDescription
        } catch {
            self.errorMessage = "Ошибка сети: \(error.localizedDescription)"
        }
    }

    public func toggleFavorite(id: String) async {
        let wasFavorite = favoriteIds.contains(id)
        let newValue = !wasFavorite

        applyFavoriteChange(id: id, isFavorite: newValue)

        do {
            try await catalogAPI.setFavorite(id: id, isFavorite: newValue)
        } catch let error as NetworkError {
            applyFavoriteChange(id: id, isFavorite: wasFavorite)
            self.errorMessage = error.localizedDescription
        } catch {
            applyFavoriteChange(id: id, isFavorite: wasFavorite)
            self.errorMessage = "Ошибка сети: \(error.localizedDescription)"
        }
    }

    public func clearError() {
        if errorMessage != nil {
            errorMessage = nil
        }
    }

    private func applyFavoriteChange(id: String, isFavorite: Bool) {
        if isFavorite {
            favoriteIds.insert(id)
        } else {
            favoriteIds.remove(id)
        }
    }

    @discardableResult
    public func addReviewToProduct(
        productId: String,
        rating: Int,
        comment: String,
        images: [String] = []
    ) async -> Product? {
        do {
            try await catalogAPI.addReview(productID: productId, rating: rating, comment: comment, images: images)
            let updatedProduct = await fetchProductDetail(id: productId)
            self.clearError()
            return updatedProduct
        } catch let error as NetworkError {
            self.errorMessage = error.localizedDescription
            return nil
        } catch {
            self.errorMessage = "Ошибка сети: \(error.localizedDescription)"
            return nil
        }
    }
}
