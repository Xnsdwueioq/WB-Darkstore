import SwiftUI

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
