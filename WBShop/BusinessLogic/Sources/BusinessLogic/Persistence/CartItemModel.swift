import Foundation
import SwiftData

@Model
public final class CartItemModel {
    @Attribute(.unique) public var id: String
    public var image: String
    public var name: String
    public var weight: Int
    public var price: Int
    public var quantity: Int
    public var isAvailable: Bool

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
