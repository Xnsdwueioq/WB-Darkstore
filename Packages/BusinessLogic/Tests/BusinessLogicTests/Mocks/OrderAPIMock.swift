import NetworkPackage

actor OrderAPIMock: OrderAPIProtocol {
    enum MockError: Error, Equatable {
        case requestFailed
    }

    private let fetchResponse: Result<[OrderDTO], MockError>
    private let creationError: MockError?

    private(set) var createdOrders: [(paymentMethod: String, addressID: String)] = []

    init(
        fetchResponse: Result<[OrderDTO], MockError> = .success([]),
        creationError: MockError? = nil
    ) {
        self.fetchResponse = fetchResponse
        self.creationError = creationError
    }

    func createOrder(paymentMethod: String, addressID: String) async throws {
        createdOrders.append((paymentMethod, addressID))
        if let creationError { throw creationError }
    }

    func fetchOrders() async throws -> [OrderDTO] {
        try fetchResponse.get()
    }
}
