import SwiftUI

public struct DSRatingLabel: View {
    private let rating: Double

    public init(rating: Double) {
        self.rating = rating
    }

    private var formattedRating: String {
        String(format: "%.1f", rating)
    }

    public var body: some View {
        HStack(spacing: 2) {
            Image("ReviewRatingStar", bundle: .module)
                .resizable()
                .frame(width: 11, height: 11)
                .accessibilityHidden(true)

            Text(formattedRating)
                .font(DSTypography.caption)
                .foregroundStyle(DSColors.black)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Рейтинг \(formattedRating) из 5")
    }
}
