//
//  ReviewDTO.swift
//  NetworkPackage
//
//  Created by Valeriy Solovey on 04.09.2026.
//

import Foundation

public struct ReviewDTO: Sendable, Equatable {
    public let rating: Int
    public let author: String
    public let createdAt: Date
    public let content: String
    public let images: [String]

    public init(
        rating: Int,
        author: String,
        createdAt: Date,
        content: String,
        images: [String]
    ) {
        self.rating = rating
        self.author = author
        self.createdAt = createdAt
        self.content = content
        self.images = images
    }
}
