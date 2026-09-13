import SwiftUI
import Core
import DSKit

struct CategoryProductsView: View {
    let categoryId: String
    let categoryName: String

    @Injected var productService: ProductServicing

    @State private var selectedProduct: ProductPreview?
    @State private var isLoading = true

    var body: some View {
        Group {
            if isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ProductGridView(
                    products: productService.categoryProducts,
                    onSelectProduct: { selectedProduct = $0 },
                    isFavorite: { productService.isFavorite(id: $0) },
                    onToggleFavorite: { product in
                        Task { await productService.toggleFavorite(id: product.id) }
                    }
                )
            }
        }
        .navigationTitle(categoryName)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(item: $selectedProduct) { preview in
            ProductDetailContainerView(previewID: preview.id) {
                selectedProduct = nil
            }
            .presentationDetents([.large])
        }
        .task {
            await productService.fetchCategoryProducts(categoryId: categoryId)
            isLoading = false
        }
        .errorAlert(
            message: productService.errorMessage,
            onDismiss: {
                productService.clearError()
            }
        )
    }
}
