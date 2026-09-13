import SwiftUI
import DSKit
import Core

struct ProductDetailView: View {
    let product: Product
    let onDismiss: () -> Void
    @State private var showReviews = false


    var body: some View {
        ZStack(alignment: .topTrailing) {
            ScrollView {
                VStack(alignment: .leading, spacing: DSSpacing.xl) {
                    if let imageUrl = URL(string: product.image) {
                        CachedAsyncImage(url: imageUrl) { phase in
                            switch phase {
                            case .empty:
                                ProgressView()
                                    .frame(width: UIScreen.main.bounds.width, height: 440)
                                    .background(Color(.systemGray6))
                                
                            case .success(let image):
                                image
                                    .resizable()
                                    .scaledToFill()
                                    .frame(maxWidth: UIScreen.main.bounds.width, maxHeight: 440)
                                
                            case .failure:
                                Image(systemName: "photo")
                                    .font(.largeTitle)
                                    .foregroundColor(.gray)
                                    .frame(maxWidth: UIScreen.main.bounds.width, maxHeight: 440)
                                    .background(Color(.systemGray5))
                                
                            @unknown default:
                                EmptyView()
                            }
                        }
                        .clipped()
                        .cornerRadius(16)
                    } else {
                        Image(systemName: "photo")
                            .font(.largeTitle)
                            .foregroundColor(.gray)
                            .frame(maxWidth: UIScreen.main.bounds.width, maxHeight: 440)
                            .background(Color(.systemGray5))
                            .cornerRadius(16)
                    }

                    VStack(alignment: .leading, spacing: DSSpacing.xs) {
                        DSPriceText(Double(product.price))
                            .font(DSTypography.display)
                        
                        HStack {
                            Text(product.name)
                                .font(DSTypography.title)
                            
                            Text("\(Int(product.weight))г")
                                .font(DSTypography.title)
                                .foregroundStyle(DSColors.secondary)
                        }
                        HStack (alignment: .center) {
                            Text(String(format: "%.1f", product.rating))
                                .font(DSTypography.body)
                            
                            RatingStarsView(rating: Double(product.rating), starSize: DSTypography.caption)
                            
                            Button {
                                showReviews = true
                            } label: {
                                HStack(alignment: .center) {
                                    Image("review")

                                    let count = product.reviews?.count ?? 0
                                    Text("\(count) \(reviewsWord(count))")

                                    Image(systemName: "chevron.right")
                                }
                                .font(DSTypography.body)
                                .foregroundStyle(DSColors.black)
                            }
                        }

                        
                        Text(product.description)
                            .font(DSTypography.body)
                            .padding(.top, DSSpacing.lg)
                    }
                    .padding(.horizontal, DSSpacing.lg)

                    Spacer()
                }
            }
            DSCloseButton(action: onDismiss)
        }
        .sheet(isPresented: $showReviews) {
            ReviewsView(product: product) {
                showReviews = false
            }
        }
    }
}

struct ProductDetailContainerView: View {
    let previewID: String
    @Injected var productService: ProductServicing
    let onDismiss: () -> Void

    @State private var product: Product?

    var body: some View {
        Group {
            if let product {
                ProductDetailView(product: product, onDismiss: onDismiss)
            } else {
                ZStack(alignment: .topTrailing) {
                    ProgressView("Загрузка...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)

                    DSCloseButton(action: onDismiss)
                        .padding(.top, DSSpacing.md)
                        .padding(.trailing, DSSpacing.md)
                }
            }
        }
        .task {
            product = await productService.fetchProductDetail(id: previewID)
        }
        .errorAlert(
            message: productService.errorMessage,
            onDismiss: {
                productService.clearError()
            }
        )
    }
}
