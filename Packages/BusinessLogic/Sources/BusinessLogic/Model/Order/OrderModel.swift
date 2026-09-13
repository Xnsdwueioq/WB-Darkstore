//
//  OrderModel.swift
//  BusinessLogic
//
//  Created by Илья Ермаков on 10.09.2026.
//

import Foundation

@MainActor
public protocol OrderModelProtocol: AnyObject, Observable {
    var state: ScreenState<[Order]> { get }
    func loadOrders() async
    func createOrder(paymentMethod: String, addressID: String) async
}

@MainActor
@Observable
public final class OrderModel: OrderModelProtocol {
    public private(set) var state: ScreenState<[Order]> = .loading

    private let orderService: any OrderServiceProtocol

    public init(orderService: any OrderServiceProtocol) {
        self.orderService = orderService
    }

    public func loadOrders() async {
        state = .loading
        do {
            let orders = try await orderService.getOrders()
            state = .content(orders)
        } catch {
            state = .error(error)
        }
    }

    public func createOrder(paymentMethod: String, addressID: String) async {
        do {
            try await orderService.createOrder(paymentMethod: paymentMethod, addressID: addressID)
            await loadOrders()
        } catch {
            state = .error(error)
        }
    }
}
