import SwiftUI

public struct DSReviewsRatingSummary: View {
    private let ratings: [Int]

    public init(ratings: [Int]) {
        self.ratings = ratings.filter { (1...5).contains($0) }
    }

    private var averageRating: Double {
        guard !ratings.isEmpty else { return 0 }
        return Double(ratings.reduce(0, +)) / Double(ratings.count)
    }

    private var formattedRating: String {
        String(format: "%.1f", averageRating)
    }

    private var counts: [Int: Int] {
        Dictionary(grouping: ratings, by: { $0 })
            .mapValues(\.count)
    }

    private var largestCount: Int {
        counts.values.max() ?? 0
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: DSSpacing.lg) {
            HStack(spacing: DSSpacing.sm) {
                Text("Отзывы")
                    .foregroundStyle(DSColors.black)

                Text("\(ratings.count)")
                    .foregroundStyle(DSColors.secondary)

                Spacer(minLength: 0)
            }
            .font(DSTypography.headline)

            HStack(alignment: .center, spacing: DSSpacing.xs) {
                Text(formattedRating)
                    .font(DSTypography.reviewAvgRating)
                    .foregroundStyle(DSColors.black)
                    .minimumScaleFactor(0.7)
                    .lineLimit(1)
                    .accessibilityLabel("Средняя оценка \(formattedRating) из 5")

                VStack(spacing: DSSpacing.xs) {
                    ForEach((1...5).reversed(), id: \.self) { stars in
                        distributionRow(stars: stars)
                    }
                }
                .frame(maxWidth: .infinity)

                Spacer(minLength: 0)
            }
        }
    }

    private func distributionRow(stars: Int) -> some View {
        let count = counts[stars, default: 0]

        return HStack(spacing: DSSpacing.xs) {
            HStack(spacing: 2) {
                ForEach(0..<stars, id: \.self) { _ in
                    Image("ReviewRatingStar", bundle: .module)
                        .renderingMode(.template)
                        .resizable()
                        .frame(width: 12, height: 12)
                        .foregroundStyle(count > 0 ? DSColors.black : DSColors.reviewRatingMuted)
                }
            }
            .frame(width: 68, alignment: .trailing)
            .accessibilityHidden(true)

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(DSColors.reviewRatingTrack)

                    Rectangle()
                        .fill(DSColors.black)
                        .frame(
                            width: largestCount > 0 ? geometry.size.width * CGFloat(count) / CGFloat(largestCount) : 0
                        )
                }
                .frame(height: 2)
                .frame(maxHeight: .infinity)
            }
            .frame(height: 12)
            .accessibilityHidden(true)

            Text("\(count)")
                .font(DSTypography.caption)
                .foregroundStyle(count > 0 ? DSColors.black : DSColors.reviewRatingMuted)
                .frame(width: 20, alignment: .leading)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(stars) звёзд: \(count)")
    }
}

#if DEBUG

#Preview("Один отзыв") {
    DSReviewsRatingSummary(ratings: [5])
        .padding()
}

#Preview("Несколько отзывов") {
    DSReviewsRatingSummary(ratings: [5, 5, 5, 4, 4, 1])
        .padding()
}

#endif
