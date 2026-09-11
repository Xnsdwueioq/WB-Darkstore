//
//  CheckoutBarView.swift
//  WBDarkstore
//
//  Created by Полина Гельман on 12.09.2026.
//
import SwiftUI

struct CheckoutBarView: View {
    let totalItems: Int
    let totalPrice: Int
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Text("Оформить")
                    .font(.headline)
                Spacer()
                Text("\(totalItems) шт · \(totalPrice) ₽")
                    .font(.subheadline.bold())
            }
            .foregroundColor(.white)
            .padding(.horizontal, 20)
            .padding(.vertical, 14)
            .background(Color.purple)
            .cornerRadius(14)
        }
    }
}
