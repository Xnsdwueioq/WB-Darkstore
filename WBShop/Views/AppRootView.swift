import SwiftUI
import Core

struct AppRootView: View {
    @StateObject private var router: Router = ServiceLocator.shared.resolve()

    var body: some View {
        NavigationStack(path: $router.path) {
            ZStack {
                if router.isAuthenticated {
                    MainTabView()
                        .transition(
                            .asymmetric(
                                insertion: .opacity
                                    .combined(with: .move(edge: .bottom))
                                    .combined(with: .scale(scale: 0.9)),
                                removal: .opacity
                            )
                        )
                } else {
                    LoginView()
                        .transition(
                            .asymmetric(
                                insertion: .opacity
                                    .combined(with: .move(edge: .bottom))
                                    .combined(with: .scale(scale: 0.9)),
                                removal: .opacity
                            )
                        )
                }
            }
            .animation(.easeInOut(duration: 0.35), value: router.isAuthenticated)
            .navigationDestination(for: Route.self) { route in
                switch route {
                case .login:
                    LoginView()
                case .content:
                    MainTabView()
                case .search:
                    SearchView()
                case .category(id: let id, name: let name):
                    CategoryProductsView(categoryId: id, categoryName: name)
                case .profile:
                    ProfileView()
                case .profileEdit:
                    ProfileEditView()
                }
            }
        }
    }
}

#Preview {
    AppRootView()
}
