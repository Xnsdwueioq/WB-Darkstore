//
//  AddressServiceTests.swift
//  BusinessLogic
//
//  Created by Valeriy Solovey on 05.09.2026.
//

import NetworkPackage
import Testing
@testable import BusinessLogic

@Suite("AddressService")
struct AddressServiceTests {
    @Test("Maps saved IDs, coordinate order and all address fields", arguments: [false, true])
    func mapsAddresses(withDetails: Bool) async throws {
        let dto = makeDTO(withDetails: withDetails)
        let api = AddressAPIMock(fetchResponse: .success([
            SavedAddressDTO(id: "address-2", address: dto),
            SavedAddressDTO(id: "address-1", address: dto)
        ]))
        let service = AddressService(addressAPI: api)

        let addresses = try await service.getAddresses()

        #expect(addresses == [
            SavedAddress(id: "address-2", address: makeAddress(withDetails: withDetails)),
            SavedAddress(id: "address-1", address: makeAddress(withDetails: withDetails))
        ])
    }

    @Test("Returns an empty address list")
    func getsEmptyAddresses() async throws {
        let service = AddressService(addressAPI: AddressAPIMock())

        #expect(try await service.getAddresses().isEmpty)
    }

    @Test("Maps writes to longitude then latitude and forwards IDs", arguments: [false, true])
    func mapsMutations(withDetails: Bool) async throws {
        let api = AddressAPIMock()
        let service = AddressService(addressAPI: api)
        let address = makeAddress(withDetails: withDetails)

        try await service.addAddress(address)
        try await service.updateAddress(addressID: "address-1", address: address)
        try await service.deleteAddress(addressID: "address-2")

        #expect(await api.addedAddresses == [makeDTO(withDetails: withDetails)])
        let updates = await api.updatedAddresses
        #expect(updates.count == 1)
        let update = try #require(updates.first)
        #expect(update.addressID == "address-1")
        #expect(update.address == makeDTO(withDetails: withDetails))
        #expect(await api.deletedAddressIDs == ["address-2"])
    }

    @Test("Rejects invalid coordinate counts instead of indexing out of bounds", arguments: [[], [92.87], [92.87, 56.01, 1.0]])
    func rejectsInvalidCoordinates(coordinates: [Double]) async {
        let dto = AddressDTO(
            coordinates: coordinates, addressLine: "Мира, 10",
            floor: nil, entrance: nil, intercomCode: nil, comment: nil
        )
        let api = AddressAPIMock(fetchResponse: .success([SavedAddressDTO(id: "address-1", address: dto)]))
        let service = AddressService(addressAPI: api)

        await #expect(throws: AddressMappingError.invalidCoordinates) {
            try await service.getAddresses()
        }
    }

    enum Operation: CaseIterable, Sendable {
        case fetch, add, update, delete
    }

    @Test("Propagates all API operation errors", arguments: Operation.allCases)
    func propagatesErrors(operation: Operation) async {
        let api = AddressAPIMock(fetchResponse: .failure(.requestFailed), mutationError: .requestFailed)
        let service = AddressService(addressAPI: api)

        await #expect(throws: AddressAPIMock.MockError.requestFailed) {
            switch operation {
            case .fetch: _ = try await service.getAddresses()
            case .add: try await service.addAddress(makeAddress(withDetails: false))
            case .update: try await service.updateAddress(addressID: "address-1", address: makeAddress(withDetails: false))
            case .delete: try await service.deleteAddress(addressID: "address-1")
            }
        }
    }

    private func makeAddress(withDetails: Bool) -> Address {
        Address(
            coordinates: .init(longitude: 92.87, latitude: 56.01), addressLine: "Мира, 10",
            floor: withDetails ? "5" : nil, entrance: withDetails ? "2" : nil,
            intercomCode: withDetails ? "42" : nil, comment: withDetails ? "Позвонить" : nil
        )
    }

    private func makeDTO(withDetails: Bool) -> AddressDTO {
        AddressDTO(
            coordinates: [92.87, 56.01], addressLine: "Мира, 10",
            floor: withDetails ? "5" : nil, entrance: withDetails ? "2" : nil,
            intercomCode: withDetails ? "42" : nil, comment: withDetails ? "Позвонить" : nil
        )
    }
}
