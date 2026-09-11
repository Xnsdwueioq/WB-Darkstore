//
//  ProductGridView.swift
//  WBDarkstore
//
//  Created by Полина Гельман on 12.09.2026.
//

import SwiftUI
import BusinessLogic

struct ProductGridView: View {
    let products: [Product]
    let cartQuantities: [String: Int]
    let onSelectProduct: (Product) -> Void
    let onToggleFavorite: (Product) -> Void
    let onAdd: (Product) -> Void
    let onRemove: (Product) -> Void

    private let horizontalPadding: CGFloat = 16
    private let cardSpacing: CGFloat = 8
    private let rowSpacing: CGFloat = 18

    var body: some View {
        GeometryReader { geo in
            let cardWidth = (geo.size.width - horizontalPadding * 2 - cardSpacing) / 2
            let columns = [
                GridItem(.flexible(), spacing: cardSpacing),
                GridItem(.flexible(), spacing: cardSpacing)
            ]

            ScrollView {
                if products.isEmpty {
                    EmptyStateView()
                } else {
                    LazyVGrid(columns: columns, spacing: rowSpacing) {
                        ForEach(products) { product in
                            ProductCardView(
                                product: product,
                                width: cardWidth,
                                quantity: cartQuantities[product.id] ?? 0,
                                onAdd: { onAdd(product) },
                                onRemove: { onRemove(product) }
                            )
                            .overlay(alignment: .topTrailing) {
                                FavoriteButton(isFavorite: product.isFavorite) {
                                    onToggleFavorite(product)
                                }
                                .padding(8)
                            }
                            .onTapGesture {
                                onSelectProduct(product)
                            }
                        }
                    }
                    .padding(.horizontal, horizontalPadding)
                }
            }
        }
    }
}

struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "heart")
                .font(.title)
                .foregroundColor(.secondary)
            Text("Пока пусто")
                .font(.title3)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 80)
    }
}

struct FavoriteButton: View {
    let isFavorite: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: isFavorite ? "heart.fill" : "heart")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(isFavorite ? .pink : .white)
                .padding(6)
                .background(.ultraThinMaterial, in: Circle())
        }
    }
}
