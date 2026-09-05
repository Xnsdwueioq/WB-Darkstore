//
//  NewReview.swift
//  BusinessLogic
//
//  Created by Valeriy Solovey on 04.09.2026.
//

import Foundation

public struct NewReview: Sendable, Equatable {
    public let rating: Int
    public let content: String
    public let images: [URL]

    public init(
        rating: Int,
        content: String,
        images: [URL]
    ) {
        self.rating = rating
        self.content = content
        self.images = images
    }
}
