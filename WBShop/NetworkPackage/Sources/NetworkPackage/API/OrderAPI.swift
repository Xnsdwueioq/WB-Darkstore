import Foundation
import OpenAPIRuntime

public protocol OrderAPIProtocol: Sendable {
    func createOrder(paymentMethod: String, addressID: String) async throws
    func fetchOrders() async throws -> [OrderDTO]
}

final class OrderAPI: OrderAPIProtocol {
    private let client: any APIProtocol

    init(client: any APIProtocol) {
        self.client = client
    }

    func createOrder(paymentMethod: String, addressID: String) async throws {
        do {
            let response = try await client.post_sol_orders(
                body: .json(
                    .init(
                        paymentMethod: paymentMethod,
                        addressID: addressID
                    )
                )
            )

            switch response {
            case .ok:
                return

            case .badRequest(let badRequest):
                let message = try? badRequest.body.json.error
                throw NetworkError.http(statusCode: 400, message: message)

            case .unauthorized(let unauthorized):
                let message = try? unauthorized.body.json.error
                throw NetworkError.http(statusCode: 401, message: message)

            case .default(let statusCode, let defaultResp):
                let message = try? defaultResp.body.json.error
                throw NetworkError.http(statusCode: statusCode, message: message)
            }
        } catch let error as NetworkError {
            throw error
        } catch {
            throw NetworkError.transport(error.localizedDescription)
        }
    }

    func fetchOrders() async throws -> [OrderDTO] {
        do {
            let response = try await client.get_sol_orders(.init())

            switch response {
            case .ok(let okResponse):
                let body = try okResponse.body.json
                return body.map { order in
                    let address = AddressDTO(
                        addressLine: order.address.addressLine,
                        coordinates: order.address.coordinates,
                        floor: order.address.floor,
                        entrance: order.address.entrance,
                        intercomCode: order.address.intercomCode,
                        comment: order.address.comment
                    )

                    let items = order.items.map { item in
                        OrderItemDTO(
                            id: item.id,
                            image: item.image,
                            name: item.name,
                            weight: item.weight,
                            price: item.price,
                            quantity: item.quantity
                        )
                    }

                    return OrderDTO(
                        id: order.id,
                        status: order.status.rawValue,
                        deliveryDate: order.deliveryDate,
                        address: address,
                        orderPrice: order.orderPrice,
                        deliveryPrice: order.deliveryPrice,
                        totalPrice: order.totalPrice,
                        totalItems: order.totalItems,
                        items: items
                    )
                }

            case .unauthorized(let unauthorized):
                let message = try? unauthorized.body.json.error
                throw NetworkError.http(statusCode: 401, message: message)

            case .default(let statusCode, let defaultResp):
                let message = try? defaultResp.body.json.error
                throw NetworkError.http(statusCode: statusCode, message: message)
            }
        } catch let error as NetworkError {
            throw error
        } catch {
            throw NetworkError.transport(error.localizedDescription)
        }
    }
}
