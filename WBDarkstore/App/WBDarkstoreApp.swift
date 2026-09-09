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
//    @State private var catalogModel: any CatalogModelProtocol

    init() {
        guard let token = ProcessInfo.processInfo.environment["BEARER_TOKEN"] else {
            fatalError("BEARER_TOKEN is missing")
        }

//        let compositionRoot = try! CompositionRoot(token: token)

        // инициализация catalogModel из compositionRoot
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
