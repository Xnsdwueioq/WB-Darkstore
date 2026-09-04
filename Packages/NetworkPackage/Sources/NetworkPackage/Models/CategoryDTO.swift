//
//  CategoryDTO.swift
//  NetworkPackage
//
//  Created by Valeriy Solovey on 04.09.2026.
//

public struct CategoryDTO: Sendable, Equatable {
    public let id: String
    public let name: String
    public let image: String

    public init(id: String, name: String, image: String) {
        self.id = id
        self.name = name
        self.image = image
    }
}
