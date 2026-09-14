import Foundation
import NetworkPackage

enum CatalogMapper {
    static func mapCategory(_ dto: CategoryDTO) -> Category {
        Category(id: dto.id, name: dto.name, image: dto.image)
    }

    static func mapCategories(_ dtos: [CategoryDTO]) -> [Category] {
        dtos.map(mapCategory)
    }

    static func mapReview(_ dto: ReviewDTO) -> Review {
        Review(
            rating: dto.rating,
            author: dto.author,
            createdAt: dto.createdAt,
            content: dto.content,
            images: dto.images
        )
    }

    static func mapReviews(_ dtos: [ReviewDTO]?) -> [Review]? {
        dtos?.map(mapReview)
    }

    static func mapProductPreview(_ dto: ProductPreviewDTO) -> ProductPreview {
        ProductPreview(
            id: dto.id,
            name: dto.name,
            image: dto.image,
            weight: dto.weight,
            price: dto.price,
            rating: dto.rating,
            reviewCount: dto.reviewCount,
            isFavorite: dto.isFavorite,
            discount: dto.discount
        )
    }

    static func mapProductPreviews(_ dtos: [ProductPreviewDTO]) -> [ProductPreview] {
        dtos.map(mapProductPreview)
    }

    static func mapProduct(_ dto: ProductDTO) -> Product {
        Product(
            id: dto.id,
            name: dto.name,
            image: dto.image,
            weight: dto.weight,
            price: dto.price,
            rating: dto.rating,
            description: dto.description,
            isFavorite: dto.isFavorite,
            discount: dto.discount,
            reviews: mapReviews(dto.reviews)
        )
    }
}
