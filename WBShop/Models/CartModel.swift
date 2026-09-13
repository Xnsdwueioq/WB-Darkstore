import SwiftData

@Model
final class CartItemModel {
    @Attribute(.unique) var id: String
    var image: String
    var name: String
    var weight: Int
    var price: Int
    var quantity: Int
    var isAvailable: Bool

    init(
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
