import Foundation
import SwiftUI

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(of: "#", with: "")
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r = Double((int >> 16) & 0xFF) / 255
        let g = Double((int >> 8) & 0xFF) / 255
        let b = Double(int & 0xFF) / 255
        self.init(red: r, green: g, blue: b)
    }
}

extension LinearGradient {
    public static let figmaPurplePink = LinearGradient(
        gradient: Gradient(stops: [
            .init(color: Color(hex: "ED3CCA"), location: 0.0049),
            .init(color: Color(hex: "DF34D2"), location: 0.1488),
            .init(color: Color(hex: "D02BD9"), location: 0.2927),
            .init(color: Color(hex: "BF22E1"), location: 0.4314),
            .init(color: Color(hex: "AE1AE8"), location: 0.5702),
            .init(color: Color(hex: "9A10F0"), location: 0.7089),
            .init(color: Color(hex: "8306F7"), location: 0.8476),
            .init(color: Color(hex: "6600FF"), location: 0.9915)
        ]),
        startPoint: UnitPoint(x: 0.004, y: 0.437),
        endPoint: UnitPoint(x: 0.996, y: 0.563)
    )

    public static let figmaLightPinkPurple = LinearGradient(
        gradient: Gradient(stops: [
            .init(color: Color(hex: "FEF1FB"), location: 0.0049),
            .init(color: Color(hex: "FDF1FC"), location: 0.1488),
            .init(color: Color(hex: "FCF0FC"), location: 0.2927),
            .init(color: Color(hex: "FBF0FD"), location: 0.4314),
            .init(color: Color(hex: "F9EFFD"), location: 0.5702),
            .init(color: Color(hex: "F8EEFE"), location: 0.7089),
            .init(color: Color(hex: "F6EEFE"), location: 0.8476),
            .init(color: Color(hex: "F4EDFF"), location: 0.9915)
        ]),
        startPoint: UnitPoint(x: 0.004, y: 0.437),
        endPoint: UnitPoint(x: 0.996, y: 0.563)
    )

    public static let figmaSubtlePinkPurple = LinearGradient(
        gradient: Gradient(stops: [
            .init(color: Color(hex: "FEF1FB"), location: 0.0049),
            .init(color: Color(hex: "FDF1FC"), location: 0.1488),
            .init(color: Color(hex: "FCF0FC"), location: 0.2927),
            .init(color: Color(hex: "FBF0FD"), location: 0.4314),
            .init(color: Color(hex: "F9EFFD"), location: 0.5702),
            .init(color: Color(hex: "F8EEFE"), location: 0.7089),
            .init(color: Color(hex: "F6EEFE"), location: 0.8476),
            .init(color: Color(hex: "FFFFFF"), location: 0.9915)
        ]),
        startPoint: .top,
        endPoint: .bottom
    )
}

public enum DSButtonStyle {
    case primary
    case secondary
    case destructive
    case gradient
    case lightPurple
    case white

    var background: AnyShapeStyle {
        switch self {
        case .primary:
            return AnyShapeStyle(DSColors.primary)
        case .secondary:
            return AnyShapeStyle(DSColors.secondary)
        case .destructive:
            return AnyShapeStyle(DSColors.destructive)
        case .gradient:
            return AnyShapeStyle(LinearGradient.figmaPurplePink)
        case .lightPurple:
            return AnyShapeStyle(LinearGradient.figmaLightPinkPurple)
        case .white:
            return AnyShapeStyle(DSColors.white)
        }
    }

    var foregroundColor: Color {
        switch self {
        case .secondary,
                .lightPurple,
                .white:
            return .black
        default:
            return .white
        }
    }

    var outline: Color {
        switch self {
        case .white:
            return DSColors.lightPurple
        default:
            return .clear
        }
    }
}

public enum DSButtonSize {
    case compact
    case regular
    case medium
    case downloadReceipt
    var font: Font {
        switch self {
        case .compact:
            return DSTypography.button
        case .regular:
            return DSTypography.bodyBold
        case .medium:
            return DSTypography.order
        case .downloadReceipt:
            return DSTypography.order
        }
    }

    var horizontalPadding: CGFloat {
        switch self {
        case .compact:
            return DSSpacing.md
        case .regular:
            return DSSpacing.xl
        case .medium:
            return 130
        case .downloadReceipt:
            return DSSpacing.lg
        }
    }
    var verticalPadding: CGFloat {
        switch self {
        case .compact:
            return DSSpacing.sm
        case .regular:
            return 14
        case .medium, .downloadReceipt:
            return 13
        }
    }
    var cornerRadius: CGFloat {
        switch self {
        case .compact:
            return DSRadius.sm
        case .regular:
            return DSRadius.lg
        case .medium, .downloadReceipt:
            return DSRadius.lg
        }
    }
}

public struct DSButton: View {
    public let title: String
    public let style: DSButtonStyle
    public let size: DSButtonSize
    public let icon: Image?
    public let fillWidth: Bool
    public let action: () -> Void

    public init(
        title: String,
        style: DSButtonStyle,
        size: DSButtonSize = .regular,
        icon: Image? = nil,
        fillWidth: Bool = false,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.style = style
        self.size = size
        self.icon = icon
        self.fillWidth = fillWidth
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            HStack(spacing: DSSpacing.sm) {
                if fillWidth {
                    Spacer(minLength: 0)
                }
                Text(title)
                    .font(size.font)
                    .lineLimit(1)
                if let icon {
                    icon
                }
                if fillWidth {
                    Spacer(minLength: 0)
                }
            }
            .foregroundColor(style.foregroundColor)
            .padding(.horizontal, fillWidth ? DSSpacing.md : size.horizontalPadding)
            .padding(.vertical, size.verticalPadding)
            .frame(maxWidth: fillWidth ? .infinity : nil)
            .background(style.background)
            .cornerRadius(size.cornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: size.cornerRadius)
                    .stroke(style.outline, lineWidth: style.outline == .clear ? 0 : 2)
            )
        }
    }
}

public struct DSCloseButton: View {
    let action: () -> Void

    public init(action: @escaping () -> Void) {
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            Image(systemName: "xmark")
                .font(.system(size: 24))
                .foregroundStyle(.black.opacity(0.5))
                .padding(DSSpacing.xl)
        }
    }
}

public struct DSTextField: View {
    private let placeholder: String
    @Binding private var text: String

    public init(placeholder: String, text: Binding<String>) {
        self.placeholder = placeholder
        self._text = text
    }

    public var body: some View {
        TextField(placeholder, text: $text)
            .font(DSTypography.body)
            .padding(.horizontal, DSSpacing.xl)
            .frame(height: 50)
            .background(
                RoundedRectangle(cornerRadius: DSRadius.lg)
                    .fill(DSColors.background.opacity(0.76))
            )
            .overlay(
                RoundedRectangle(cornerRadius: DSRadius.lg)
                    .stroke(DSColors.border, lineWidth: 0.5)
            )
    }
}

public struct DSSecureField: View {
    private let placeholder: String
    @Binding private var text: String

    public init(placeholder: String, text: Binding<String>) {
        self.placeholder = placeholder
        self._text = text
    }

    public var body: some View {
        SecureField(placeholder, text: $text)
            .textContentType(.password)
            .font(DSTypography.body)
            .padding(.horizontal, DSSpacing.xl)
            .frame(height: 50)
            .background(
                RoundedRectangle(cornerRadius: DSRadius.lg)
                    .fill(DSColors.background.opacity(0.76))
            )
            .overlay(
                RoundedRectangle(cornerRadius: DSRadius.lg)
                    .stroke(DSColors.border, lineWidth: 0.5)
            )
    }
}

public struct DSCard<Content: View>: View {
    private let content: Content

    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    public var body: some View {
        VStack(alignment: .leading,
               spacing: DSSpacing.sm) {
            content
        }
        .padding(DSSpacing.lg)
        .background(DSColors.surface)
        .cornerRadius(DSRadius.lg)
        .shadow(radius: 4)
    }
}

public struct DSInfoBanner: View {
    private let title: String
    private let message: String

    public init(title: String, message: String) {
        self.title = title
        self.message = message
    }

    public var body: some View {
        HStack(alignment: .top, spacing: DSSpacing.md) {
            Image(systemName: "info.circle.fill")
                .font(DSTypography.body)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: DSSpacing.xs) {
                Text(title)
                    .font(DSTypography.bodyBold)
                Text(message)
                    .font(DSTypography.caption)
            }
        }
        .foregroundStyle(DSColors.primary)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(DSSpacing.lg)
        .background(DSColors.lightPurple, in: RoundedRectangle(cornerRadius: DSRadius.lg))
    }
}
