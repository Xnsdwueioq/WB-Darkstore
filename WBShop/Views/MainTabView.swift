import SwiftUI
import Core
import DSKit

struct MainTabView: View {
    @Injected private var router: Router

    var body: some View {
        @Bindable var router = router

        TabView(selection: $router.selectedTab) {
            Tab("Все товары",
                systemImage: "square.grid.2x2",
                value: MainTab.catalog) {
                ContentView()
            }
            
            Tab("Категории",
                systemImage: "list.bullet",
                value: MainTab.categories) {
                CategoriesView()
            }

            Tab("Избранное",
                systemImage: "heart.fill",
                value: MainTab.favorites) {
                FavoritesView()
            }

            Tab("Корзина",
                systemImage: "cart",
                value: MainTab.cart) {
                CartView {
                    print()
                }
            }
        }
        .overlay(alignment: .bottomLeading) {
            if router.selectedTab != .cart {
                SearchBarButton {
                    router.push(.search)
                }
                    .padding(.horizontal, DSSpacing.lg)
                    .padding(.bottom, 60)
            }
        }
    }
}
