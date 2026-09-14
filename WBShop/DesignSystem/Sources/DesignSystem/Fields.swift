import SwiftUI

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
