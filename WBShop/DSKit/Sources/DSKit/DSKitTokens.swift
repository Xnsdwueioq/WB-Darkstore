import Foundation
import SwiftUI

public enum DSColors {
    public static let primary = Color.purple
    public static let secondary = Color.gray
    public static let background = Color(.systemBackground)
    public static let surface = Color.white
    public static let border = Color.gray.opacity(0.1)
    public static let destructive = Color.red
    public static let disabled = Color.gray.opacity(0.4)
    public static let black = Color.black
    public static let blue = Color.blue
    public static let white = Color.white
    public static let lightPurple = Color.purple.opacity(0.1)
    public static let smoky = Color(hex: "F6F6FA")
    public static let reviewRatingTrack = Color(hex: "F0ECF4")
    public static let reviewRatingMuted = Color(hex: "9797AF")
    public static let favoriteActive = Color(hex: "E313BF")
    public static let favoriteInactive = Color(hex: "B9B9B8")
}

public enum DSSpacing {
    public static let xs: CGFloat = 4
    public static let sm: CGFloat = 8
    public static let smMd: CGFloat = 10
    public static let md: CGFloat = 12
    public static let lg: CGFloat = 16
    public static let xl: CGFloat = 20
    public static let xxl: CGFloat = 24
    public static let cartTitleSpacingList: CGFloat = 20

}

public enum DSRadius {
    public static let sm: CGFloat = 6
    public static let md: CGFloat = 8
    public static let lg: CGFloat = 12
    public static let xl: CGFloat = 16
    public static let sheet: CGFloat = 20
}

public enum DSTypography {
    public static let display = Font.custom("Inter", size: 32).weight(.medium)
    public static let success = Font.custom("Inter", size: 56).weight(.semibold)
    public static let title = Font.custom("Inter", size: 26).weight(.semibold)
    public static let headline = Font.custom("Inter", size: 24).weight(.bold)
    public static let body = Font.custom("Inter", size: 16)
    public static let bodyBold = Font.custom("Inter", size: 16).weight(.semibold)
    public static let priceBold = Font.custom("Inter", size: 17).weight(.bold)
    public static let order = Font.custom("Inter", size: 20).weight(.semibold)
    public static let button = Font.custom("Inter", size: 14).weight(.semibold)
    public static let caption = Font.custom("Inter", size: 14)
    public static let reviewAvgRating = Font.custom("Inter", size: 94)
}

public struct DSCounterView: View {
    let count: Int
    let onIncrement: () -> Void
    let onDecrement: () -> Void

    public init(count: Int, onIncrement: @escaping () -> Void, onDecrement: @escaping () -> Void) {
        self.count = count
        self.onIncrement = onIncrement
        self.onDecrement = onDecrement
    }

    public var body: some View {
        HStack(spacing: DSSpacing.lg) {
            Button(action: onDecrement) {
                Image(systemName: "minus")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.black)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            Text("\(count)")
                .font(DSTypography.body)
                .frame(minWidth: 20)
                .multilineTextAlignment(.center)

            Button(action: onIncrement) {
                Image(systemName: "plus")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.black)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, DSSpacing.md)
        .padding(.vertical, DSSpacing.sm)
        .background(Color(.systemGroupedBackground))
        .cornerRadius(DSRadius.md)
    }
}

private extension NumberFormatter {
    static let price: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.usesGroupingSeparator = false
        return formatter
    }()
}

public struct DSPriceText: View {
    let value: Double
    let font: Font

    public init(_ value: Double, font: Font = DSTypography.display) {
        self.value = value
        self.font = font
    }

    public var body: some View {
        Text(formattedPrice)
            .font(font)
    }

    private var formattedPrice: String {
        let string = NumberFormatter.price.string(from: NSNumber(value: value)) ?? "\(Int(value))"

        return "\(string) ₽"
    }
}

public struct DSSuccessScreen: View {
    public let title: String
    public let subtitle: String
    public let buttonTitle: String
    public let onClose: () -> Void
    public let onAction: () -> Void

    public init(
        title: String,
        subtitle: String,
        buttonTitle: String = "Закрыть",
        onClose: @escaping () -> Void,
        onAction: @escaping () -> Void
    ) {
        self.title = title
        self.subtitle = subtitle
        self.buttonTitle = buttonTitle
        self.onClose = onClose
        self.onAction = onAction
    }

    public var body: some View {
        ZStack {
            LinearGradient.figmaPurplePink
                .ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    Spacer()
                    Button(action: onClose) {
                        Image(systemName: "xmark")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(.white.opacity(0.8))
                            .padding(DSSpacing.lg)
                    }
                }

                Spacer()

                Image("checkmark", bundle: .module)
                    .padding(.bottom, DSSpacing.xl)

                Text(title)
                    .font(DSTypography.success)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.leading)
                    .padding(.bottom, DSSpacing.md)

                Text(subtitle)
                    .font(DSTypography.order)
                    .foregroundColor(.white.opacity(0.7))
                    .multilineTextAlignment(.leading)
                    .padding(.bottom, 40)

                DSButton(
                    title: buttonTitle,
                    style: .white,
                    size: .medium,
                    fillWidth: true,
                    action: onAction
                )
                .padding(.bottom, DSSpacing.xxl)
            }
            .padding(.horizontal, DSSpacing.md)
        }
    }
}

#Preview {
    DSSuccessScreen(
        title: "Заказ оформлен",
        subtitle: "Товары уже в процессе сборки, скоро привезём!",
        buttonTitle: "Закрыть",
        onClose: { print() },
        onAction: { print() }
    )
}
