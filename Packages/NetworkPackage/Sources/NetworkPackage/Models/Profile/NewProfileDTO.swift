//
//  NewProfileDTO.swift
//  NetworkPackage
//
//  Created by Valeriy Solovey on 06.09.2026.
//

public struct NewProfileDTO: Sendable, Equatable {
    public let name: String
    public let birthday: String
    public let image: String

    public init(
        name: String,
        birthday: String,
        image: String
    ) {
        self.name = name
        self.birthday = birthday
        self.image = image
    }
}
