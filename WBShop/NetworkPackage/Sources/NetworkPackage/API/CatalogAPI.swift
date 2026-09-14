import Foundation
import OpenAPIRuntime

public protocol CatalogAPIProtocol: Sendable {
    func fetchProducts(categoryID: String?, page: Int?, pageSize: Int?) async throws -> ProductPageDTO
    func fetchProduct(id: String) async throws -> ProductDTO
    func fetchCategories() async throws -> [CategoryDTO]
    func setFavorite(id: String, isFavorite: Bool) async throws
    func addReview(productID: String, rating: Int, comment: String, images: [String]) async throws
}

public extension CatalogAPIProtocol {
    func fetchProducts() async throws -> ProductPageDTO {
        try await fetchProducts(categoryID: nil, page: nil, pageSize: nil)
    }

    func fetchProducts(categoryID: String?) async throws -> ProductPageDTO {
        try await fetchProducts(categoryID: categoryID, page: nil, pageSize: nil)
    }

    func addReview(productID: String, rating: Int, comment: String) async throws {
        try await addReview(productID: productID, rating: rating, comment: comment, images: [])
    }
}

final class CatalogAPI: CatalogAPIProtocol {
    private let client: any APIProtocol

    init(client: any APIProtocol) {
        self.client = client
    }

    func fetchProducts(
      categoryID: String? = nil,
      page: Int? = nil,
      pageSize: Int? = nil
    ) async throws -> ProductPageDTO {
        do {
            let response = try await client.get_sol_products(
                query: .init(category: categoryID, page: page, pageSize: pageSize)
            )

            switch response {
            case .ok(let okResponse):
                let body = try okResponse.body.json
                let previews = body.data.map { item in
                    ProductPreviewDTO(
                        id: item.id,
                        name: item.name,
                        image: item.image,
                        weight: item.weight,
                        price: item.price,
                        rating: Double(item.rating),
                        reviewCount: item.reviewCount,
                        isFavorite: item.isFavorite,
                        discount: item.discount
                    )
                }
                return ProductPageDTO(
                    currentPage: body.currentPage,
                    totalPages: body.totalPages,
                    data: previews
                )

            case .badRequest(let badRequest):
                let message = try? badRequest.body.json.error
                throw NetworkError.http(statusCode: 400, message: message)

            case .unauthorized(let unauthorized):
                let message = try? unauthorized.body.json.error
                throw NetworkError.http(statusCode: 401, message: message)

            case .default(let statusCode, let defaultResp):
                let message = try? defaultResp.body.json.error
                throw NetworkError.http(statusCode: statusCode, message: message)
            }
        } catch let error as NetworkError {
            throw error
        } catch {
            throw NetworkError.transport(error.localizedDescription)
        }
    }

    func fetchProduct(id: String) async throws -> ProductDTO {
        do {
            let response = try await client.get_sol_products_sol__lcub_id_rcub_(path: .init(id: id))

            switch response {
            case .ok(let okResponse):
                let body = try okResponse.body.json
                let reviews = body.reviews?.map { review in
                    ReviewDTO(
                        rating: review.rating,
                        author: review.author,
                        createdAt: review.createdAt,
                        content: review.content,
                        images: review.images
                    )
                }

                return ProductDTO(
                    id: body.id,
                    name: body.name,
                    image: body.image,
                    weight: body.weight,
                    price: body.price,
                    rating: Double(body.rating),
                    description: body.description,
                    isFavorite: body.isFavorite,
                    discount: body.discount,
                    reviews: reviews
                )

            case .notFound(let notFound):
                let message = try? notFound.body.json.error
                throw NetworkError.http(statusCode: 404, message: message ?? "Товар не найден")

            case .unauthorized(let unauthorized):
                let message = try? unauthorized.body.json.error
                throw NetworkError.http(statusCode: 401, message: message)

            case .default(let statusCode, let defaultResp):
                let message = try? defaultResp.body.json.error
                throw NetworkError.http(statusCode: statusCode, message: message)
            }
        } catch let error as NetworkError {
            throw error
        } catch {
            throw NetworkError.transport(error.localizedDescription)
        }
    }

    func fetchCategories() async throws -> [CategoryDTO] {
        do {
            let response = try await client.get_sol_categories()

            switch response {
            case .ok(let okResponse):
                let body = try okResponse.body.json
                return body.map { CategoryDTO(id: $0.id, name: $0.name, image: $0.image) }

            case .unauthorized(let unauthorized):
                let message = try? unauthorized.body.json.error
                throw NetworkError.http(statusCode: 401, message: message)

            case .default(let statusCode, let defaultResp):
                let message = try? defaultResp.body.json.error
                throw NetworkError.http(statusCode: statusCode, message: message)
            }
        } catch let error as NetworkError {
            throw error
        } catch {
            throw NetworkError.transport(error.localizedDescription)
        }
    }

    func setFavorite(id: String, isFavorite: Bool) async throws {
        do {
            if isFavorite {
                let response = try await client.post_sol_products_sol__lcub_id_rcub__sol_favourite(
                    path: .init(id: id)
                )

                switch response {
                case .ok:
                    return
                case .unauthorized(let unauthorized):
                    let message = try? unauthorized.body.json.error
                    throw NetworkError.http(statusCode: 401, message: message)
                case .notFound(let notFound):
                    let message = try? notFound.body.json.error
                    throw NetworkError.http(statusCode: 404, message: message)
                case .default(let statusCode, let defaultResp):
                    let message = try? defaultResp.body.json.error
                    throw NetworkError.http(statusCode: statusCode, message: message)
                }
            } else {
                let response = try await client.delete_sol_products_sol__lcub_id_rcub__sol_favourite(
                    path: .init(id: id)
                )

                switch response {
                case .ok:
                    return
                case .unauthorized(let unauthorized):
                    let message = try? unauthorized.body.json.error
                    throw NetworkError.http(statusCode: 401, message: message)
                case .notFound(let notFound):
                    let message = try? notFound.body.json.error
                    throw NetworkError.http(statusCode: 404, message: message)
                case .default(let statusCode, let defaultResp):
                    let message = try? defaultResp.body.json.error
                    throw NetworkError.http(statusCode: statusCode, message: message)
                }
            }
        } catch let error as NetworkError {
            throw error
        } catch {
            throw NetworkError.transport(error.localizedDescription)
        }
    }

    func addReview(productID: String, rating: Int, comment: String, images: [String] = []) async throws {
        do {
            let response = try await client.post_sol_products_sol__lcub_id_rcub__sol_reviews(
                path: .init(id: productID),
                body: .json(.init(rating: rating, content: comment, images: images))
            )

            switch response {
            case .ok:
                return
            case .badRequest(let badRequest):
                let message = try? badRequest.body.json.error
                throw NetworkError.http(statusCode: 400, message: message)
            case .unauthorized(let unauthorized):
                let message = try? unauthorized.body.json.error
                throw NetworkError.http(statusCode: 401, message: message)
            case .default(let statusCode, let defaultResp):
                let message = try? defaultResp.body.json.error
                throw NetworkError.http(statusCode: statusCode, message: message)
            }
        } catch let error as NetworkError {
            throw error
        } catch {
            throw NetworkError.transport(error.localizedDescription)
        }
    }
}
