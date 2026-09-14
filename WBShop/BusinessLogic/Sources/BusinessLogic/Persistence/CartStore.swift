import Foundation
import NetworkPackage
import SwiftData

actor CartStore {
    struct Snapshot: Sendable {
        let products: [CartProduct]
        let errorMessage: String?
    }

    private enum DeleteItemOutcome: Sendable {
        case success
        case failure(String)
    }

    private let cartAPI: any CartAPIProtocol
    private let orderAPI: any OrderAPIProtocol
    private let modelContainer: ModelContainer
    private var isFetching = false

    private var cartQuantities: [String: Int] = [:]
    private var productDetails: [String: CartProduct] = [:]

    private var productsInCart: [CartProduct] {
        cartQuantities.compactMap { id, quantity in
            guard let details = productDetails[id], quantity > 0 else { return nil }
            return CartProduct(
                id: details.id,
                image: details.image,
                name: details.name,
                weight: details.weight,
                price: details.price,
                quantity: quantity,
                isAvailable: details.isAvailable
            )
        }
        .sorted { $0.id < $1.id }
    }

    init(
        cartAPI: any CartAPIProtocol,
        orderAPI: any OrderAPIProtocol,
        modelContainer: ModelContainer
    ) {
        self.cartAPI = cartAPI
        self.orderAPI = orderAPI
        self.modelContainer = modelContainer

        let loaded = Self.loadLocalCart(from: modelContainer)
        cartQuantities = loaded.quantities
        productDetails = loaded.details
    }

    private func snapshot(errorMessage: String? = nil) -> Snapshot {
        Snapshot(products: productsInCart, errorMessage: errorMessage)
    }

    private func restoreQuantity(id: String, to quantity: Int) {
        if quantity > 0 {
            cartQuantities[id] = quantity
        } else {
            cartQuantities.removeValue(forKey: id)
        }
        saveLocalCart()
    }

    func currentSnapshot() -> Snapshot {
        snapshot()
    }

    func fetchProducts() async -> Snapshot {
        guard !isFetching else {
            return snapshot()
        }
        isFetching = true
        defer { isFetching = false }

        do {
            let cartDTO = try await cartAPI.fetchCart()
            let products = CartMapper.mapCartItems(cartDTO.items)

            var newQuantities: [String: Int] = [:]
            var newDetails: [String: CartProduct] = [:]

            for product in products {
                newQuantities[product.id] = product.quantity
                newDetails[product.id] = product
            }

            cartQuantities = newQuantities
            productDetails = newDetails
            saveLocalCart()
            return snapshot()
        } catch let error as NetworkError {
            return snapshot(errorMessage: error.localizedDescription)
        } catch {
            return snapshot(errorMessage: "Ошибка сети: \(error.localizedDescription)")
        }
    }

    func addProductToCart(id: String, productInfo: CartProduct?) async -> Snapshot {
        let previousQuantity = cartQuantities[id] ?? 0
        cartQuantities[id, default: 0] += 1

        if productDetails[id] == nil, let productInfo {
            productDetails[id] = productInfo
        }

        saveLocalCart()

        do {
            _ = try await cartAPI.addItem(id: id)
            if productDetails[id] == nil {
                return await fetchProducts()
            }
            return snapshot()
        } catch let error as NetworkError {
            restoreQuantity(id: id, to: previousQuantity)
            return snapshot(errorMessage: error.localizedDescription)
        } catch {
            restoreQuantity(id: id, to: previousQuantity)
            return snapshot(errorMessage: "Ошибка сети: \(error.localizedDescription)")
        }
    }

    func removeProductFromCart(id: String) async -> Snapshot {
        guard let currentQuantity = cartQuantities[id], currentQuantity > 0 else {
            return snapshot()
        }

        let newQuantity = currentQuantity - 1
        if newQuantity > 0 {
            cartQuantities[id] = newQuantity
        } else {
            cartQuantities.removeValue(forKey: id)
        }

        do {
            _ = try await cartAPI.removeItem(id: id)
            saveLocalCart()
            return snapshot()
        } catch let error as NetworkError {
            restoreQuantity(id: id, to: currentQuantity)
            return snapshot(errorMessage: error.localizedDescription)
        } catch {
            restoreQuantity(id: id, to: currentQuantity)
            return snapshot(errorMessage: "Ошибка сети: \(error.localizedDescription)")
        }
    }

    func deleteProductFromCart(id: String) async -> Snapshot {
        guard let currentQuantity = cartQuantities[id], currentQuantity > 0 else {
            return snapshot()
        }
        cartQuantities.removeValue(forKey: id)

        let cartAPI = self.cartAPI

        let outcomes = await withTaskGroup(of: DeleteItemOutcome.self) { group in
            for _ in 0..<currentQuantity {
                group.addTask {
                    do {
                        _ = try await cartAPI.removeItem(id: id)
                        return .success
                    } catch let error as NetworkError {
                        if case .http(let statusCode, _) = error, statusCode == 404 {
                            return .success
                        }
                        return .failure(error.localizedDescription)
                    } catch {
                        return .failure("Ошибка сети: \(error.localizedDescription)")
                    }
                }
            }

            var collected: [DeleteItemOutcome] = []
            collected.reserveCapacity(currentQuantity)
            for await outcome in group {
                collected.append(outcome)
            }
            return collected
        }

        let failures = outcomes.compactMap { outcome -> String? in
            if case .failure(let message) = outcome { return message }
            return nil
        }
        let succeededCount = outcomes.count - failures.count
        let remaining = currentQuantity - succeededCount

        if remaining > 0 {
            cartQuantities[id] = remaining
        }
        saveLocalCart()

        return snapshot(errorMessage: failures.first)
    }

    func createOrder(paymentMethod: String, addressId: String) async -> Snapshot {
        do {
            try await orderAPI.createOrder(paymentMethod: paymentMethod, addressID: addressId)
            return await fetchProducts()
        } catch let error as NetworkError {
            return snapshot(errorMessage: error.localizedDescription)
        } catch {
            return snapshot(errorMessage: "Ошибка сети: \(error.localizedDescription)")
        }
    }

    private static func loadLocalCart(
        from modelContainer: ModelContainer
    ) -> (quantities: [String: Int], details: [String: CartProduct]) {
        let context = ModelContext(modelContainer)

        var quantities: [String: Int] = [:]
        var details: [String: CartProduct] = [:]

        do {
            let items = try context.fetch(FetchDescriptor<CartItemModel>())

            for item in items {
                guard item.quantity > 0 else { continue }
                quantities[item.id] = item.quantity
                details[item.id] = CartProduct(
                    id: item.id,
                    image: item.image,
                    name: item.name,
                    weight: item.weight,
                    price: item.price,
                    quantity: item.quantity,
                    isAvailable: item.isAvailable
                )
            }
        } catch {
            print("Ошибка загрузки локальной корзины: \(error)")
        }

        return (quantities, details)
    }

    private func saveLocalCart() {
        let context = ModelContext(modelContainer)

        do {
            let existingItems = try context.fetch(FetchDescriptor<CartItemModel>())
            for item in existingItems {
                context.delete(item)
            }

            for product in productsInCart {
                let item = CartItemModel(
                    id: product.id,
                    image: product.image,
                    name: product.name,
                    weight: product.weight,
                    price: product.price,
                    quantity: product.quantity,
                    isAvailable: product.isAvailable
                )
                context.insert(item)
            }
            try context.save()
        } catch {
            print("Ошибка сохранения корзины: \(error)")
        }
    }
}
