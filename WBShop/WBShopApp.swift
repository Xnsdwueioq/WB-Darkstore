//
//  WBShopApp.swift
//  WBShop
//
//  Created by Полина Гельман on 28.06.2026.
//

import SwiftUI
import Core
import DSKit
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
        
        ServiceLocator.shared.register(service: AuthService() as AuthServicing)
        ServiceLocator.shared.register(service: UserService() as UserServicing)
        ServiceLocator.shared.register(service: CartService(modelContainer: modelContainer) as CartServicing)
        ServiceLocator.shared.register(service: ProductService() as ProductServicing)
        ServiceLocator.shared.register(service: CategoryService() as CategoryServicing)
        ServiceLocator.shared.register(service: SearchService() as SearchServicing)
        setupApiToken()
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
