//
//  OrderServiceMock.swift
//  BusinessLogic
//
//  Created by Илья Ермаков on 10.09.2026.
//

import Foundation
@testable import BusinessLogic

struct OrderServiceMock: OrderServiceProtocol {
    enum MockError: Error {
        case requestFailed
    }

    enum OrdersResult {
        case success([BusinessLogic.Order])
        case failure(MockError)
    }

    enum CreateResult {
        case success
        case failure(MockError)
    }

    let ordersResult: OrdersResult
    let createResult: CreateResult

    init(
        ordersResult: OrdersResult = .success([]),
        createResult: CreateResult = .success
    ) {
        self.ordersResult = ordersResult
        self.createResult = createResult
    }

    func createOrder(paymentMethod: String, addressID: String) async throws {
        switch createResult {
        case .success:
            return
        case .failure(let error):
            throw error
        }
    }

    func getOrders() async throws -> [BusinessLogic.Order] {
        switch ordersResult {
        case .success(let orders):
            orders
        case .failure(let error):
            throw error
        }
    }
}
