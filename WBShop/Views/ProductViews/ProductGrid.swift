import SwiftUI
import DSKit

struct ProductGridView: View {
    let products: [ProductPreview]
    let onSelectProduct: (ProductPreview) -> Void
    let isFavorite: (String) -> Bool
    let onToggleFavorite: (ProductPreview) -> Void

    private let horizontalPadding = DSSpacing.md
    private let cardSpacing = DSSpacing.xs
    private let rowSpacing = 18.0

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
                            ProductCardView(product: product, width: cardWidth)
                                .overlay(alignment: .topTrailing) {
                                    FavoriteButton(isFavorite: isFavorite(product.id)) {
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
        VStack(spacing: DSSpacing.md) {
            Image(systemName: "heart")
                .font(DSTypography.title)
                .foregroundColor(DSColors.secondary)
            Text("Пока пусто")
                .font(DSTypography.title)
                .foregroundColor(DSColors.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 80)
    }
}
