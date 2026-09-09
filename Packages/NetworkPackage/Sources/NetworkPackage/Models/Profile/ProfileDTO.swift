//
//  ProfileDTO.swift
//  NetworkPackage
//
//  Created by Valeriy Solovey on 06.09.2026.
//

public struct ProfileDTO: Sendable, Equatable {
    public let name: String
    public let phone: String
    public let birthday: String
    public let image: String?

    public init(
        name: String,
        phone: String,
        birthday: String,
        image: String?
    ) {
        self.name = name
        self.phone = phone
        self.birthday = birthday
        self.image = image
    }
}
