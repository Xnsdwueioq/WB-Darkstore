import SwiftUI
import Core
import DSKit

struct FavoritesView: View {
    @Injected var productService: ProductServicing
    @State private var selectedProduct: ProductPreview?

    var body: some View {
        HStack {
            Text("Избранное")
                .font(DSTypography.display)
            Spacer()
        }
        .padding(.top, DSSpacing.sm_md)
        .padding(.horizontal, DSSpacing.md)

        ProductGridView(
            products: productService.favProducts,
            onSelectProduct: { selectedProduct = $0 },
            isFavorite: { productService.isFavorite(id: $0) },
            onToggleFavorite: { product in
                Task { await productService.toggleFavorite(id: product.id) }
            }
        )
        .navigationTitle("Избранное")
        .background(DSColors.surface)
        .task {
            await productService.fetchFavProducts()
        }
        .sheet(item: $selectedProduct) { preview in
            ProductDetailContainerView(previewID: preview.id) {
                selectedProduct = nil
            }
            .presentationDetents([.large])
            .presentationCornerRadius(DSRadius.sheet)
        }
        .errorAlert(
            message: productService.errorMessage,
            onDismiss: {
                productService.clearError()
            }
        )
    }
}

#Preview {
    FavoritesView()
}

struct FavoriteButton: View {
    let isFavorite: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(isFavorite ? "PinkHeart" : "GreyHeart")
                .resizable()
                .scaledToFit()
                .frame(width: 24, height: 24)
                .scaleEffect(isFavorite ? 1.15 : 1.0)
                .padding(8)
                .clipShape(Circle())
        }
        .buttonStyle(.plain)
        .animation(.spring(response: 0.3, dampingFraction: 0.5), value: isFavorite)
        .sensoryFeedback(.impact(weight: .light), trigger: isFavorite)
    }
}
