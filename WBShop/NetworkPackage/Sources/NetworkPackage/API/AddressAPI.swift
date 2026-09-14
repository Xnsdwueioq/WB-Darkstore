import Foundation
import OpenAPIRuntime

public protocol AddressAPIProtocol: Sendable {
    func fetchAddresses() async throws -> [IdentifiedAddressDTO]
    func addAddress(_ address: AddressDTO) async throws
    func updateAddress(id: String, address: AddressDTO) async throws
    func deleteAddress(id: String) async throws
}

final class AddressAPI: AddressAPIProtocol {
    private let client: any APIProtocol

    init(client: any APIProtocol) {
        self.client = client
    }

    func fetchAddresses() async throws -> [IdentifiedAddressDTO] {
        do {
            let response = try await client.get_sol_addresses(.init())

            switch response {
            case .ok(let okResponse):
                let fetchedAddresses = try okResponse.body.json
                return fetchedAddresses.compactMap { item in
                    guard let id = item.value2.id else { return nil }
                    let addressDTO = AddressDTO(
                        addressLine: item.value1.addressLine,
                        coordinates: item.value1.coordinates,
                        floor: item.value1.floor,
                        entrance: item.value1.entrance,
                        intercomCode: item.value1.intercomCode,
                        comment: item.value1.comment
                    )
                    return IdentifiedAddressDTO(id: id, address: addressDTO)
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

    func addAddress(_ address: AddressDTO) async throws {
        do {
            let schemaAddress = Components.Schemas.Address(
                coordinates: address.coordinates,
                addressLine: address.addressLine,
                floor: address.floor,
                entrance: address.entrance,
                intercomCode: address.intercomCode,
                comment: address.comment
            )
            let response = try await client.post_sol_addresses(body: .json(schemaAddress))

            switch response {
            case .ok:
                return

            case .badRequest(let badRequest):
                let message = try? badRequest.body.json.error
                throw NetworkError.http(statusCode: 400, message: message ?? "Некорректные данные адреса")

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

    func updateAddress(id: String, address: AddressDTO) async throws {
        do {
            let schemaAddress = Components.Schemas.Address(
                coordinates: address.coordinates,
                addressLine: address.addressLine,
                floor: address.floor,
                entrance: address.entrance,
                intercomCode: address.intercomCode,
                comment: address.comment
            )
            let response = try await client.put_sol_addresses_sol__lcub_id_rcub_(
                path: .init(id: id),
                body: .json(schemaAddress)
            )

            switch response {
            case .ok:
                return

            case .badRequest(let badRequest):
                let message = try? badRequest.body.json.error
                throw NetworkError.http(statusCode: 400, message: message ?? "Некорректные данные адреса")

            case .notFound(let notFound):
                let message = try? notFound.body.json.error
                throw NetworkError.http(statusCode: 404, message: message ?? "Адрес не найден")

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

    func deleteAddress(id: String) async throws {
        do {
            let response = try await client.delete_sol_addresses_sol__lcub_id_rcub_(path: .init(id: id))

            switch response {
            case .ok:
                return

            case .notFound(let notFound):
                let message = try? notFound.body.json.error
                throw NetworkError.http(statusCode: 404, message: message ?? "Адрес не найден")

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
