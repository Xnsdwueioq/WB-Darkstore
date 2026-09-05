//
//  AddressDTO.swift
//  NetworkPackage
//
//  Created by Valeriy Solovey on 05.09.2026.
//

public struct AddressDTO: Sendable, Equatable {
    public let coordinates: [Double]
    public let addressLine: String
    public let floor: String?
    public let entrance: String?
    public let intercomCode: String?
    public let comment: String?

    public init(
        coordinates: [Double],
        addressLine: String,
        floor: String?,
        entrance: String?,
        intercomCode: String?,
        comment: String?
    ) {
        self.coordinates = coordinates
        self.addressLine = addressLine
        self.floor = floor
        self.entrance = entrance
        self.intercomCode = intercomCode
        self.comment = comment
    }
}
