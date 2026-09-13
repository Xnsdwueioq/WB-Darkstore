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
    @Injected private var cart: CartServicing

    private var totalProductsCount: Int {
        cart.productsInCart.reduce(0) { $0 + $1.quantity }
    }

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
        .overlay(alignment: .bottom) {
            if selectedTab != .cart {
                HStack(spacing: DSSpacing.sm) {
                    SearchBarButton {
                        router.push(.search)
                    }

                    if !cart.productsInCart.isEmpty {
                        CheckoutFloatingButton(
                            totalPrice: cart.totalPrice,
                            itemsCount: totalProductsCount,
                            fillWidth: true
                        ) {
                            selectedTab = .cart
                        }
                    } else {
                        Spacer()
                    }
                }
                .padding(.horizontal, DSSpacing.lg)
                .padding(.bottom, 60)
            }
        }
    }
}
