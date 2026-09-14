import SwiftUI
import Core
import DSKit

extension Components.Schemas.Order: Identifiable {}

struct CartView: View {
    let onDismiss: () -> Void
    @Injected var cart: CartServicing
    @Injected private var userService: UserServicing
    @AppStorage("selectedAddressId") private var selectedAddressId = ""
    @State private var orderToShow: Order?
    @State private var isPlacingOrder = false
    @State private var isOrderSuccessPresented = false

    private var hasUnavailableProducts: Bool {
        cart.productsInCart.contains { !$0.isAvailable }
    }

    private var totalProductsCount: Int {
        cart.productsInCart.reduce(0) { $0 + $1.quantity }
    }

    private var hasActiveOrder: Bool {
        return userService.orders.filter { $0.status == .active }.count >= 1
    }

    private var isButtonDisabled: Bool {
        cart.productsInCart.isEmpty || hasUnavailableProducts || userService.addresses.isEmpty
            || isPlacingOrder || hasActiveOrder
    }

    var body: some View {
        ZStack(alignment: .topTrailing) {
            VStack(alignment: .leading, spacing: DSSpacing.cartTitleSpacingList) {
                HStack {
                    Text("Корзина")
                        .font(DSTypography.display)
                    Text("\(totalProductsCount)")
                        .font(DSTypography.display)
                        .foregroundStyle(DSColors.secondary)
                    Spacer()
                }
                .padding(.top, DSSpacing.smMd)
                .padding(.horizontal, DSSpacing.md)

                if cart.productsInCart.isEmpty {
                    ContentUnavailableView(
                        "Корзина пуста",
                        systemImage: "cart",
                        description: Text("Добавьте товары из каталога, чтобы оформить заказ")
                    )
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    VStack(alignment: .leading, spacing: DSSpacing.sm) {
                        Text("15 минут · \(totalProductsCount) товар\(pluralSuffix(totalProductsCount))")
                            .font(DSTypography.button)
                            .padding(.horizontal, DSSpacing.md)
                            .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: DSSpacing.md, trailing: 0))
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.clear)

                        List {
                            ForEach(cart.productsInCart) { product in
                                CartItemView(
                                    product: product,
                                    onIncrement: {
                                        Task { await cart.addProductToCart(id: product.id) }
                                    },
                                    onDecrement: {
                                        Task { await cart.removeProductFromCart(id: product.id) }
                                    }
                                )
                                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                    Button(role: .destructive) {
                                        Task {
                                            await cart.deleteProductFromCart(id: product.id)
                                        }
                                    } label: {
                                        Label("Удалить", systemImage: "trash")
                                    }
                                }
                                .listRowSeparator(.hidden)
                                .listRowBackground(Color.clear)
                                .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: DSSpacing.lg, trailing: 0))
                            }

                            VStack(spacing: DSSpacing.xl) {
                                AddressSelectorView()

                                HStack {
                                    Text("Оплата картой")
                                        .font(DSTypography.priceBold)
                                    Image(systemName: "chevron.right")
                                        .font(DSTypography.bodyBold)
                                        .foregroundColor(DSColors.black)
                                    Spacer()
                                }

                                HStack {
                                    Text("Итого")
                                        .font(DSTypography.priceBold)
                                    Spacer()
                                    DSPriceText(Double(cart.totalPrice), font: DSTypography.priceBold)
                                }

                                VStack {
                                    HStack {
                                        Text("\(totalProductsCount) товар\(pluralSuffix(totalProductsCount))")
                                            .font(DSTypography.caption)
                                        Spacer()
                                        DSPriceText(Double(cart.totalPrice), font: DSTypography.caption)
                                    }

                                    HStack {
                                        Text("Доставка")
                                            .font(DSTypography.caption)
                                        Spacer()
                                        Text("Бесплатно")
                                            .font(DSTypography.caption)
                                    }
                                }
                            }
                            .padding(.horizontal, DSSpacing.md)
                            .padding(.top, DSSpacing.md)
                            .padding(.bottom, DSSpacing.xxl)
                            .background(LinearGradient.figmaSubtlePinkPurple)
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.clear)
                            .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))

                            DSButton(
                                title: "Заказать",
                                style: .gradient,
                                size: .medium,
                                fillWidth: true
                            ) {
                                Task {
                                    // если с другого устройства сделали заказ, пока открыта cart view
                                    await userService.getOrders()

                                    if !hasActiveOrder {
                                        await placeOrder()
                                    }

                                    // апдейт после заказа
                                    await userService.getOrders()
                                }
                            }
                            .buttonStyle(.plain)
                            .disabled(isButtonDisabled)
                            .opacity(isButtonDisabled ? 0.5 : 1)
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.clear)
                            if hasActiveOrder {
                                DSInfoBanner(
                                    title: "Ваш заказ уже в работе",
                                    message: "Новый заказ можно будет оформить, когда текущий завершится."
                                )
                                .padding(.horizontal, DSSpacing.md)
                                .listRowInsets(
                                    EdgeInsets(top: DSSpacing.md, leading: 0, bottom: DSSpacing.lg, trailing: 0)
                                )
                                .listRowSeparator(.hidden)
                                .listRowBackground(Color.clear)
                            }
                        }
                        .listStyle(.plain)
                        .scrollContentBackground(.hidden)
                    }
                }
            }
        }
        .task {
            await cart.fetchProducts()
            await userService.getOrders()
        }
        .fullScreenCover(isPresented: $isOrderSuccessPresented) {
            DSSuccessScreen(
                title: "Заказ\nоформлен",
                subtitle: "Товары уже в процессе сборки,\nскоро привезём!",
                buttonTitle: "Закрыть",
                onClose: {
                    isOrderSuccessPresented = false
                    onDismiss()
                    orderToShow = userService.orders.first(where: { $0.status == .active })
                },
                onAction: {
                    isOrderSuccessPresented = false
                    onDismiss()
                    orderToShow = userService.orders.first(where: { $0.status == .active })
                }
            )
        }
        .sheet(item: $orderToShow) { order in
            OrderDetailView(order: order) {
                orderToShow = nil
                onDismiss()
            }
        }
        .errorAlert(
            message: cart.errorMessage,
            onDismiss: {
                cart.clearErrorMessage()
            }
        )
        .errorAlert(
            message: userService.errorMessage,
            onDismiss: {
                userService.clearErrorMessage()
            }
        )
    }

    private func placeOrder() async {
        let addressIdToUse = selectedAddressId.isEmpty ? userService.addresses.first?.id : selectedAddressId
        guard let addressIdToUse else { return }

        isPlacingOrder = true
        defer { isPlacingOrder = false }
        await cart.createOrder(paymentMethod: "CASH", addressId: addressIdToUse)
        guard cart.errorMessage == nil else { return }
        await userService.getOrders()
        isOrderSuccessPresented = true
    }
}

#Preview {
    CartView {
        print()
    }
}

struct CartItemView: View {
    let product: CartProduct
    let onIncrement: () -> Void
    let onDecrement: () -> Void

    var body: some View {
        HStack(alignment: .top, spacing: DSSpacing.md) {
            ZStack {
                if let imageUrl = URL(string: product.image) {
                    CachedAsyncImage(url: imageUrl) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                                .frame(width: 100, height: 100)
                                .background(DSColors.secondary)

                        case .success(let image):
                            image
                                .resizable().scaledToFill()
                                .frame(width: 100, height: 100)
                                .clipped()

                        case .failure:
                            Image(systemName: "photo")
                                .foregroundColor(DSColors.secondary)
                                .frame(width: 100, height: 100)
                                .background(DSColors.disabled)

                        @unknown default:
                            EmptyView()
                        }
                    }
                    .cornerRadius(DSRadius.md)
                } else {
                    Image(systemName: "photo")
                        .foregroundColor(DSColors.secondary)
                        .frame(width: 100, height: 100)
                        .background(DSColors.disabled)
                        .cornerRadius(DSRadius.md)
                }

                if !product.isAvailable {
                    Color.black.opacity(0.3)
                        .cornerRadius(DSRadius.md)
                }
            }
            .frame(width: 100, height: 100)

            VStack(alignment: .leading, spacing: DSSpacing.xs) {
                if product.isAvailable {
                    DSPriceText(Double(product.quantity) * Double(product.price), font: DSTypography.priceBold)
                } else {
                    Text("Нет в наличии")
                        .font(DSTypography.caption)
                        .foregroundColor(.red)
                        .padding(.vertical, 2)
                }

                HStack {
                    Text(product.name)
                        .font(DSTypography.caption)
                    Text("\(product.weight)г")
                        .font(DSTypography.caption)
                        .foregroundStyle(DSColors.secondary)
                }

                DSCounterView(
                    count: product.quantity,
                    onIncrement: onIncrement,
                    onDecrement: onDecrement
                )
                .disabled(!product.isAvailable)
                .padding(.top, DSSpacing.md)
            }
            Spacer()
        }
        .padding(.horizontal, DSSpacing.md)
        .opacity(product.isAvailable ? 1.0 : 0.5)
    }
}
