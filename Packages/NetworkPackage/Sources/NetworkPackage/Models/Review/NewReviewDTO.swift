//
//  NewReviewDTO.swift
//  NetworkPackage
//
//  Created by Valeriy Solovey on 04.09.2026.
//

public struct NewReviewDTO: Sendable, Equatable {
    public let rating: Int
    public let content: String
    public let images: [String]

    public init(
        rating: Int,
        content: String,
        images: [String]
    ) {
        self.rating = rating
        self.content = content
        self.images = images
    }
}
