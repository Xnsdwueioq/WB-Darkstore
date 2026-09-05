public protocol OrderServiceProtocol: Sendable {
    func createOrder(paymentMethod: String, addressID: String) async throws
    func getOrders() async throws -> [Order]
}
