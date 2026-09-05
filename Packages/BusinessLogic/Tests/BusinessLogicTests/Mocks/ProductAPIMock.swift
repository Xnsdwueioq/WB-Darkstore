import NetworkPackage

actor ProductAPIMock: ProductAPIProtocol {
    enum MockError: Error {
        case requestFailed
    }

    enum FetchResponse: Sendable {
        case success(ProductDetailsDTO)
        case failure(MockError)
    }

    private let fetchResponse: FetchResponse

    private(set) var addedFavoriteProductIDs: [String] = []
    private(set) var removedFavoriteProductIDs: [String] = []
    private(set) var submittedReviews: [(productID: String, review: NewReviewDTO)] = []

    init(fetchResponse: FetchResponse) {
        self.fetchResponse = fetchResponse
    }

    func fetchProduct(id: String) async throws -> ProductDetailsDTO {
        switch fetchResponse {
        case .success(let product):
            product
        case .failure(let error):
            throw error
        }
    }

    func addToFavorites(productID: String) async throws {
        addedFavoriteProductIDs.append(productID)
    }

    func removeFromFavorites(productID: String) async throws {
        removedFavoriteProductIDs.append(productID)
    }

    func submitReview(productID: String, review: NewReviewDTO) async throws {
        submittedReviews.append((productID, review))
    }
}
