import SwiftUI
import Core
import DSKit

enum MainTab {
    case catalog
    case favorites
    case cart
    case categories
}

struct MainTabView: View {
    @State private var selectedTab: MainTab = .catalog
    @Injected var router: Router

    var body: some View {
        TabView(selection: $selectedTab) {
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
            if selectedTab != .cart {
                SearchBarButton {
                    router.push(.search)
                }
                    .padding(.horizontal, DSSpacing.lg)
                    .padding(.bottom, 60)
            }
        }
    }
}
