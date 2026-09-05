//
//  AddressCoordinates.swift
//  BusinessLogic
//
//  Created by Valeriy Solovey on 05.09.2026.
//

public struct AddressCoordinates: Sendable, Equatable {
    public let longitude: Double
    public let latitude: Double

    public init(longitude: Double, latitude: Double) {
        self.longitude = longitude
        self.latitude = latitude
    }
}
