import SwiftUI
import DSKit
import Core

struct ProductCardView: View {
    let product: ProductPreview
    var width: CGFloat = 174
    @Injected var cart: CartServicing
    
    private var imageHeight: CGFloat {
        width * (256.0 / /*174*/ 256.0)
    }

    private var quantity: Int {
        cart.cartQuantities[product.id] ?? 0
    }

    private var totalPrice: Int {
        Int(product.price) * quantity
    }

    var body: some View {
        VStack(alignment: .leading, spacing: DSSpacing.sm) {
            ZStack {
                if let imageUrl = URL(string: product.image) {
                    CachedAsyncImage(url: imageUrl) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                                .frame(width: width, height: imageHeight)
                                .background(DSColors.secondary)

                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFill()
                                .frame(width: width, height: imageHeight)

                        case .failure:
                            Image(systemName: "photo")
                                .font(.largeTitle)
                                .foregroundColor(DSColors.secondary)
                                .frame(width: width, height: imageHeight)
                                .background(Color(.systemGray5))

                        @unknown default:
                            EmptyView()
                        }
                    }
                    .clipped()
                    .cornerRadius(DSRadius.xl)
                } else {
                    Image(systemName: "photo")
                        .font(.largeTitle)
                        .foregroundColor(DSColors.secondary)
                        .frame(width: width, height: imageHeight)
                        .background(Color(.systemGray5))
                        .cornerRadius(DSRadius.xl)
                }

                if quantity >= 1 {
                    Rectangle()
                        .fill(Color(DSColors.secondary))
                        .frame(width: width, height: imageHeight)
                        .opacity(0.5)
                        .cornerRadius(DSRadius.xl)
                        .transition(.scale.combined(with: .opacity))
                    Text("\(quantity)")
                        .font(DSTypography.display.weight(.bold))
                        .foregroundStyle(DSColors.white)
                }
            }
            .animation(.spring(response: 0.3, dampingFraction: 0.75), value: quantity)


            HStack {
                Text(product.name)
                    .font(DSTypography.caption)
                    .lineLimit(2)
                    .frame(height: 37, alignment: .topLeading)
                
                Text("\(product.weight, specifier: "%.0f") г")
                    .font(DSTypography.caption)
                    .foregroundColor(DSColors.secondary)
                    .frame(height: 37, alignment: .topLeading)
                
            }
            
            HStack {
                if quantity > 0 {
                    HStack(spacing: DSSpacing.sm) {
                        Button {
                            Task {
                                await cart.removeProductFromCart(id: product.id)
                            }
                        } label: {
                            Image(systemName: "minus")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.white)
                                .contentShape(Rectangle())
                        }


                        Text("\(totalPrice) ₽")
                            .font(DSTypography.caption)
                            .bold()
                            .foregroundColor(.white)
                            .lineLimit(1)


                        Button {
                            Task {
                                await cart.addProductToCart(id: product.id)
                            }
                        } label: {
                            Image(systemName: "plus")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.white)
                                .contentShape(Rectangle())
                        }

                    }
                    .padding(.horizontal, DSSpacing.md)
                    .padding(.vertical, DSSpacing.sm)
                    .background(
                        LinearGradient.figmaPurplePink
                    )
                    .cornerRadius(DSRadius.md)
                    .transition(.scale.combined(with: .opacity))
                } else {
                    DSButton(
                        title: "\(Int(product.price)) ₽",
                        style: .lightPurple,
                        size: .compact,
                        icon: Image(systemName: "plus")
                    ) {
                        Task {
                            await cart.addProductToCart(id: product.id)
                        }
                    }
                    .transition(.scale.combined(with: .opacity))
                }
            }
            .animation(.spring(response: 0.3, dampingFraction: 0.75), value: quantity)
        }
        .frame(width: width)
        .background(DSColors.background)
        .contentShape(Rectangle())
        .errorAlert(
            message: cart.errorMessage,
            onDismiss: {
                cart.clearErrorMessage()
            }
        )
    }
}
