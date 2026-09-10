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
        _catalogModel = State(initialValue: CatalogModel(catalogService: compositionRoot.catalogService))
        
    }
    
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(catalogModel)
        }
    }
}
