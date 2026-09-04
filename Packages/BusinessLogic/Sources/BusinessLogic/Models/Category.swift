//
//  Category.swift
//  BusinessLogic
//
//  Created by Valeriy Solovey on 04.09.2026.
//

import Foundation

public struct Category {
    public var id: String
    public var name: String
    public var imageURL: URL?

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
