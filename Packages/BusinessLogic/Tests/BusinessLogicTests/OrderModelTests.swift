//
//  OrderModelTests.swift
//  BusinessLogic
//
//  Created by Илья Ермаков on 10.09.2026.
//

import Foundation
import Testing
@testable import BusinessLogic

@Suite("OrderModel")
@MainActor
struct OrderModelTests {
    @Test("Initial state is loading")
    func initialStateIsLoading() {
        let service = OrderServiceMock()
        let model = OrderModel(orderService: service)

        guard case .loading = model.state else {
            Issue.record("Expected initial state to be .loading")
            return
        }
    }

    @Test("Loads orders and updates state to content")
    func loadOrdersSuccess() async {
        let expectedOrders = [
            BusinessLogic.Order(
                id: "order-1",
                status: .active,
                deliveryDate: "2026-09-15",
                address: BusinessLogic.Address(
                    coordinates: BusinessLogic.AddressCoordinates(longitude: 37.6, latitude: 55.75),
                    addressLine: "ул. Пушкина, д. 1",
                    floor: "3",
                    entrance: "2",
                    intercomCode: "123",
                    comment: nil
                ),
                orderPrice: 1200,
                deliveryPrice: 0,
                totalPrice: 1200,
                totalItems: 2,
                items: [
                    BusinessLogic.OrderItem(
                        id: "item-1",
                        name: "Tomatoes",
                        imageURL: URL(string: "https://example.com/tomatoes.png"),
                        weight: 500,
                        price: 249,
                        quantity: 2
                    )
                ]
            )
        ]
        let service = OrderServiceMock(ordersResult: .success(expectedOrders))
        let model = OrderModel(orderService: service)

        await model.loadOrders()

        guard case .content(let orders) = model.state else {
            Issue.record("Expected state to be .content after successful load")
            return
        }
        #expect(orders == expectedOrders)
    }

    @Test("Propagates service error into error state on load")
    func loadOrdersFailure() async {
        let service = OrderServiceMock(ordersResult: .failure(.requestFailed))
        let model = OrderModel(orderService: service)

        await model.loadOrders()

        guard case .error = model.state else {
            Issue.record("Expected state to be .error after failed load")
            return
        }
    }

    @Test("Creating an order reloads the list into content")
    func createOrderSuccess() async {
        let expectedOrders = [
            BusinessLogic.Order(
                id: "order-2",
                status: .active,
                deliveryDate: nil,
                address: BusinessLogic.Address(
                    coordinates: BusinessLogic.AddressCoordinates(longitude: 30.3, latitude: 59.9),
                    addressLine: "Невский пр., д. 10",
                    floor: nil,
                    entrance: nil,
                    intercomCode: nil,
                    comment: nil
                ),
                orderPrice: 500,
                deliveryPrice: 0,
                totalPrice: 500,
                totalItems: 1,
                items: []
            )
        ]
        let service = OrderServiceMock(ordersResult: .success(expectedOrders), createResult: .success)
        let model = OrderModel(orderService: service)

        await model.createOrder(paymentMethod: "card", addressID: "address-1")

        guard case .content(let orders) = model.state else {
            Issue.record("Expected state to be .content after successful create")
            return
        }
        #expect(orders == expectedOrders)
    }

    @Test("Failed order creation moves state to error without reloading")
    func createOrderFailure() async {
        let service = OrderServiceMock(
            ordersResult: .success([]),
            createResult: .failure(.requestFailed)
        )
        let model = OrderModel(orderService: service)

        await model.createOrder(paymentMethod: "card", addressID: "address-1")

        guard case .error = model.state else {
            Issue.record("Expected state to be .error after failed create")
            return
        }
    }
}
