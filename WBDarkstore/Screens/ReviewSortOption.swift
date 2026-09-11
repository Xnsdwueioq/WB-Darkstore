//
//  ReviewSortOption.swift
//  WBDarkstore
//
//  Created by Полина Гельман on 12.09.2026.
//

import SwiftUI
import BusinessLogic

enum ReviewSortOption: String, CaseIterable, Identifiable {
    case newest = "Сначала новые"
    case oldest = "Сначала старые"
    case highestRating = "С высоким рейтингом"
    case lowestRating = "С низким рейтингом"

    var id: String { rawValue }
}

struct ReviewsView: View {
    let productID: String
    let reviews: [Review]
    let onReviewAdded: () -> Void
    let onDismiss: () -> Void

    @State private var showAddReview = false
    @State private var selectedSortOption: ReviewSortOption = .newest

    private var averageRating: Double {
        guard !reviews.isEmpty else { return 0 }
        let total = reviews.reduce(0) { $0 + $1.rating }
        return Double(total) / Double(reviews.count)
    }

    private var sortedReviews: [Review] {
        switch selectedSortOption {
        case .newest:
            return reviews.sorted { $0.createdAt > $1.createdAt }
        case .oldest:
            return reviews.sorted { $0.createdAt < $1.createdAt }
        case .highestRating:
            return reviews.sorted { $0.rating > $1.rating }
        case .lowestRating:
            return reviews.sorted { $0.rating < $1.rating }
        }
    }

    var body: some View {
        ZStack(alignment: .topTrailing) {
            VStack(spacing: 16) {
                HStack {
                    Text("Отзывы")
                        .font(.headline)
                    Text("\(reviews.count)")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)

                ScrollView {
                    VStack(spacing: 12) {
                        HStack {
                            Text(String(format: "%.1f", averageRating))
                                .font(.largeTitle.bold())
                            Spacer()
                        }

                        Button {
                            showAddReview = true
                        } label: {
                            Text("Написать отзыв")
                                .font(.body.bold())
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(Color(.systemGray5))
                                .cornerRadius(12)
                        }

                        if reviews.count > 1 {
                            HStack {
                                Text("Сортировка:")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)

                                Menu {
                                    Picker("Сортировка", selection: $selectedSortOption) {
                                        ForEach(ReviewSortOption.allCases) { option in
                                            Text(option.rawValue).tag(option)
                                        }
                                    }
                                } label: {
                                    HStack(spacing: 4) {
                                        Text(selectedSortOption.rawValue)
                                            .font(.subheadline)
                                        Image(systemName: "chevron.down")
                                            .font(.caption)
                                    }
                                    .padding(.vertical, 6)
                                    .padding(.horizontal, 10)
                                    .background(Color(.systemGray6))
                                    .cornerRadius(8)
                                }
                                Spacer()
                            }
                            .padding(.vertical, 4)
                        }

                        ForEach(sortedReviews) { review in
                            ReviewView(review: review)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 16)
                }
            }

            Button(action: onDismiss) {
                Image(systemName: "xmark")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
                    .padding(10)
                    .background(.black.opacity(0.4), in: Circle())
            }
            .padding(12)
        }
        .sheet(isPresented: $showAddReview) {
            AddReviewView(productID: productID) {
                showAddReview = false
                onReviewAdded()
            } onDismiss: {
                showAddReview = false
            }
        }
    }
}

struct ReviewView: View {
    let review: Review

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                RatingStarsView(rating: Double(review.rating), starSize: .body)
                Text(review.author)
                    .font(.body)
                Text(", \(review.createdAt.formatted(.dateTime.day().month(.abbreviated).locale(Locale(identifier: "ru_RU"))))")
                    .font(.body)
                    .foregroundStyle(.secondary)
            }
            Text(review.content)
                .font(.body)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemGray6))
        .cornerRadius(16)
    }
}
