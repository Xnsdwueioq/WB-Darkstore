//
//  WBDarkstoreApp.swift
//  WBDarkstore
//
//  Created by Valeriy Solovey on 04.09.2026.
//

import SwiftUI
import BusinessLogic

@main
struct WBDarkstoreApp: App {
    @State private var catalogModel: CatalogModel
    @State private var cartModel: CartModel
    @State private var orderModel: OrderModel
    init() {
        guard let token = ProcessInfo.processInfo.environment["BEARER_TOKEN"] else {
            fatalError("BEARER_TOKEN is missing")
        }
        let compositionRoot: CompositionRoot
        do {
            compositionRoot = try CompositionRoot(token: token)
        } catch {
            fatalError("Не получилось создать CompositionRoot: \(error)")
        }
        catalogModel = CatalogModel(catalogService: compositionRoot.catalogService)
        cartModel = CartModel(cartService: compositionRoot.cartService)
        orderModel = OrderModel(orderService: compositionRoot.orderService)
    }
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(catalogModel)
                .environment(cartModel)
                .environment(orderModel)
        }
    }
}
