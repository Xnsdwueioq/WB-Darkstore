import SwiftUI
import Core
import DSKit

struct ProfileView: View {
    @Injected var userService: UserServicing
    @State private var user: User?
    @Injected var router: Router

    private var initials: String {
            String(user?.name.first.map(String.init) ?? "?").uppercased()
        }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                Button {
                    router.push(.profileEdit)
                } label: {
                    HStack(spacing: DSSpacing.md) {
                        ZStack {
                            Circle()
                                .fill(DSColors.disabled.opacity(0.4))
                                .frame(width: 56, height: 56)
                            Text(initials)
                                .font(DSTypography.headline)
                                .foregroundColor(DSColors.black)
                        }
                        
                        VStack(alignment: .leading, spacing: 0) {
                            Text(user?.name.isEmpty == false ? user!.name : "Нет имени")
                                .font(DSTypography.body.weight(.semibold))
                                .foregroundColor(DSColors.black)
                            
                            HStack {
                                Text(user?.phone.isEmpty == false ? user!.phone : "Нет номера телефона")
                                    .font(DSTypography.caption)
                                    .foregroundColor(DSColors.black)
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(DSColors.secondary)
                            }
                        }
                        Spacer()
                        
                    }
                }
                .padding(.top, DSSpacing.sm)
                
                Text("История заказов")
                    .font(DSTypography.order.weight(.regular))
                    .padding(.top, DSSpacing.lg)
                
                OrderHistoryView()
            }
            .padding(DSSpacing.lg)
            .task {
                user = await userService.getProfileInfo()
            }
            .background(DSColors.background)
            .navigationTitle("Профиль")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct ProfileEditView: View {
    @Environment(\.dismiss) private var dismiss
    @Injected private var userService: UserServicing

    var onLoggedOut: () -> Void = {}

    @State private var name: String = ""
    @State private var phone: String = ""
    @State private var birthday: String = ""
    @State private var originalUser: User?
    @State private var isLoading = true
    @State private var isSaving = false
    @State private var showLogoutConfirmation = false
    @State private var showDeleteConfirmation = false

    @State private var showDatePicker = false
    @State private var selectedDate = Date()

    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        return formatter
    }()

    private var hasChanges: Bool {
        guard let originalUser else { return false }
        return name != originalUser.name || birthday != originalUser.birthday
    }

    private var initials: String {
        String(name.first.map(String.init) ?? "?").uppercased()
    }

    var body: some View {
        Group {
            if isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    VStack(spacing: DSSpacing.xxl) {
                        ZStack {
                            Circle()
                                .fill(DSColors.disabled.opacity(0.4))
                                .frame(width: 96, height: 96)
                            Text(initials)
                                .font(DSTypography.headline)
                                .foregroundColor(DSColors.black)
                        }
                        .padding(.top, DSSpacing.xl)

                        VStack(spacing: DSSpacing.lg) {
                            fieldBlock(title: "Имя") {
                                TextField("Имя", text: $name)
                                    .font(DSTypography.body)
                            }

                            fieldBlock(title: "Телефон", isLocked: true) {
                                Text(phone)
                                    .font(DSTypography.body)
                                    .foregroundColor(DSColors.secondary)
                            }

                            fieldBlock(title: "День рождения") {
                                Button {
                                    selectedDate = dateFormatter.date(from: birthday) ?? Date()
                                    showDatePicker = true
                                } label: {
                                    HStack {
                                        Text(birthday.isEmpty ? "ДД.ММ.ГГГГ" : birthday)
                                            .font(DSTypography.body)
                                            .foregroundColor(birthday.isEmpty ? DSColors.secondary : DSColors.black)
                                        Spacer()
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, DSSpacing.lg)

                        DSButton(
                            title: "Сохранить изменения",
                            style: .lightPurple,
                            size: .regular,
                            fillWidth: true
                        ) {
                            Task { await save() }
                        }
                        .disabled(!hasChanges || isSaving)
                        .opacity(hasChanges ? 1 : 0.5)
                        .padding(.horizontal, DSSpacing.lg)
                    }
                    .padding(.bottom, DSSpacing.xxl)
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button("Выйти") {
                        showLogoutConfirmation = true
                    }
                    Button("Удалить профиль", role: .destructive) {
                        showDeleteConfirmation = true
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .foregroundColor(DSColors.black)
                }
            }
        }
        .sheet(isPresented: $showDatePicker) {
            VStack(spacing: DSSpacing.md) {
                DatePicker(
                    "День рождения",
                    selection: $selectedDate,
                    in: ...Date(),
                    displayedComponents: .date
                )
                .datePickerStyle(.graphical)
                .environment(\.locale, Locale(identifier: "ru_RU"))
                .padding()

                DSButton(
                    title: "Готово",
                    style: .lightPurple,
                    size: .regular,
                    fillWidth: true
                ) {
                    birthday = dateFormatter.string(from: selectedDate)
                    showDatePicker = false
                }
                .padding(.horizontal, DSSpacing.lg)
            }
            .presentationDetents([.height(480)])
        }
        .task {
            let user = await userService.getProfileInfo()
            originalUser = user
            name = user.name
            phone = user.phone
            birthday = user.birthday
            isLoading = false
        }
        .confirmationDialog(
            "Вы уверены, что хотите выйти?",
            isPresented: $showLogoutConfirmation,
            titleVisibility: .visible
        ) {
            Button("Выйти", role: .destructive) {
                Task { await performLogout() }
            }
        }
        .confirmationDialog(
            "Удалить профиль без возможности восстановления?",
            isPresented: $showDeleteConfirmation,
            titleVisibility: .visible
        ) {
            Button("Удалить профиль", role: .destructive) {
                Task { await performDeleteAccount() }
            }
        }
        .errorAlert(
            message: userService.errorMessage,
            onDismiss: { userService.clearErrorMessage() }
        )
    }

    @ViewBuilder
    private func fieldBlock<Content: View>(
        title: String,
        isLocked: Bool = false,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: DSSpacing.xs) {
            HStack(spacing: DSSpacing.xs) {
                if isLocked {
                    Image(systemName: "lock.fill")
                        .font(.caption)
                        .foregroundColor(DSColors.secondary)
                }
                Text(title)
                    .font(DSTypography.caption)
                    .foregroundColor(DSColors.secondary)
            }
            content()
            Divider()
        }
    }

    private func save() async {
        guard var updated = originalUser else { return }
        updated.name = name
        updated.birthday = birthday

        isSaving = true
        defer { isSaving = false }

        let success = await userService.editProfile(updated)
        if success {
            originalUser = updated
        }
    }

    private func performLogout() async {
        if await userService.logout() {
            onLoggedOut()
        }
    }

    private func performDeleteAccount() async {
        if await userService.deleteAccount() {
            onLoggedOut()
        }
    }
}

#Preview {
    ProfileView()
}
