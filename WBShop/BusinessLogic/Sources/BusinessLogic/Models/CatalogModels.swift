import Foundation

public struct Category: Identifiable, Hashable, Sendable {
    public let id: String
    public let name: String
    public let image: String

    public init(id: String, name: String, image: String) {
        self.id = id
        self.name = name
        self.image = image
    }
}

public struct Review: Hashable, Sendable {
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
        images: [String] = []
    ) {
        self.rating = rating
        self.author = author
        self.createdAt = createdAt
        self.content = content
        self.images = images
    }
}

public struct ProductPreview: Identifiable, Hashable, Sendable {
    public let id: String
    public let name: String
    public let image: String
    public let weight: Double
    public let price: Int
    public let rating: Double
    public let reviewCount: Int
    public let isFavorite: Bool
    public let discount: Double?

    public init(
        id: String,
        name: String,
        image: String,
        weight: Double,
        price: Int,
        rating: Double,
        reviewCount: Int,
        isFavorite: Bool,
        discount: Double? = nil
    ) {
        self.id = id
        self.name = name
        self.image = image
        self.weight = weight
        self.price = price
        self.rating = rating
        self.reviewCount = reviewCount
        self.isFavorite = isFavorite
        self.discount = discount
    }

    public init(
        id: String,
        image: String,
        name: String,
        weight: Double,
        price: Int,
        rating: Double,
        reviewCount: Int,
        isFavorite: Bool,
        discount: Double? = nil
    ) {
        self.init(
            id: id,
            name: name,
            image: image,
            weight: weight,
            price: price,
            rating: rating,
            reviewCount: reviewCount,
            isFavorite: isFavorite,
            discount: discount
        )
    }
}

public struct Product: Identifiable, Hashable, Sendable {
    public let id: String
    public let name: String
    public let image: String
    public let weight: Double
    public let price: Int
    public let rating: Double
    public let description: String
    public let isFavorite: Bool
    public let discount: Double?
    public let reviews: [Review]?

    public init(
        id: String,
        name: String,
        image: String,
        weight: Double,
        price: Int,
        rating: Double,
        description: String,
        isFavorite: Bool,
        discount: Double? = nil,
        reviews: [Review]? = nil
    ) {
        self.id = id
        self.name = name
        self.image = image
        self.weight = weight
        self.price = price
        self.rating = rating
        self.description = description
        self.isFavorite = isFavorite
        self.discount = discount
        self.reviews = reviews
    }
}
