import Foundation
import SwiftData

struct CartProduct: Identifiable, Hashable, Sendable {
    let id: String
    let image: String
    let name: String
    let weight: Int
    let price: Int
    let quantity: Int
    let isAvailable: Bool
}

protocol CartServicing {
    func fetchProducts() async
    var productsInCart: [CartProduct] { get }
    var errorMessage: String? { get }
    var cartQuantities: [String: Int] { get }
    func addProductToCart(id: String, productInfo: CartProduct?) async
    func removeProductFromCart(id: String) async
    func deleteProductFromCart(id: String) async
    func createOrder(paymentMethod: String, addressId: String) async
    func clearErrorMessage()
}

extension CartServicing {
    func addProductToCart(id: String) async {
        await addProductToCart(id: id, productInfo: nil)
    }
}

@Observable
@MainActor
final class CartService: CartServicing {
    private let store: CartStore

    public private(set) var productsInCart: [CartProduct] = []
    public var errorMessage: String?

    public var cartQuantities: [String: Int] {
        Dictionary(uniqueKeysWithValues: productsInCart.map { ($0.id, $0.quantity) })
    }

    init(modelContainer: ModelContainer) {
        store = CartStore(modelContainer: modelContainer)
        Task {
            apply(await store.currentSnapshot())
        }
    }

    func fetchProducts() async {
        await apply(await store.fetchProducts())
    }

    func addProductToCart(id: String, productInfo: CartProduct? = nil) async {
        await apply(await store.addProductToCart(id: id, productInfo: productInfo))
    }

    func removeProductFromCart(id: String) async {
        await apply(await store.removeProductFromCart(id: id))
    }

    func deleteProductFromCart(id: String) async {
        await apply(await store.deleteProductFromCart(id: id))
    }

    func createOrder(paymentMethod: String, addressId: String) async {
        await apply(await store.createOrder(paymentMethod: paymentMethod, addressId: addressId))
    }

    func clearErrorMessage() {
        if errorMessage != nil {
            errorMessage = nil
        }
    }

    private func apply(_ snapshot: CartStore.Snapshot) {
        productsInCart = snapshot.products
        errorMessage = snapshot.errorMessage
    }
}

extension CartServicing {
    var totalPrice: Int {
        productsInCart.reduce(0) { $0 + $1.price * $1.quantity }
    }

    var cartModel: CartModel {
        CartModel(from: productsInCart)
    }
}
