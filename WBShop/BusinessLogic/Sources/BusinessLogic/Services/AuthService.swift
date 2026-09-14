import Foundation

public protocol AuthServicing: AnyObject, Sendable {
    func login(username: String, password: String) -> Bool
}

public final class AuthService: AuthServicing {
    public init() {}

    public func login(username: String, password: String) -> Bool {
        !username.isEmpty && !password.isEmpty
    }
}
