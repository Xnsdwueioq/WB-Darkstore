//
//  CheckoutFloatingButton.swift
//  WBShop
//
//  Created by Полина Гельман on 13.09.2026.
//
import SwiftUI
import DSKit

struct CheckoutFloatingButton: View {
    let totalPrice: Int
    let itemsCount: Int
    let action: () -> Void
    var fillWidth: Bool = false

    init(totalPrice: Int, itemsCount: Int, fillWidth: Bool, action: @escaping () -> Void) {
        self.totalPrice = totalPrice
        self.itemsCount = itemsCount
        self.action = action
        self.fillWidth = fillWidth

    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 0) {
                    DSPriceText(Double(totalPrice), font: DSTypography.priceBold)
                        .foregroundColor(.white)
                    Text("\(itemsCount) товар\(pluralSuffix(itemsCount))")
                        .font(DSTypography.caption)
                        .foregroundColor(.white.opacity(0.85))
                }

                if fillWidth {
                    Spacer()
                }

                Text("Оформить")
                    .font(DSTypography.order)
                    .foregroundColor(.white)
                    .lineLimit(1)
                    .padding(.trailing, DSSpacing.md)
            }
            .padding(.horizontal, DSSpacing.sm)
            .padding(.vertical, DSSpacing.sm)
            .background(LinearGradient.figmaPurplePink)
            .clipShape(
                RoundedRectangle(cornerRadius: DSRadius.lg, style: .continuous)
            )
        }
        .buttonStyle(.plain)
    }
}
