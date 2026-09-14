import Foundation

public struct CartItemDTO: Sendable, Hashable, Identifiable {
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

public struct CartDTO: Sendable, Hashable {
    public let items: [CartItemDTO]

    public init(items: [CartItemDTO]) {
        self.items = items
    }
}
