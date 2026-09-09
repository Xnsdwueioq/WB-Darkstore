//
//  OrderService.swift
//  BusinessLogic
//
//  Created by Valeriy Solovey on 05.09.2026.
//

import Foundation
import NetworkPackage

public struct OrderService: OrderServiceProtocol {
    private let orderAPI: any OrderAPIProtocol

    public init(orderAPI: any OrderAPIProtocol) {
        self.orderAPI = orderAPI
    }

    public func createOrder(paymentMethod: String, addressID: String) async throws {
        try await orderAPI.createOrder(paymentMethod: paymentMethod, addressID: addressID)
    }

    public func getOrders() async throws -> [Order] {
        let dtos = try await orderAPI.fetchOrders()

        return try dtos.map { dto in
            let status: OrderStatus = switch dto.status {
            case .active: .active
            case .completed: .completed
            }

            return Order(
                id: dto.id,
                status: status,
                deliveryDate: dto.deliveryDate,
                address: try Address(dto: dto.address),
                orderPrice: dto.orderPrice,
                deliveryPrice: dto.deliveryPrice,
                totalPrice: dto.totalPrice,
                totalItems: dto.totalItems,
                items: dto.items.map {
                    OrderItem(
                        id: $0.id,
                        name: $0.name,
                        imageURL: URL(string: $0.image),
                        weight: $0.weight,
                        price: $0.price,
                        quantity: $0.quantity
                    )
                }
            )
        }
    }
}
