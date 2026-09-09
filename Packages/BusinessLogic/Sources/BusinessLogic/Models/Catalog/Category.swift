//
//  Category.swift
//  BusinessLogic
//
//  Created by Valeriy Solovey on 04.09.2026.
//

import Foundation

public struct Category {
    public let id: String
    public let name: String
    public let imageURL: URL?

    public init(
        id: String,
        name: String,
        imageURL: URL?
    ) {
        self.id = id
        self.name = name
        self.imageURL = imageURL
    }
}
