#if DEBUG
import Foundation
import Core

@MainActor
enum PreviewContainer {
    static func install(isAuthenticated: Bool = true, selectedTab: MainTab = .catalog) {
        let router = Router()
        router.isAuthenticated = isAuthenticated
        router.selectedTab = selectedTab

        let products = PreviewProductService()
        ServiceLocator.shared.register(service: router)
        ServiceLocator.shared.register(service: router as RouterProtocol)
        ServiceLocator.shared.register(service: products as ProductServicing)
        ServiceLocator.shared.register(service: PreviewCategoryService() as CategoryServicing)
        ServiceLocator.shared.register(service: PreviewCartService(products: products.products) as CartServicing)
        ServiceLocator.shared.register(service: PreviewUserService() as UserServicing)
        ServiceLocator.shared.register(service: SearchService() as SearchServicing)
        ServiceLocator.shared.register(service: AuthService() as AuthServicing)
    }
}

@Observable
private final class PreviewProductService: ProductServicing {
    var products: [ProductPreview] = [
        ProductPreview(id: "apple", image: "https://damcdn.samokat.ru/dam-storage-ext-env-prod/2026/02/21fd6d4c-f87e-4f3c-be5d-454192c8a577",
                       name: "Яблоки", weight: 500, price: 129, rating: 4.8, reviewCount: 24, isFavorite: true),
        ProductPreview(id: "bread", image: "https://damcdn.samokat.ru/dam-storage-ext-env-prod/2025/11/34314761-fd0f-48b4-a82b-8e45f5c48c88",
                       name: "Хлеб пшеничный", weight: 400, price: 89, rating: 4.6, reviewCount: 12, isFavorite: false),
        ProductPreview(id: "milk", image: "https://damcdn.samokat.ru/dam-storage-ext-env-prod/2026/01/e1b14c69-0a4c-4ba5-9d0c-839dd4b6f34f",
                       name: "Молоко", weight: 950, price: 119, rating: 4.9, reviewCount: 31, isFavorite: false),
        ProductPreview(id: "cheese", image: "https://damcdn.samokat.ru/dam-storage-ext-env-prod/2026/07/28bd0c4d-1493-41dd-a0d7-4d0d1e30e015",
                       name: "Сыр", weight: 200, price: 249, rating: 4.7, reviewCount: 18, isFavorite: true)
    ]
    var errorMessage: String?
    var categoryProducts: [ProductPreview] = []
    var favoriteIds: Set<String> = ["apple", "cheese"]

    var favProducts: [ProductPreview] {
        products.filter { favoriteIds.contains($0.id) }
    }

    func fetchProducts() async {
        try? await Task.sleep(for: .seconds(1.5))
    }
    func fetchFavProducts() async {
        try? await Task.sleep(for: .seconds(1.5))
    }

    func fetchProductDetail(id: String) async -> Product? {
        guard let preview = products.first(where: { $0.id == id }) else { return nil }
        return Product(
            id: preview.id,
            image: preview.image,
            name: preview.name,
            weight: preview.weight,
            price: preview.price,
            rating: preview.rating,
            description: "Товар для просмотра интерфейса.",
            isFavorite: favoriteIds.contains(id)
        )
    }

    func fetchCategoryProducts(categoryId: String) async {
        try? await Task.sleep(for: .seconds(1.5))
        categoryProducts = categoryId == "bakery" ? [products[1]] : products.filter { $0.id != "bread" }
    }

    func toggleFavorite(id: String) async {
        if favoriteIds.contains(id) {
            favoriteIds.remove(id)
        } else {
            favoriteIds.insert(id)
        }
    }

    func isFavorite(id: String) -> Bool {
        favoriteIds.contains(id)
    }

    func addReviewToProduct(productId: String, rating: Int, comment: String, images: [String]) async -> Product? {
        await fetchProductDetail(id: productId)
    }

    func clearError() {
        errorMessage = nil
    }
}

@Observable
private final class PreviewCategoryService: CategoryServicing {
    var errorMessage: String?
    var categories: [Category] = [
        Category(id: "fruit", name: "Фрукты", image: "https://damcdn.samokat.ru/dam-storage-ext-env-prod/2026/01/df092d3f-c58b-4764-97b2-7fc4d210672f"),
        Category(id: "bakery", name: "Хлеб", image: "https://damcdn.samokat.ru/dam-storage-ext-env-prod/2026/01/de553d07-d946-4734-a3b2-e34860a810e8"),
        Category(id: "dairy", name: "Молочные продукты", image: "https://damcdn.samokat.ru/dam-storage-ext-env-prod/2026/04/ee4c1860-4f5f-4684-8325-7f20336cc25e")
    ]

    func fetchCategories() async {}
    func clearErrorMessage() { errorMessage = nil }
}

@Observable
private final class PreviewCartService: CartServicing {
    var productsInCart: [CartProduct] = []
    var errorMessage: String?
    private let availableProducts: [ProductPreview]

    init(products: [ProductPreview]) {
        availableProducts = products
    }

    var cartQuantities: [String: Int] {
        Dictionary(uniqueKeysWithValues: productsInCart.map { ($0.id, $0.quantity) })
    }

    func fetchProducts() async {}

    func addProductToCart(id: String, productInfo: CartProduct?) async {
        if let index = productsInCart.firstIndex(where: { $0.id == id }) {
            let item = productsInCart[index]
            productsInCart[index] = CartProduct(
                id: item.id, image: item.image, name: item.name, weight: item.weight,
                price: item.price, quantity: item.quantity + 1, isAvailable: item.isAvailable
            )
        } else if let item = productInfo {
            productsInCart.append(item)
        } else if let product = availableProducts.first(where: { $0.id == id }) {
            productsInCart.append(CartProduct(
                id: product.id, image: product.image, name: product.name,
                weight: Int(product.weight), price: product.price, quantity: 1, isAvailable: true
            ))
        }
    }

    func removeProductFromCart(id: String) async {
        guard let index = productsInCart.firstIndex(where: { $0.id == id }) else { return }
        let item = productsInCart[index]
        if item.quantity == 1 {
            productsInCart.remove(at: index)
        } else {
            productsInCart[index] = CartProduct(
                id: item.id, image: item.image, name: item.name, weight: item.weight,
                price: item.price, quantity: item.quantity - 1, isAvailable: item.isAvailable
            )
        }
    }

    func deleteProductFromCart(id: String) async {
        productsInCart.removeAll { $0.id == id }
    }

    func createOrder(paymentMethod: String, addressId: String) async {}
    func clearErrorMessage() { errorMessage = nil }
}

@Observable
@MainActor
private final class PreviewUserService: UserServicing {
    var addresses: [IdentifiableAddress] = []
    var orders: [Order] = []
    var errorMessage: String?

    func currentUserName() async -> String { "Гость" }
    func getAddresses() async {}
    func addAddress(_ address: Components.Schemas.Address) async -> Bool { false }
    func updateAddress(id: String, _ address: Components.Schemas.Address) async -> Bool { false }
    func deleteAddress(id: String) async {}
    func clearErrorMessage() { errorMessage = nil }
    func getOrders() async {}
    func getProfileInfo() async -> User { User(name: "Гость", phone: "89994433220", birthday: "01.01.2026") }
    func editProfile(_ user: User) async -> Bool { false }
    func logout() async -> Bool { false }
    func deleteAccount() async -> Bool { false }
    func getActiveOrder() async -> Order? { nil }
}
#endif
