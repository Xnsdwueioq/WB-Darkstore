import Foundation
import NetworkPackage
import Testing
@testable import BusinessLogic

@Suite("OrderService")
struct OrderServiceTests {
    @Test("Maps orders, addresses and items while preserving server order")
    func mapsOrders() async throws {
        let dtos = [OrderStatusDTO.completed, .active].enumerated().map { index, status in
            OrderDTO(
                id: "order-\(index)",
                status: status,
                deliveryDate: index == 0 ? "5 сентября, 18:30" : nil,
                address: AddressDTO(
                    coordinates: [92.87, 56.01], addressLine: "Мира, 10",
                    floor: "5", entrance: "2", intercomCode: "42", comment: "Позвонить"
                ),
                orderPrice: 498, deliveryPrice: 99, totalPrice: 597, totalItems: 2,
                items: [OrderItemDTO(
                    id: "product-1", name: "Tomatoes",
                    image: index == 0 ? "https://example.com/tomatoes.png" : "http://[",
                    weight: 500, price: 249, quantity: 2
                )]
            )
        }
        let service = OrderService(orderAPI: OrderAPIMock(fetchResponse: .success(dtos)))

        let orders = try await service.getOrders()

        #expect(orders.map(\.id) == ["order-0", "order-1"])
        #expect(orders.map(\.status) == [.completed, .active])
        #expect(orders.map(\.deliveryDate) == ["5 сентября, 18:30", nil])
        for (index, order) in orders.enumerated() {
            #expect(order.address == Address(
                coordinates: [92.87, 56.01], addressLine: "Мира, 10",
                floor: "5", entrance: "2", intercomCode: "42", comment: "Позвонить"
            ))
            #expect(order.orderPrice == 498)
            #expect(order.deliveryPrice == 99)
            #expect(order.totalPrice == 597)
            #expect(order.totalItems == 2)
            #expect(order.items == [OrderItem(
                id: "product-1", name: "Tomatoes",
                imageURL: index == 0 ? URL(string: "https://example.com/tomatoes.png") : nil,
                weight: 500, price: 249, quantity: 2
            )])
        }
    }

    @Test("Preserves absent address details and empty order items")
    func mapsMinimalOrder() async throws {
        let dto = OrderDTO(
            id: "order-1", status: .active, deliveryDate: nil,
            address: AddressDTO(
                coordinates: [92.87, 56.01], addressLine: "Мира, 10",
                floor: nil, entrance: nil, intercomCode: nil, comment: nil
            ),
            orderPrice: 0, deliveryPrice: 0, totalPrice: 0, totalItems: 0, items: []
        )
        let service = OrderService(orderAPI: OrderAPIMock(fetchResponse: .success([dto])))

        let order = try #require(try await service.getOrders().first)

        #expect(order.address == Address(
            coordinates: [92.87, 56.01], addressLine: "Мира, 10",
            floor: nil, entrance: nil, intercomCode: nil, comment: nil
        ))
        #expect(order.items.isEmpty)
        #expect(order.deliveryDate == nil)
    }

    @Test("Returns an empty order history")
    func getsEmptyOrders() async throws {
        let service = OrderService(orderAPI: OrderAPIMock())

        #expect(try await service.getOrders().isEmpty)
    }

    @Test("Passes the payment method and address ID to order creation")
    func createsOrder() async throws {
        let api = OrderAPIMock()
        let service = OrderService(orderAPI: api)

        try await service.createOrder(paymentMethod: "card", addressID: "address-1")

        let calls = await api.createdOrders
        #expect(calls.count == 1)
        let call = try #require(calls.first)
        #expect(call.paymentMethod == "card")
        #expect(call.addressID == "address-1")
    }

    @Test("Propagates errors from both operations", arguments: [false, true])
    func propagatesErrors(creating: Bool) async {
        let api = OrderAPIMock(fetchResponse: .failure(.requestFailed), creationError: .requestFailed)
        let service = OrderService(orderAPI: api)

        await #expect(throws: OrderAPIMock.MockError.requestFailed) {
            if creating {
                try await service.createOrder(paymentMethod: "card", addressID: "address-1")
            } else {
                _ = try await service.getOrders()
            }
        }
    }
}
