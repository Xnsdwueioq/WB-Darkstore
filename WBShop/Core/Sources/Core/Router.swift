import SwiftUI

public enum Route: Hashable {
    case content
    case login
    case search
    case category(id: String, name: String)
    case profile
    case profileEdit
}

public protocol RouterProtocol: AnyObject {
    func push(_ route: Route)
    func pop()
    func popToRoot()
}

public final class Router: ObservableObject, RouterProtocol {
    @Published public var path = NavigationPath()
    @Published public var isAuthenticated = false

    public init() {}

    public func push(_ route: Route) {
        path.append(route)
    }

    public func pop() {
        guard !path.isEmpty else { return }
        path.removeLast()
    }

    public func popToRoot() {
        path.removeLast(path.count)
    }

    public func login() {
        withAnimation(.easeInOut(duration: 0.35)) {
            isAuthenticated = true
            path = NavigationPath()
        }
    }
}
