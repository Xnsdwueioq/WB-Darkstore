//
//  OrderServiceProtocol.swift
//  BusinessLogic
//
//  Created by Valeriy Solovey on 05.09.2026.
//

public protocol OrderServiceProtocol: Sendable {
    func createOrder(paymentMethod: String, addressID: String) async throws
    func getOrders() async throws -> [Order]
}
