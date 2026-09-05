public struct OrderDTO: Sendable, Equatable, Identifiable {
    public let id: String
    public let status: OrderStatusDTO
    public let deliveryDate: String?
    public let address: AddressDTO
    public let orderPrice: Int
    public let deliveryPrice: Int
    public let totalPrice: Int
    public let totalItems: Int
    public let items: [OrderItemDTO]

    public init(
        id: String,
        status: OrderStatusDTO,
        deliveryDate: String?,
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
