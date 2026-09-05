//
//  SavedAddressDTO.swift
//  NetworkPackage
//
//  Created by Valeriy Solovey on 05.09.2026.
//

public struct SavedAddressDTO: Sendable, Equatable, Identifiable {
    public let id: String
    public let address: AddressDTO

    public init(id: String, address: AddressDTO) {
        self.id = id
        self.address = address
    }
}
