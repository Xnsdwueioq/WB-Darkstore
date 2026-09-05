import NetworkPackage

actor CartAPIMock: CartAPIProtocol {
    enum MockError: Error, Equatable {
        case requestFailed
    }

    private let fetchResponse: Result<CartDTO, MockError>
    private let mutationError: MockError?
    private let addedTotal: Int
    private let removedTotal: Int

    private(set) var addedProductIDs: [String] = []
    private(set) var removedProductIDs: [String] = []

    init(
        fetchResponse: Result<CartDTO, MockError> = .failure(.requestFailed),
        mutationError: MockError? = nil,
        addedTotal: Int = 3,
        removedTotal: Int = 2
    ) {
        self.fetchResponse = fetchResponse
        self.mutationError = mutationError
        self.addedTotal = addedTotal
        self.removedTotal = removedTotal
    }

    func fetchCart() async throws -> CartDTO {
        try fetchResponse.get()
    }

    func addItem(productID: String) async throws -> Int {
        addedProductIDs.append(productID)
        if let mutationError { throw mutationError }
        return addedTotal
    }

    func removeItem(productID: String) async throws -> Int {
        removedProductIDs.append(productID)
        if let mutationError { throw mutationError }
        return removedTotal
    }
}
