import Foundation

func reviewsWord(_ count: Int) -> String {
    let mod100 = count % 100
    let mod10 = count % 10
    if (11...14).contains(mod100) {
        return "отзывов"
    }
    switch mod10 {
    case 1: return "отзыв"
    case 2...4: return "отзыва"
    default: return "отзывов"
    }
}
