//
//  ProductCardView.swift
//  WBDarkstore
//
//  Created by Полина Гельман on 12.09.2026.
//

import SwiftUI
import BusinessLogic

struct ProductCardView: View {
    let product: Product
    var width: CGFloat = 174
    let quantity: Int
    let onAdd: () -> Void
    let onRemove: () -> Void

    private var imageHeight: CGFloat { width }
    private var totalPrice: Int { product.price * max(quantity, 1) }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Group {
                if let url = product.imageURL {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                        case .success(let image):
                            image.resizable().scaledToFill()
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
            .frame(width: width, height: imageHeight)
            .background(Color(.systemGray6))
            .clipped()
            .cornerRadius(12)

            HStack {
                Text(product.name)
                    .font(.footnote)
                    .lineLimit(2)
                    .frame(height: 32, alignment: .topLeading)

                Text("\(Int(product.weight)) г")
                    .font(.footnote)
                    .foregroundColor(.secondary)
                    .frame(height: 32, alignment: .topLeading)
            }

            HStack {
                if quantity > 0 {
                    HStack(spacing: 8) {
                        Button(action: onRemove) {
                            Image(systemName: "minus")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.white)
                        }

                        Text("\(totalPrice) ₽")
                            .font(.footnote.bold())
                            .foregroundColor(.white)
                            .lineLimit(1)

                        Button(action: onAdd) {
                            Image(systemName: "plus")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.white)
                        }
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color.purple)
                    .cornerRadius(10)
                    .transition(.scale.combined(with: .opacity))
                } else {
                    Button(action: onAdd) {
                        HStack {
                            Text("\(product.price) ₽")
                            Image(systemName: "plus")
                        }
                        .font(.footnote.bold())
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color(.systemGray5))
                        .cornerRadius(10)
                    }
                    .buttonStyle(.plain)
                    .transition(.scale.combined(with: .opacity))
                }
            }
            .animation(.spring(response: 0.3, dampingFraction: 0.75), value: quantity)
        }
        .frame(width: width)
        .contentShape(Rectangle())
    }
}
