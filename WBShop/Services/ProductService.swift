import Foundation
import OpenAPIRuntime
import OpenAPIURLSession

protocol ProductServicing {
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
    func addReviewToProduct(productId: String ,rating: Int, comment: String, images: [String]) async -> Product?
    func clearError()
}

@Observable
final class ProductService: ProductServicing {
    var products: [ProductPreview] = []
    var errorMessage: String?
    var favProducts: [ProductPreview] = []
    var categoryProducts: [ProductPreview] = []
    var favoriteIds: Set<String> = []
    
    private let client: APIProtocol
    
    init() {
        do {
            client = Client(
                serverURL: try Servers.Server1.url(),
                configuration: .init(dateTranscoder: FlexibleISO8601DateTranscoder()),
                transport: URLSessionTransport(),
                middlewares: [AuthMiddleware()]
            )
        } catch {
            fatalError("Не удалось создать URL сервера: \(error)")
        }
    }
    
    func isFavorite(id: String) -> Bool {
        favoriteIds.contains(id)
    }
    
    func fetchProducts() async {
        do {
            let response = try await client.get_sol_products()
            
            switch response {
            case .ok(let okResponse):
                let body = try okResponse.body.json
                await MainActor.run {
                    self.products = body.data
                    
                    self.favoriteIds = Set(
                        body.data
                            .filter(\.isFavorite)
                            .map(\.id)
                    )
                    
                    self.favProducts = body.data.filter {
                        self.favoriteIds.contains($0.id)
                    }
                    self.clearError()
                }
                
            case .badRequest(let error):
                await handleError(try? error.body.json.error, default: "Некорректный запрос")
                
            case .unauthorized(let error):
                await handleError(try? error.body.json.error, default: "Требуется авторизация")
                
            case .default(let statusCode, let error):
                await handleError(try? error.body.json.error, default: "Ошибка сервера (\(statusCode))")
            }
        } catch {
            await handleNetworkError(error)
        }
    }
    
    func fetchProductDetail(id: String) async -> Product? {
        do {
            let response = try await client.get_sol_products_sol__lcub_id_rcub_(path: .init(id: id))
            switch response {
            case .ok(let okResponse):
                let body = try okResponse.body.json
                await MainActor.run { self.clearError() }
                return body
            case .unauthorized:
                await handleError(nil, default: "Требуется авторизация")
            case .default(let statusCode, _):
                await handleError(nil, default: "Ошибка сервера (\(statusCode))")
            case .notFound:
                await handleError(nil, default: "Not found")
            }
        } catch {
            await handleNetworkError(error)
        }
        return nil
    }
    
    func fetchFavProducts() async -> Void {
        await fetchProducts()
    }
    
    func fetchCategoryProducts(categoryId: String) async {
        do {
            let response = try await client.get_sol_products(
                query: .init(category: categoryId)
            )
            
            switch response {
            case .ok(let okResponse):
                let body = try okResponse.body.json
                await MainActor.run {
                    self.categoryProducts = body.data
                    self.clearError()
                }
                
            case .badRequest(let error):
                await handleError(try? error.body.json.error, default: "Некорректный запрос")
                
            case .unauthorized(let error):
                await handleError(try? error.body.json.error, default: "Требуется авторизация")
                
            case .default(let statusCode, let error):
                await handleError(try? error.body.json.error, default: "Ошибка сервера (\(statusCode))")
            }
        } catch {
            await handleNetworkError(error)
        }
    }
    
    func toggleFavorite(id: String) async {
        let wasFavorite = favoriteIds.contains(id)
        let newValue = !wasFavorite
        
        await MainActor.run {
            applyFavoriteChange(id: id, isFavorite: newValue)
        }
        
        do {
            if newValue {
                let response = try await client.post_sol_products_sol__lcub_id_rcub__sol_favourite(path: .init(id: id))
                
                switch response {
                case .ok:
                    break
                case .unauthorized(let error):
                    await handleError(
                        try? error.body.json.error,
                        default: "Требуется авторизация",
                        revertFavorite: id,
                        isFavorite: wasFavorite
                    )
                case .notFound(let error):
                    await handleError(
                        try? error.body.json.error,
                        default: "Товар не найден",
                        revertFavorite: id,
                        isFavorite: wasFavorite
                    )
                case .default(let statusCode, let error):
                    await handleError(
                        try? error.body.json.error,
                        default: "Ошибка сервера (\(statusCode))",
                        revertFavorite: id,
                        isFavorite: wasFavorite
                    )
                }
            } else {
                let response = try await client.delete_sol_products_sol__lcub_id_rcub__sol_favourite(path: .init(id: id))
                
                switch response {
                case .ok:
                    break
                case .unauthorized(let error):
                    await handleError(
                        try? error.body.json.error,
                        default: "Требуется авторизация",
                        revertFavorite: id,
                        isFavorite: wasFavorite
                    )
                case .notFound(let error):
                    await handleError(
                        try? error.body.json.error,
                        default: "Товар не найден",
                        revertFavorite: id,
                        isFavorite: wasFavorite
                    )
                case .default(let statusCode, let error):
                    await handleError(
                        try? error.body.json.error,
                        default: "Ошибка сервера (\(statusCode))",
                        revertFavorite: id,
                        isFavorite: wasFavorite
                    )
                }
            }
        } catch {
            await handleNetworkError(error, revertFavorite: id, isFavorite: wasFavorite)
        }
    }
    
    @MainActor
    private func handleError(_ message: String?, default defaultMessage: String, revertFavorite id: String? = nil, isFavorite: Bool = false) {
        self.errorMessage = message ?? defaultMessage
        if let id {
            applyFavoriteChange(id: id, isFavorite: isFavorite)
        }
    }
    
    @MainActor
    private func handleNetworkError(_ error: Error,revertFavorite id: String? = nil,isFavorite: Bool = false) {
        self.errorMessage = "Ошибка сети: \(error.localizedDescription)"
        if let id {
            applyFavoriteChange(id: id, isFavorite: isFavorite)
        }
    }
    
    public func clearError() {
        if errorMessage != nil {
            errorMessage = nil
        }
    }
    
    @MainActor
    private func applyFavoriteChange(id: String, isFavorite: Bool) {
        if isFavorite {
            favoriteIds.insert(id)
        } else {
            favoriteIds.remove(id)
        }
    }
    
    @discardableResult
    func addReviewToProduct(productId: String, rating: Int, comment: String, images: [String] = []) async -> Product? {
        do {
            let response = try await client.post_sol_products_sol__lcub_id_rcub__sol_reviews(
                path: .init(id: productId),
                body: .json(.init(rating: rating, content: comment, images: images))
            )
            
            switch response {
            case .ok:
                let updatedProduct = await fetchProductDetail(id: productId)
                await MainActor.run { self.clearError() }
                return updatedProduct
                
            case .unauthorized(let error):
                await handleError(try? error.body.json.error, default: "Требуется авторизация")
                
            case .default(let statusCode, let error):
                await handleError(try? error.body.json.error, default: "Ошибка сервера (\(statusCode))")
                
            case .badRequest(let error):
                await handleError(try? error.body.json.error, default: "Bad request")
            }
        } catch {
            await handleNetworkError(error)
        }
        return nil
    }
}
