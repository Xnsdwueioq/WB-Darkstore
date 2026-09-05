//
//  AddressService.swift
//  BusinessLogic
//
//  Created by Valeriy Solovey on 05.09.2026.
//

import NetworkPackage

public struct AddressService: AddressServiceProtocol {
    private let addressAPI: any AddressAPIProtocol

    public init(addressAPI: any AddressAPIProtocol) {
        self.addressAPI = addressAPI
    }

    public func getAddresses() async throws -> [SavedAddress] {
        let dtos = try await addressAPI.fetchAddresses()

        return try dtos.map {
            SavedAddress(id: $0.id, address: try Address(dto: $0.address))
        }
    }

    public func addAddress(_ address: Address) async throws {
        try await addressAPI.addAddress(address.dto)
    }

    public func updateAddress(addressID: String, address: Address) async throws {
        try await addressAPI.updateAddress(addressID: addressID, address: address.dto)
    }

    public func deleteAddress(addressID: String) async throws {
        try await addressAPI.deleteAddress(addressID: addressID)
    }
}
