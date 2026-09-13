//
//  ContentView.swift
//  WBDarkstore
//
//  Created by Valeriy Solovey  on 04.09.2026.
//

import SwiftUI
import BusinessLogic
import Core

struct ContentView: View {
    @Injected var catalogService: CatalogServiceProtocol
    @Injected var productService: ProductServiceProtocol
    @Injected var cartService: CartServiceProtocol

    @State private var products: [Product] = []
    @State private var cart: Cart?
    @State private var selectedProduct: Product?
    @State private var errorMessage: String?

    private var cartQuantities: [String: Int] {
        guard let cart else { return [:] }
        return Dictionary(uniqueKeysWithValues: cart.items.map { ($0.id, $0.quantity) })
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            ProductGridView(
                products: products,
                cartQuantities: cartQuantities,
                onSelectProduct: { selectedProduct = $0 },
                onToggleFavorite: { product in
                    Task { await toggleFavorite(product) }
                },
                onAdd: { product in
                    Task { await addToCart(product) }
                },
                onRemove: { product in
                    Task { await removeFromCart(product) }
                }
            )

            if let cart, cart.totalItems > 0 {
                CheckoutBarView(totalItems: cart.totalItems, totalPrice: cart.totalPrice) {
                    // TODO: переход на экран оформления заказа
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 12)
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: cart?.totalItems)
        .task {
            await loadProducts()
            await loadCart()
        }
        .sheet(item: $selectedProduct) { product in
            ProductDetailContainerView(productID: product.id) {
                selectedProduct = nil
            }
        }
        .alert("Ошибка", isPresented: .constant(errorMessage != nil), actions: {
            Button("ОК") { errorMessage = nil }
        }, message: {
            Text(errorMessage ?? "")
        })
    }

    private func loadProducts() async {
        do {
            let list = try await catalogService.getProducts(categoryID: nil, page: 1, pageSize: 10)
            products = list.products
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func loadCart() async {
        do {
            cart = try await cartService.getCart()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func addToCart(_ product: Product) async {
        do {
            _ = try await cartService.addToCart(productID: product.id)
            await loadCart() // total из ответа — это счётчик по всей корзине, а не по товару, поэтому перезапрашиваем
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func removeFromCart(_ product: Product) async {
        do {
            _ = try await cartService.removeFromCart(productID: product.id)
            await loadCart()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func toggleFavorite(_ product: Product) async {
        do {
            try await productService.setFavorite(!product.isFavorite, productID: product.id)
            await loadProducts()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

#Preview {
    ContentView()
}
