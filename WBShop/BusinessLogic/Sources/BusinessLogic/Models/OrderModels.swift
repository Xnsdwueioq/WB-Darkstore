import Foundation

public enum OrderStatus: String, Sendable, Hashable {
    case active
    case completed
}

public struct OrderItem: Identifiable, Hashable, Sendable {
    public let id: String
    public let image: String
    public let name: String
    public let weight: Int
    public let price: Int
    public let quantity: Int

    public init(
        id: String,
        image: String,
        name: String,
        weight: Int,
        price: Int,
        quantity: Int
    ) {
        self.id = id
        self.image = image
        self.name = name
        self.weight = weight
        self.price = price
        self.quantity = quantity
    }
}

public struct Order: Identifiable, Hashable, Sendable {
    public let id: String
    public let status: OrderStatus
    public let deliveryDate: String?
    public let address: Address
    public let orderPrice: Int
    public let deliveryPrice: Int
    public let totalPrice: Int
    public let totalItems: Int
    public let items: [OrderItem]

    public init(
        id: String,
        status: OrderStatus,
        deliveryDate: String? = nil,
        address: Address,
        orderPrice: Int,
        deliveryPrice: Int,
        totalPrice: Int,
        totalItems: Int,
        items: [OrderItem]
    ) {
        self.id = id
        self.status = status
        self.deliveryDate = deliveryDate
        self.address = address
        self.orderPrice = orderPrice
        self.deliveryPrice = deliveryPrice
        self.totalPrice = totalPrice
        self.totalItems = totalItems
        self.items = items
    }
}
