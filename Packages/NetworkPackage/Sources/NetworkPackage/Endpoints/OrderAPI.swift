public struct OrderAPI: OrderAPIProtocol {
    private let apiClient: APIClient

    public init(apiClient: APIClient) {
        self.apiClient = apiClient
    }

    public func createOrder(paymentMethod: String, addressID: String) async throws {
        let output = try await apiClient.client.postOrders(
            .init(body: .json(.init(paymentMethod: paymentMethod, addressID: addressID)))
        )

        switch output {
        case .ok:
            return

        case .badRequest(let response):
            let error = try response.body.json
            throw APIError.badRequest(message: error.error)

        case .unauthorized(let response):
            let error = try response.body.json
            throw APIError.unauthorized(message: error.error)

        case .default(statusCode: let statusCode, let response):
            let error = try response.body.json
            throw APIError.server(
                statusCode: statusCode,
                message: error.error
            )
        }
    }

    public func fetchOrders() async throws -> [OrderDTO] {
        let output = try await apiClient.client.getOrders()

        switch output {
        case .ok(let response):
            let orders = try response.body.json

            return orders.map { order in
                let status: OrderStatusDTO = switch order.status {
                case .active: .active
                case .completed: .completed
                }

                return OrderDTO(
                    id: order.id,
                    status: status,
                    deliveryDate: order.deliveryDate,
                    address: AddressDTO(
                        coordinates: order.address.coordinates,
                        addressLine: order.address.addressLine,
                        floor: order.address.floor,
                        entrance: order.address.entrance,
                        intercomCode: order.address.intercomCode,
                        comment: order.address.comment
                    ),
                    orderPrice: order.orderPrice,
                    deliveryPrice: order.deliveryPrice,
                    totalPrice: order.totalPrice,
                    totalItems: order.totalItems,
                    items: order.items.map {
                        OrderItemDTO(
                            id: $0.id,
                            name: $0.name,
                            image: $0.image,
                            weight: $0.weight,
                            price: $0.price,
                            quantity: $0.quantity
                        )
                    }
                )
            }

        case .unauthorized(let response):
            let error = try response.body.json
            throw APIError.unauthorized(message: error.error)

        case .default(statusCode: let statusCode, let response):
            let error = try response.body.json
            throw APIError.server(
                statusCode: statusCode,
                message: error.error
            )
        }
    }
}
