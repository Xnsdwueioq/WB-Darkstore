import SwiftUI
import OpenAPIRuntime
import DSKit
import Core

extension ProductPreview: Identifiable {
}

struct ContentView: View {
    @Injected var productService: ProductServicing
    @Injected var router: Router

    @State private var selectedProduct: ProductPreview?

    var body: some View {
        VStack(spacing: DSSpacing.md) {
            HStack(spacing: DSSpacing.md) {
                AddressSelectorView()

                Button {
                    router.push(.profile)
                } label: {
                    Image(systemName: "person.fill")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(DSColors.black)
                        .frame(width: 36, height: 36)
                        .background(DSColors.lightPurple)
                        .clipShape(Circle())
                }
            }
            .padding(.horizontal, DSSpacing.md)
            .padding(.vertical, DSSpacing.sm)
            .background(DSColors.smoky)
            .cornerRadius(DSRadius.xl)
            .padding(.horizontal, DSSpacing.lg)

            ProductGridView(
                products: productService.products,
                onSelectProduct: { selectedProduct = $0 },
                isFavorite: { productService.isFavorite(id: $0) },
                onToggleFavorite: { product in
                    Task { await productService.toggleFavorite(id: product.id) }
                }
            )
            .background(DSColors.surface)
        }
        .task {
            await productService.fetchProducts()
        }
        .sheet(item: $selectedProduct) { preview in
            ProductDetailContainerView(previewID: preview.id){
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
    ContentView()
}
