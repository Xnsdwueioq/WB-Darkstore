//
//  Review.swift
//  BusinessLogic
//
//  Created by Valeriy Solovey on 04.09.2026.
//

import Foundation

public struct Review: Sendable, Equatable, Identifiable {
    public let rating: Int
    public let author: String
    public let createdAt: Date
    public let content: String
    public let id: UUID
    public let images: [URL]

    public init(
        id: UUID = UUID(),
        rating: Int,
        author: String,
        createdAt: Date,
        content: String,
        images: [URL]
    ) {
        self.id = id
        self.rating = rating
        self.author = author
        self.createdAt = createdAt
        self.content = content
        self.images = images
    }
}
