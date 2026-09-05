//
//  SavedAddress.swift
//  BusinessLogic
//
//  Created by Valeriy Solovey on 05.09.2026.
//

public struct SavedAddress: Sendable, Equatable, Identifiable {
    public let id: String
    public let address: Address

    public init(id: String, address: Address) {
        self.id = id
        self.address = address
    }
}
