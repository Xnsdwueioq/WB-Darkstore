//
//  AddReviewView.swift
//  WBDarkstore
//
//  Created by Полина Гельман on 12.09.2026.
//

import SwiftUI
import BusinessLogic
import Core

struct AddReviewView: View {
    let productID: String
    let onReviewAdded: () -> Void
    let onDismiss: () -> Void

    @Injected private var productService: ProductServiceProtocol

    @State private var rating: Int = 0
    @State private var comment: String = ""
    @State private var isSubmitting = false
    @State private var errorMessage: String?
    @State private var isSuccessPresented = false

    var body: some View {
        ZStack(alignment: .topTrailing) {
            VStack(alignment: .leading, spacing: 16) {
                Text("Отзыв о товаре")
                    .font(.title2.bold())
                    .padding(.top, 16)

                VStack(alignment: .leading, spacing: 6) {
                    Text("Оценка")
                        .font(.body)

                    HStack(spacing: 8) {
                        ForEach(1...5, id: \.self) { star in
                            Image(systemName: star <= rating ? "star.fill" : "star")
                                .font(.title2)
                                .foregroundColor(star <= rating ? .orange : Color(.systemGray4))
                                .onTapGesture { rating = star }
                        }
                    }
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text("Комментарий")
                        .font(.body)

                    TextEditor(text: $comment)
                        .frame(minHeight: 120)
                        .padding(8)
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                }

                Spacer()

                Button {
                    Task { await submitReview() }
                } label: {
                    Text(isSubmitting ? "Отправка..." : "Оставить отзыв")
                        .font(.body.bold())
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(rating == 0 ? Color(.systemGray4) : Color.purple)
                        .foregroundColor(.white)
                        .cornerRadius(14)
                }
                .disabled(rating == 0 || isSubmitting)
            }
            .padding(.horizontal, 16)

            Button(action: onDismiss) {
                Image(systemName: "xmark")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
                    .padding(10)
                    .background(.black.opacity(0.4), in: Circle())
            }
            .padding(12)
        }
        .fullScreenCover(isPresented: $isSuccessPresented) {
            VStack(spacing: 16) {
                Text("Отзыв отправлен")
                    .font(.title.bold())
                Text("Спасибо! Скоро мы его опубликуем")
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
                Button("Закрыть") {
                    isSuccessPresented = false
                    onReviewAdded()
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
        }
        .alert("Ошибка", isPresented: .constant(errorMessage != nil), actions: {
            Button("ОК") { errorMessage = nil }
        }, message: {
            Text(errorMessage ?? "")
        })
    }

    private func submitReview() async {
        isSubmitting = true
        defer { isSubmitting = false }

        do {
            let review = NewReview(rating: rating, content: comment, images: [])
            try await productService.submitReview(productID: productID, review: review)
            isSuccessPresented = true
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
