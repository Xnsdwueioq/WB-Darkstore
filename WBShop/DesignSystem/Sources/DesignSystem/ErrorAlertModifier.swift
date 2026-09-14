import SwiftUI

public struct ErrorAlertModifier: ViewModifier {
    let errorMessage: String?
    let onDismiss: () -> Void

    public init(errorMessage: String?, onDismiss: @escaping () -> Void) {
        self.errorMessage = errorMessage
        self.onDismiss = onDismiss
    }

    public func body(content: Content) -> some View {
        content
            .alert(
                "Ошибка",
                isPresented: Binding(
                    get: {
                        errorMessage != nil
                    },
                    set: { isPresented in
                        if !isPresented {
                            onDismiss()
                        }
                    }
                )
            ) {
                Button("OK") {
                    onDismiss()
                }
            } message: {
                Text(errorMessage ?? "Произошла неизвестная ошибка")
            }
    }
}

public extension View {
    func errorAlert(
        message: String?,
        onDismiss: @escaping () -> Void
    ) -> some View {
        modifier(
            ErrorAlertModifier(
                errorMessage: message,
                onDismiss: onDismiss
            )
        )
    }
}
