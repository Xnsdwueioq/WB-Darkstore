import SwiftUI

public struct DSProductDetailedButton: View {
    public let quantity: Int
    public let onIncrement: () -> Void
    public let onDecrement: () -> Void
    public let onOpenCart: () -> Void

    public init(
        quantity: Int,
        onIncrement: @escaping () -> Void,
        onDecrement: @escaping () -> Void,
        onOpenCart: @escaping () -> Void
    ) {
        self.quantity = quantity
        self.onIncrement = onIncrement
        self.onDecrement = onDecrement
        self.onOpenCart = onOpenCart
    }

    public var body: some View {
        if quantity > 0 {
            HStack(spacing: 6) {
                HStack(spacing: 0) {
                    Button(action: onDecrement) {
                        Image("cartMinus", bundle: .module)
                            .frame(width: 42, height: 50)
                            .contentShape(Rectangle())
                    }
                    .accessibilityLabel("Уменьшить количество")

                    Text("\(quantity)")
                        .font(DSTypography.order)
                        .monospacedDigit()
                        .frame(maxWidth: .infinity)
                        .accessibilityLabel("В корзине \(quantity)")

                    Button(action: onIncrement) {
                        Image("cartPlus", bundle: .module)
                            .frame(width: 42, height: 50)
                            .contentShape(Rectangle())
                    }
                    .accessibilityLabel("Увеличить количество")
                }
                .buttonStyle(.plain)
                .foregroundStyle(DSColors.black)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(DSColors.smoky, in: RoundedRectangle(cornerRadius: DSRadius.lg))

                DSButton(title: "В корзине", style: .gradient, size: .medium, fillWidth: true, action: onOpenCart)
                    .frame(maxWidth: .infinity)
                    .accessibilityHint("Открывает корзину")
            }
        } else {
            DSButton(title: "В корзину", style: .gradient, size: .medium, fillWidth: true, action: onIncrement)
        }
    }
}
