import Foundation
import SwiftData
import NetworkPackage

@MainActor
public struct BusinessLogicContainer {
    public let authService: any AuthServicing
    public let userService: any UserServicing
    public let cartService: any CartServicing
    public let productService: any ProductServicing
    public let categoryService: any CategoryServicing
    public let searchService: any SearchServicing

    public init(
        modelContainer: ModelContainer,
        tokenProvider: @escaping @Sendable () -> String?
    ) throws {
        let networkServices = try NetworkServices(tokenProvider: tokenProvider)

        let auth = AuthService()
        let product = ProductService(catalogAPI: networkServices.catalog)
        let category = CategoryService(catalogAPI: networkServices.catalog)
        let search = SearchService(productService: product)
        let user = UserService(
            profileAPI: networkServices.profile,
            addressAPI: networkServices.addresses,
            orderAPI: networkServices.orders
        )
        let cart = CartService(
            cartAPI: networkServices.cart,
            orderAPI: networkServices.orders,
            modelContainer: modelContainer
        )

        self.authService = auth
        self.userService = user
        self.cartService = cart
        self.productService = product
        self.categoryService = category
        self.searchService = search
    }

    public init(
        authService: any AuthServicing,
        userService: any UserServicing,
        cartService: any CartServicing,
        productService: any ProductServicing,
        categoryService: any CategoryServicing,
        searchService: any SearchServicing
    ) {
        self.authService = authService
        self.userService = userService
        self.cartService = cartService
        self.productService = productService
        self.categoryService = categoryService
        self.searchService = searchService
    }
}
