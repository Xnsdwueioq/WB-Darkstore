//
//  AddressAPIProtocol.swift
//  NetworkPackage
//
//  Created by Valeriy Solovey on 05.09.2026.
//

public protocol AddressAPIProtocol: Sendable {
    func fetchAddresses() async throws -> [SavedAddressDTO]
    func addAddress(_ address: AddressDTO) async throws
    func updateAddress(addressID: String, address: AddressDTO) async throws
    func deleteAddress(addressID: String) async throws
}
