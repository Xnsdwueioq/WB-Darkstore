import Foundation
import OpenAPIRuntime
import OpenAPIURLSession

public struct NetworkServices: Sendable {
    public let catalog: any CatalogAPIProtocol
    public let cart: any CartAPIProtocol
    public let orders: any OrderAPIProtocol
    public let profile: any ProfileAPIProtocol
    public let addresses: any AddressAPIProtocol

    public init(
        tokenProvider: @escaping @Sendable () -> String?
    ) throws {
        let serverURL = try Servers.Server1.url()
        let client = Client(
            serverURL: serverURL,
            configuration: .init(dateTranscoder: FlexibleISO8601DateTranscoder()),
            transport: URLSessionTransport(),
            middlewares: [AuthMiddleware(tokenProvider: tokenProvider)]
        )
        self.catalog = CatalogAPI(client: client)
        self.cart = CartAPI(client: client)
        self.orders = OrderAPI(client: client)
        self.profile = ProfileAPI(client: client)
        self.addresses = AddressAPI(client: client)
    }

    public init(
        catalog: any CatalogAPIProtocol,
        cart: any CartAPIProtocol,
        orders: any OrderAPIProtocol,
        profile: any ProfileAPIProtocol,
        addresses: any AddressAPIProtocol
    ) {
        self.catalog = catalog
        self.cart = cart
        self.orders = orders
        self.profile = profile
        self.addresses = addresses
    }
}
