//
//  Address+Mapping.swift
//  BusinessLogic
//
//  Created by Valeriy Solovey on 05.09.2026.
//

import NetworkPackage

extension Address {
    init(dto: AddressDTO) throws {
        guard dto.coordinates.count == 2 else {
            throw AddressMappingError.invalidCoordinates
        }

        self.init(
            coordinates: .init(longitude: dto.coordinates[0], latitude: dto.coordinates[1]),
            addressLine: dto.addressLine,
            floor: dto.floor,
            entrance: dto.entrance,
            intercomCode: dto.intercomCode,
            comment: dto.comment
        )
    }

    var dto: AddressDTO {
        AddressDTO(
            coordinates: [coordinates.longitude, coordinates.latitude],
            addressLine: addressLine,
            floor: floor,
            entrance: entrance,
            intercomCode: intercomCode,
            comment: comment
        )
    }
}
