import SwiftUI

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
