//
//  NewProfile.swift
//  BusinessLogic
//
//  Created by Valeriy Solovey on 06.09.2026.
//

import Foundation

public struct NewProfile: Sendable, Equatable {
    public let name: String
    public let birthday: String
    public let imageURL: URL

    public init(
        name: String,
        birthday: String,
        imageURL: URL
    ) {
        self.name = name
        self.birthday = birthday
        self.imageURL = imageURL
    }
}
