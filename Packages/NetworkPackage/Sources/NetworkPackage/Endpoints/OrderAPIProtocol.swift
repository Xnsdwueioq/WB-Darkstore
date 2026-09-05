public protocol OrderAPIProtocol: Sendable {
    func createOrder(paymentMethod: String, addressID: String) async throws
    func fetchOrders() async throws -> [OrderDTO]
}
