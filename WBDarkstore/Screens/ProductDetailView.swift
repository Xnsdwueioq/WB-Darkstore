//
//  ProductDetailView.swift
//  WBDarkstore
//
//  Created by Полина Гельман on 12.09.2026.
//

import SwiftUI
import BusinessLogic

struct ProductDetailView: View {
    let product: ProductDetails
    let onDismiss: () -> Void
    @State private var showReviews = false
    let onReviewAdded: () -> Void

    var body: some View {
        ZStack(alignment: .topTrailing) {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Group {
                        if let imageUrl = product.imageURL {
                            AsyncImage(url: imageUrl) { phase in
                                switch phase {
                                case .empty:
                                    ProgressView()
                                case .success(let image):
                                    image.resizable().clipped()
                                case .failure:
                                    Image(systemName: "photo")
                                        .font(.largeTitle)
                                        .foregroundColor(.gray)
                                @unknown default:
                                    EmptyView()
                                }
                            }
                        } else {
                            Image(systemName: "photo")
                                .font(.largeTitle)
                                .foregroundColor(.gray)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 440)
                    .background(Color(.systemGray6))
                    .clipped()
                    .cornerRadius(16)

                    VStack(alignment: .leading, spacing: 6) {
                        priceView

                        HStack {
                            Text(product.name)
                                .font(.title3.bold())

                            Text("\(Int(product.weight)) г")
                                .font(.title3)
                                .foregroundStyle(.secondary)
                        }

                        HStack(alignment: .center, spacing: 6) {
                            unsafe Text(String(format: "%.1f", product.rating))
                                .font(.body)

                            RatingStarsView(rating: Double(product.rating))

                            Button {
                                showReviews = true
                            } label: {
                                HStack(spacing: 4) {
                                    Image(systemName: "text.bubble")
                                    Text("\(product.reviews.count) \(reviewsWord(product.reviews.count))")
                                    Image(systemName: "chevron.right")
                                }
                                .font(.body)
                                .foregroundStyle(.primary)
                            }
                            .buttonStyle(.plain)
                        }

                        Text(product.description)
                            .font(.body)
                            .padding(.top, 12)
                    }
                    .padding(.horizontal, 16)

                    Spacer()
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
        .sheet(isPresented: $showReviews) {
            ReviewsView(
                productID: product.id,
                reviews: product.reviews,
                onReviewAdded: {
                    showReviews = false
                    onReviewAdded()
                },
                onDismiss: { showReviews = false }
            )
        }
    }

    @ViewBuilder
    private var priceView: some View {
        if let discount = product.discount, discount > 0 {
            let discountedPrice = Int(Double(product.price) * (1 - discount / 100))
            HStack(spacing: 8) {
                Text("\(discountedPrice) ₽")
                    .font(.largeTitle.bold())
                Text("\(product.price) ₽")
                    .font(.body)
                    .strikethrough()
                    .foregroundStyle(.secondary)
            }
        } else {
            Text("\(product.price) ₽")
                .font(.largeTitle.bold())
        }
    }
}
