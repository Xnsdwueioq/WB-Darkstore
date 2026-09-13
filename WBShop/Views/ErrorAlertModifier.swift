import SwiftUI

struct ErrorAlertModifier: ViewModifier {
    let errorMessage: String?
    let onDismiss: () -> Void

    func body(content: Content) -> some View {
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

extension View {
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
