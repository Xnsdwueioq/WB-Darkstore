import Foundation

public struct CartProduct: Identifiable, Hashable, Sendable {
    public let id: String
    public let image: String
    public let name: String
    public let weight: Int
    public let price: Int
    public let quantity: Int
    public let isAvailable: Bool

    public init(
        id: String,
        image: String,
        name: String,
        weight: Int,
        price: Int,
        quantity: Int,
        isAvailable: Bool
    ) {
        self.id = id
        self.image = image
        self.name = name
        self.weight = weight
        self.price = price
        self.quantity = quantity
        self.isAvailable = isAvailable
    }
}

public struct CartModel: Sendable {
    public var items: [String: Int]

    public var totalQuantity: Int {
        items.values.reduce(0, +)
    }

    public init(from products: [CartProduct]) {
        self.items = Dictionary(uniqueKeysWithValues: products.map { ($0.id, $0.quantity) })
    }

    public init(items: [String: Int] = [:]) {
        self.items = items
    }
}
