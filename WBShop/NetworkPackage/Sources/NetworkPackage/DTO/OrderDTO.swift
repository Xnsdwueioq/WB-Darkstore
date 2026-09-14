import Foundation

public struct OrderItemDTO: Sendable, Hashable, Identifiable {
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

public struct OrderDTO: Sendable, Hashable, Identifiable {
    public let id: String
    public let status: String
    public let deliveryDate: String?
    public let address: AddressDTO
    public let orderPrice: Int
    public let deliveryPrice: Int
    public let totalPrice: Int
    public let totalItems: Int
    public let items: [OrderItemDTO]

    public init(
        id: String,
        status: String,
        deliveryDate: String? = nil,
        address: AddressDTO,
        orderPrice: Int,
        deliveryPrice: Int,
        totalPrice: Int,
        totalItems: Int,
        items: [OrderItemDTO]
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
