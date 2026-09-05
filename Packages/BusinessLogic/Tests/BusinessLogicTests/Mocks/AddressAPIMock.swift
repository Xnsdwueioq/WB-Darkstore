//
//  AddressAPIMock.swift
//  BusinessLogic
//
//  Created by Valeriy Solovey on 05.09.2026.
//

import NetworkPackage

actor AddressAPIMock: AddressAPIProtocol {
    enum MockError: Error, Equatable {
        case requestFailed
    }

    private let fetchResponse: Result<[SavedAddressDTO], MockError>
    private let mutationError: MockError?

    private(set) var addedAddresses: [AddressDTO] = []
    private(set) var updatedAddresses: [(addressID: String, address: AddressDTO)] = []
    private(set) var deletedAddressIDs: [String] = []

    init(
        fetchResponse: Result<[SavedAddressDTO], MockError> = .success([]),
        mutationError: MockError? = nil
    ) {
        self.fetchResponse = fetchResponse
        self.mutationError = mutationError
    }

    func fetchAddresses() async throws -> [SavedAddressDTO] {
        try fetchResponse.get()
    }

    func addAddress(_ address: AddressDTO) async throws {
        addedAddresses.append(address)
        if let mutationError { throw mutationError }
    }

    func updateAddress(addressID: String, address: AddressDTO) async throws {
        updatedAddresses.append((addressID, address))
        if let mutationError { throw mutationError }
    }

    func deleteAddress(addressID: String) async throws {
        deletedAddressIDs.append(addressID)
        if let mutationError { throw mutationError }
    }
}
