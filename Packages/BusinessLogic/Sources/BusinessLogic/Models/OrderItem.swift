import Foundation

public struct OrderItem: Sendable, Equatable, Identifiable {
    public let id: String
    public let name: String
    public let imageURL: URL?
    public let weight: Int
    public let price: Int
    public let quantity: Int

    public init(
        id: String,
        name: String,
        imageURL: URL?,
        weight: Int,
        price: Int,
        quantity: Int
    ) {
        self.id = id
        self.name = name
        self.imageURL = imageURL
        self.weight = weight
        self.price = price
        self.quantity = quantity
    }
}
