//
//  AddressServiceProtocol.swift
//  BusinessLogic
//
//  Created by Valeriy Solovey on 05.09.2026.
//

public protocol AddressServiceProtocol: Sendable {
    func getAddresses() async throws -> [SavedAddress]
    func addAddress(_ address: Address) async throws
    func updateAddress(addressID: String, address: Address) async throws
    func deleteAddress(addressID: String) async throws
}
