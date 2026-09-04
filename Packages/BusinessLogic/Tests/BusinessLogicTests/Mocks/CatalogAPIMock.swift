import NetworkPackage

struct CatalogAPIMock: CatalogAPIProtocol {
    enum MockError: Error {
        case requestFailed
    }

    enum Response: Sendable {
        case success([CategoryDTO])
        case failure(MockError)
    }

    enum ProductsResponse: Sendable {
        case success(ProductListDTO)
        case failure(MockError)
    }

    let response: Response
    let productsResponse: ProductsResponse

    init(
        response: Response = .success([]),
        productsResponse: ProductsResponse = .success(
            ProductListDTO(currentPage: 1, totalPages: 1, products: [])
        )
    ) {
        self.response = response
        self.productsResponse = productsResponse
    }

    func fetchCategories() async throws -> [CategoryDTO] {
        switch response {
        case .success(let categories):
            categories
        case .failure(let error):
            throw error
        }
    }

    func fetchProducts(
        categoryID: String?,
        page: Int?,
        pageSize: Int?
    ) async throws -> ProductListDTO {
        switch productsResponse {
        case .success(let productList):
            productList
        case .failure(let error):
            throw error
        }
    }
}
