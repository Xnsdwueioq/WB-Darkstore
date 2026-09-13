import Foundation

func pluralSuffix(_ count: Int) -> String {
    let remainder10 = count % 10
    let remainder100 = count % 100
    if remainder100 >= 11 && remainder100 <= 14 { return "ов" }
    switch remainder10 {
    case 1: return ""
    case 2, 3, 4: return "а"
    default: return "ов"
    }
}
