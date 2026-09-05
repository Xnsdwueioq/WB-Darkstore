//
//  Cart.swift
//  BusinessLogic
//
//  Created by Valeriy Solovey on 05.09.2026.
//

public struct Cart: Sendable, Equatable {
    public let deliveryTime: Int
    public let orderPrice: Int
    public let deliveryPrice: Int
    public let totalPrice: Int
    public let totalItems: Int
    public let items: [CartItem]

    public init(
        deliveryTime: Int,
        orderPrice: Int,
        deliveryPrice: Int,
        totalPrice: Int,
        totalItems: Int,
        items: [CartItem]
    ) {
        self.deliveryTime = deliveryTime
        self.orderPrice = orderPrice
        self.deliveryPrice = deliveryPrice
        self.totalPrice = totalPrice
        self.totalItems = totalItems
        self.items = items
    }
}
