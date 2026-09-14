import Foundation
import SwiftData
import NetworkPackage

@MainActor
public protocol CartServicing: AnyObject {
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

public extension CartServicing {
    func addProductToCart(id: String) async {
        await addProductToCart(id: id, productInfo: nil)
    }

    var totalPrice: Int {
        productsInCart.reduce(0) { $0 + $1.price * $1.quantity }
    }

    var cartModel: CartModel {
        CartModel(from: productsInCart)
    }
}

@Observable
@MainActor
public final class CartService: CartServicing {
    private let store: CartStore

    public private(set) var productsInCart: [CartProduct] = []
    public var errorMessage: String?

    public var cartQuantities: [String: Int] {
        Dictionary(uniqueKeysWithValues: productsInCart.map { ($0.id, $0.quantity) })
    }

    init(store: CartStore) {
        self.store = store
        Task {
            apply(await store.currentSnapshot())
        }
    }

    public convenience init(
        cartAPI: any CartAPIProtocol,
        orderAPI: any OrderAPIProtocol,
        modelContainer: ModelContainer
    ) {
        let store = CartStore(cartAPI: cartAPI, orderAPI: orderAPI, modelContainer: modelContainer)
        self.init(store: store)
    }

    public func fetchProducts() async {
        apply(await store.fetchProducts())
    }

    public func addProductToCart(id: String, productInfo: CartProduct? = nil) async {
        apply(await store.addProductToCart(id: id, productInfo: productInfo))
    }

    public func removeProductFromCart(id: String) async {
        apply(await store.removeProductFromCart(id: id))
    }

    public func deleteProductFromCart(id: String) async {
        apply(await store.deleteProductFromCart(id: id))
    }

    public func createOrder(paymentMethod: String, addressId: String) async {
        apply(await store.createOrder(paymentMethod: paymentMethod, addressId: addressId))
    }

    public func clearErrorMessage() {
        if errorMessage != nil {
            errorMessage = nil
        }
    }

    private func apply(_ snapshot: CartStore.Snapshot) {
        productsInCart = snapshot.products
        errorMessage = snapshot.errorMessage
    }
}
