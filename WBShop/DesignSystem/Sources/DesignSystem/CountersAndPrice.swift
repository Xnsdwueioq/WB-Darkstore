import Foundation
import SwiftUI

public struct DSCounterView: View {
    let count: Int
    let onIncrement: () -> Void
    let onDecrement: () -> Void

    public init(count: Int, onIncrement: @escaping () -> Void, onDecrement: @escaping () -> Void) {
        self.count = count
        self.onIncrement = onIncrement
        self.onDecrement = onDecrement
    }

    public var body: some View {
        HStack(spacing: DSSpacing.lg) {
            Button(action: onDecrement) {
                Image(systemName: "minus")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.black)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            Text("\(count)")
                .font(DSTypography.body)
                .frame(minWidth: 20)
                .multilineTextAlignment(.center)

            Button(action: onIncrement) {
                Image(systemName: "plus")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.black)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, DSSpacing.md)
        .padding(.vertical, DSSpacing.sm)
        #if canImport(UIKit)
        .background(Color(uiColor: .systemGroupedBackground))
        #else
        .background(Color(nsColor: .windowBackgroundColor))
        #endif
        .cornerRadius(DSRadius.md)
    }
}

private extension NumberFormatter {
    static let price: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.usesGroupingSeparator = false
        return formatter
    }()
}

public struct DSPriceText: View {
    let value: Double
    let font: Font

    public init(_ value: Double, font: Font = DSTypography.display) {
        self.value = value
        self.font = font
    }

    public var body: some View {
        Text(formattedPrice)
            .font(font)
    }

    private var formattedPrice: String {
        let string = NumberFormatter.price.string(from: NSNumber(value: value)) ?? "\(Int(value))"
        return "\(string) ₽"
    }
}
