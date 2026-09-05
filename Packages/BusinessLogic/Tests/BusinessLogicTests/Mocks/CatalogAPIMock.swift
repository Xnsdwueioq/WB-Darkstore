import NetworkPackage

struct CatalogAPIMock: CatalogAPIProtocol {
    enum MockError: Error {
        case requestFailed
    }

    enum Response: Sendable {
        case success([CategoryDTO])
        case failure(MockError)
    }

    let response: Response

    func fetchCategories() async throws -> [CategoryDTO] {
        switch response {
        case .success(let categories):
            categories
        case .failure(let error):
            throw error
        }
    }
}
