//
//  WBDarkstoreApp.swift
//  WBDarkstore
//
//  Created by Valeriy Solovey on 04.09.2026.
//

import SwiftUI
import BusinessLogic
import Core

@main
struct WBDarkstoreApp: App {
//    @State private var catalogModel: any CatalogModelProtocol
    init() {
        guard let token = ProcessInfo.processInfo.environment["BEARER_TOKEN"] else {
            fatalError("BEARER_TOKEN is missing")
        }

        do {
            _ = try CompositionRoot(token: token)
        } catch {
            print(error)
        }

        // инициализация catalogModel из compositionRoot
    }

    var body: some Scene {
        WindowGroup {
            AppRootView()
        }
    }
}
