import Foundation

public protocol ServiceLocating {
    func resolve<T>() -> T
}

public final class ServiceLocator: ServiceLocating, @unchecked Sendable {
    public static let shared = ServiceLocator()

    private lazy var services: [ObjectIdentifier: Any] = [:]

    private init() {
        let router = Router()
        register(service: router)   
        register(service: router as RouterProtocol)
    }

    public func register<T>(service: T) {
        let key = ObjectIdentifier(T.self)
        services[key] = service
    }

    public func resolve<T>() -> T {
        let key = ObjectIdentifier(T.self)
        guard let service = services[key] as? T else {
            fatalError("Service not registered: \(T.self)")
        }
        return service
    }
}
