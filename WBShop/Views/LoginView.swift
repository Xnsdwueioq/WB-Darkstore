import SwiftUI
import DSKit
import Core

struct LoginView: View {
    @Injected var router: Router
    @Injected var authService: AuthServicing

    @State private var phone = ""
    @State private var password = ""
    @State private var errorMessage: String?

    var body: some View {
        VStack(spacing: DSSpacing.xl) {
            Text("Вход")
                .font(DSTypography.title)

            DSTextField(placeholder: "Номер телефона", text: $phone)
            DSTextField(placeholder: "Пароль", text: $password)

            if let errorMessage {
                Text(errorMessage)
                    .font(DSTypography.caption)
                    .foregroundColor(DSColors.destructive)
            }

            DSButton(title: "Войти", style: .gradient) {
                if authService.login(username: phone, password: password) {
                    router.login()
                } else {
                    errorMessage = "Заполните оба поля"
                }
            }
            .frame(maxWidth: 200)
        }
        .padding(DSSpacing.xxl)
        .background(DSColors.background)
    }
}

#Preview {
    LoginView()
}
