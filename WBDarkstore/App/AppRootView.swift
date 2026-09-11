//
//  AppRootView.swift
//  WBDarkstore
//
//  Created by Полина Гельман on 11.09.2026.
//

import SwiftUI
import Core

struct AppRootView: View {
    @StateObject private var router: Router = ServiceLocator.shared.resolve()

    var body: some View {
        NavigationStack(path: $router.path) {
            ZStack {

            }
            .task {
                router.push(.content)
            }
            .animation(.easeInOut(duration: 0.35), value: router.isAuthenticated)
            .navigationDestination(for: Route.self) { route in
                switch route {
                case .login:
                    Text("")
                case .content:
                    ContentView()
                case .search:
                    Text("")
                case .category(id: _, name: _):
                    Text("")

                case .profile:
                    Text("")
                case .profileEdit:
                    Text("")
                }
            }
        }
    }
}

#Preview {
    AppRootView()
}
