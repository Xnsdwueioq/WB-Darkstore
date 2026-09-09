//
//  AddressAPI.swift
//  NetworkPackage
//
//  Created by Valeriy Solovey on 05.09.2026.
//

public struct AddressAPI: AddressAPIProtocol {
    private let apiClient: APIClient

    public init(apiClient: APIClient) {
        self.apiClient = apiClient
    }

    public func fetchAddresses() async throws -> [SavedAddressDTO] {
        let output = try await apiClient.client.getAddresses()

        switch output {
        case .ok(let response):
            let addresses = try response.body.json

            return try addresses.map {
                let idContainer = $0.value2
                guard let id = idContainer.id else {
                    throw APIError.invalidResponse(message: "Address ID is missing")
                }
                let address = $0.value1

                return SavedAddressDTO(
                    id: id,
                    address: AddressDTO(
                        coordinates: address.coordinates,
                        addressLine: address.addressLine,
                        floor: address.floor,
                        entrance: address.entrance,
                        intercomCode: address.intercomCode,
                        comment: address.comment
                    )
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

    public func addAddress(_ address: AddressDTO) async throws {
        let output = try await apiClient.client.postAddresses(
            .init(
                body: .json(.init(
                    coordinates: address.coordinates,
                    addressLine: address.addressLine,
                    floor: address.floor,
                    entrance: address.entrance,
                    intercomCode: address.intercomCode,
                    comment: address.comment
                ))
            )
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

    public func updateAddress(addressID: String, address: AddressDTO) async throws {
        let output = try await apiClient.client.putAddressesId(
            .init(
                path: .init(id: addressID),
                body: .json(.init(
                    coordinates: address.coordinates,
                    addressLine: address.addressLine,
                    floor: address.floor,
                    entrance: address.entrance,
                    intercomCode: address.intercomCode,
                    comment: address.comment
                ))
            )
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

        case .notFound(let response):
            let error = try response.body.json
            throw APIError.notFound(message: error.error)

        case .default(statusCode: let statusCode, let response):
            let error = try response.body.json
            throw APIError.server(
                statusCode: statusCode,
                message: error.error
            )
        }
    }

    public func deleteAddress(addressID: String) async throws {
        let output = try await apiClient.client.deleteAddressesId(
            .init(
                path: .init(id: addressID)
            )
        )

        switch output {
        case .ok:
            return

        case .unauthorized(let response):
            let error = try response.body.json
            throw APIError.unauthorized(message: error.error)

        case .notFound(let response):
            let error = try response.body.json
            throw APIError.notFound(message: error.error)

        case .default(statusCode: let statusCode, let response):
            let error = try response.body.json
            throw APIError.server(
                statusCode: statusCode,
                message: error.error
            )
        }
    }
}
