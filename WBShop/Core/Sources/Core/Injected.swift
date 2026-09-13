public protocol Injectable {
    static var injected: Self { get }
}

public extension Injectable {
    static var injected: Self { ServiceLocator.shared.resolve() }
}

@propertyWrapper
public final class Injected<T> {
    private var dependency: T?

    public init() {}

    public var wrappedValue: T {
        get {
            if dependency == nil {
                let resolved: T = ServiceLocator.shared.resolve()
                dependency = resolved
            }
            guard let dependency else {
                fatalError("Injected<\(T.self)> resolved to nil")
            }
            return dependency
        }
        set { dependency = newValue }
    }
}
