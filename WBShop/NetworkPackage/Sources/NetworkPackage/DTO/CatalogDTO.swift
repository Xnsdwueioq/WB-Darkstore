import Foundation

public struct CategoryDTO: Sendable, Hashable, Identifiable {
    public let id: String
    public let name: String
    public let image: String

    public init(id: String, name: String, image: String) {
        self.id = id
        self.name = name
        self.image = image
    }
}

public struct ReviewDTO: Sendable, Hashable {
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

public struct ProductPreviewDTO: Sendable, Hashable, Identifiable {
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
}

public struct ProductDTO: Sendable, Hashable, Identifiable {
    public let id: String
    public let name: String
    public let image: String
    public let weight: Double
    public let price: Int
    public let rating: Double
    public let description: String
    public let isFavorite: Bool
    public let discount: Double?
    public let reviews: [ReviewDTO]?

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
        reviews: [ReviewDTO]? = nil
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

public struct ProductPageDTO: Sendable, Hashable {
    public let currentPage: Int
    public let totalPages: Int
    public let data: [ProductPreviewDTO]

    public init(currentPage: Int, totalPages: Int, data: [ProductPreviewDTO]) {
        self.currentPage = currentPage
        self.totalPages = totalPages
        self.data = data
    }
}
