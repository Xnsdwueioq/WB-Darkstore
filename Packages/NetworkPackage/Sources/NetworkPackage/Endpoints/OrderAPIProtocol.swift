//
//  OrderAPIProtocol.swift
//  NetworkPackage
//
//  Created by Valeriy Solovey on 05.09.2026.
//

public protocol OrderAPIProtocol: Sendable {
    func createOrder(paymentMethod: String, addressID: String) async throws
    func fetchOrders() async throws -> [OrderDTO]
}
