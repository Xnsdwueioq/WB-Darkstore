//
//  Order.swift
//  BusinessLogic
//
//  Created by Valeriy Solovey on 05.09.2026.
//

public struct Order: Sendable, Equatable, Identifiable {
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
        deliveryDate: String?,
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
