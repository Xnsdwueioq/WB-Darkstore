//
//  ProductDetailContainerView 2.swift
//  WBDarkstore
//
//  Created by Полина Гельман on 12.09.2026.
//

import SwiftUI
import BusinessLogic
import Core

struct ProductDetailContainerView: View {
    let productID: String
    let onDismiss: () -> Void

    @Injected var productService: ProductServiceProtocol
    @State private var product: ProductDetails?
    @State private var errorMessage: String?

    var body: some View {
        Group {
            if let product {
                ProductDetailView(
                    product: product,
                    onDismiss: onDismiss,
                    onReviewAdded: { Task { await loadDetails() } } // ← новое
                )
            } else {
                ProgressView("Загрузка...")
            }
        }
        .task { await loadDetails() }
        .alert("Ошибка", isPresented: .constant(errorMessage != nil), actions: {
            Button("ОК") { errorMessage = nil; onDismiss() }
        }, message: { Text(errorMessage ?? "") })
    }

    private func loadDetails() async {
        do {
            product = try await productService.getProduct(id: productID)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
