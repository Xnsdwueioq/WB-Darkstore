import Observation
import SwiftUI

public enum MainTab: Hashable, Sendable {
    case catalog
    case favorites
    case cart
    case categories
}

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
    func selectTab(_ tab: MainTab)
}

@Observable
public final class Router: RouterProtocol {
    public var path = NavigationPath()
    public var isAuthenticated = false
    public var selectedTab: MainTab = .catalog

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

    public func selectTab(_ tab: MainTab) {
        popToRoot()
        selectedTab = tab
    }

    public func login() {
        withAnimation(.easeInOut(duration: 0.35)) {
            isAuthenticated = true
            path = NavigationPath()
        }
    }
}
