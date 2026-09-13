//
//  RatingStarsView.swift
//  WBDarkstore
//
//  Created by Полина Гельман on 12.09.2026.
//

import SwiftUI

func reviewsWord(_ count: Int) -> String {
    let mod10 = count % 10
    let mod100 = count % 100
    if mod10 == 1 && mod100 != 11 {
        return "отзыв"
    } else if (2...4).contains(mod10) && !(12...14).contains(mod100) {
        return "отзыва"
    } else {
        return "отзывов"
    }
}

struct RatingStarsView: View {
    let rating: Double
    let maxRating: Int = 5
    var starSize: Font = .body

    var body: some View {
        HStack(spacing: 2) {
            ForEach(1...maxRating, id: \.self) { index in
                starImage(for: index)
                    .font(starSize)
            }
        }
    }

    private func starImage(for index: Int) -> Image {
        let difference = rating - Double(index - 1)
        if difference >= 1 {
            return Image(systemName: "star.fill")
        } else if difference >= 0.5 {
            return Image(systemName: "star.leadinghalf.filled")
        } else {
            return Image(systemName: "star")
        }
    }
}
