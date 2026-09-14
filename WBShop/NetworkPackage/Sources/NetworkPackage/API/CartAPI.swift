import Foundation
import OpenAPIRuntime

public protocol CartAPIProtocol: Sendable {
    func fetchCart() async throws -> CartDTO
    func addItem(id: String) async throws -> Int
    func removeItem(id: String) async throws -> Int?
}

final class CartAPI: CartAPIProtocol {
    private let client: any APIProtocol

    init(client: any APIProtocol) {
        self.client = client
    }

    func fetchCart() async throws -> CartDTO {
        do {
            let response = try await client.get_sol_cart()

            switch response {
            case .ok(let okResponse):
                let body = try okResponse.body.json
                let items = body.items.map { item in
                    CartItemDTO(
                        id: item.value1.id,
                        image: item.value1.image,
                        name: item.value1.name,
                        weight: item.value1.weight,
                        price: item.value1.price,
                        quantity: item.value1.quantity,
                        isAvailable: item.value2.available
                    )
                }
                return CartDTO(items: items)

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

    func addItem(id: String) async throws -> Int {
        do {
            let response = try await client.post_sol_cart_sol_items(query: .init(id: id))

            switch response {
            case .ok(let okResponse):
                let body = try okResponse.body.json
                return body.total

            case .unauthorized(let unauthorized):
                let message = try? unauthorized.body.json.error
                throw NetworkError.http(statusCode: 401, message: message)

            case .notFound(let notFound):
                let message = try? notFound.body.json.error
                throw NetworkError.http(statusCode: 404, message: message)

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

    func removeItem(id: String) async throws -> Int? {
        do {
            let response = try await client.delete_sol_cart_sol_items_sol__lcub_id_rcub_(
                path: .init(id: id)
            )

            switch response {
            case .ok(let okResponse):
                let body = try okResponse.body.json
                return body.total

            case .unauthorized(let unauthorized):
                let message = try? unauthorized.body.json.error
                throw NetworkError.http(statusCode: 401, message: message)

            case .notFound(let notFound):
                let message = try? notFound.body.json.error
                throw NetworkError.http(statusCode: 404, message: message)

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
