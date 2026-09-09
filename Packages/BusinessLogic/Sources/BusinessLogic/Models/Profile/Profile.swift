//
//  Profile.swift
//  BusinessLogic
//
//  Created by Valeriy Solovey on 06.09.2026.
//

import Foundation

public struct Profile: Sendable, Equatable {
    public let name: String
    public let phone: String
    public let birthday: String
    public let imageURL: URL?

    public init(
        name: String,
        phone: String,
        birthday: String,
        imageURL: URL?
    ) {
        self.name = name
        self.phone = phone
        self.birthday = birthday
        self.imageURL = imageURL
    }
}
