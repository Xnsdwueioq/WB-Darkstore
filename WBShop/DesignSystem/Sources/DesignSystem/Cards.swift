import SwiftUI

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
