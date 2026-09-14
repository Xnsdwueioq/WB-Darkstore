//
//  WBShopApp.swift
//  WBShop
//
//  Created by Полина Гельман on 28.06.2026.
//

import SwiftUI
import Core
import DesignSystem
import BusinessLogic
import SwiftData

@main
struct WBShopApp: App {
    private let modelContainer: ModelContainer

    init() {
        do {
            self.modelContainer = try ModelContainer(for: CartItemModel.self)
        } catch {
            fatalError("Не удалось создать ModelContainer: \(error)")
        }

        setupApiToken()

        do {
            let container = try BusinessLogicContainer(
                modelContainer: modelContainer,
                tokenProvider: {
                    KeychainHelper.shared.read(service: "com.wbshop.api", account: "authToken")
                }
            )
            ServiceLocator.shared.register(service: container.authService as AuthServicing)
            ServiceLocator.shared.register(service: container.userService as UserServicing)
            ServiceLocator.shared.register(service: container.cartService as CartServicing)
            ServiceLocator.shared.register(service: container.productService as ProductServicing)
            ServiceLocator.shared.register(service: container.categoryService as CategoryServicing)
            ServiceLocator.shared.register(service: container.searchService as SearchServicing)
        } catch {
            fatalError("Не удалось инициализировать BusinessLogicContainer: \(error)")
        }

        FontRegister.registerFonts()
    }

    var body: some Scene {
        WindowGroup {
            AppRootView()
        }
        .modelContainer(modelContainer)
    }

    private func setupApiToken() {
        let serviceName = "com.wbshop.api"
        let accountName = "authToken"

        if KeychainHelper.shared.read(service: serviceName, account: accountName) == nil {
            if let plistPath = Bundle.main.object(forInfoDictionaryKey: "APIToken") as? String,
               !plistPath.isEmpty {
                KeychainHelper.shared.save(plistPath, service: serviceName, account: accountName)
            }
        }
    }
}
