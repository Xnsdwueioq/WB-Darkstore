import Foundation
import SwiftUI

public extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(of: "#", with: "")
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r = Double((int >> 16) & 0xFF) / 255
        let g = Double((int >> 8) & 0xFF) / 255
        let b = Double(int & 0xFF) / 255
        self.init(red: r, green: g, blue: b)
    }
}

public extension LinearGradient {
    static let figmaPurplePink = LinearGradient(
        gradient: Gradient(stops: [
            .init(color: Color(hex: "ED3CCA"), location: 0.0049),
            .init(color: Color(hex: "DF34D2"), location: 0.1488),
            .init(color: Color(hex: "D02BD9"), location: 0.2927),
            .init(color: Color(hex: "BF22E1"), location: 0.4314),
            .init(color: Color(hex: "AE1AE8"), location: 0.5702),
            .init(color: Color(hex: "9A10F0"), location: 0.7089),
            .init(color: Color(hex: "8306F7"), location: 0.8476),
            .init(color: Color(hex: "6600FF"), location: 0.9915)
        ]),
        startPoint: UnitPoint(x: 0.004, y: 0.437),
        endPoint: UnitPoint(x: 0.996, y: 0.563)
    )

    static let figmaLightPinkPurple = LinearGradient(
        gradient: Gradient(stops: [
            .init(color: Color(hex: "FEF1FB"), location: 0.0049),
            .init(color: Color(hex: "FDF1FC"), location: 0.1488),
            .init(color: Color(hex: "FCF0FC"), location: 0.2927),
            .init(color: Color(hex: "FBF0FD"), location: 0.4314),
            .init(color: Color(hex: "F9EFFD"), location: 0.5702),
            .init(color: Color(hex: "F8EEFE"), location: 0.7089),
            .init(color: Color(hex: "F6EEFE"), location: 0.8476),
            .init(color: Color(hex: "F4EDFF"), location: 0.9915)
        ]),
        startPoint: UnitPoint(x: 0.004, y: 0.437),
        endPoint: UnitPoint(x: 0.996, y: 0.563)
    )

    static let figmaSubtlePinkPurple = LinearGradient(
        gradient: Gradient(stops: [
            .init(color: Color(hex: "FEF1FB"), location: 0.0049),
            .init(color: Color(hex: "FDF1FC"), location: 0.1488),
            .init(color: Color(hex: "FCF0FC"), location: 0.2927),
            .init(color: Color(hex: "FBF0FD"), location: 0.4314),
            .init(color: Color(hex: "F9EFFD"), location: 0.5702),
            .init(color: Color(hex: "F8EEFE"), location: 0.7089),
            .init(color: Color(hex: "F6EEFE"), location: 0.8476),
            .init(color: Color(hex: "FFFFFF"), location: 0.9915)
        ]),
        startPoint: .top,
        endPoint: .bottom
    )
}

public enum DSColors {
    public static let primary = Color.purple
    public static let secondary = Color.gray
    #if canImport(UIKit)
    public static let background = Color(uiColor: .systemBackground)
    #else
    public static let background = Color(nsColor: .windowBackgroundColor)
    #endif
    public static let surface = Color.white
    public static let border = Color.gray.opacity(0.1)
    public static let destructive = Color.red
    public static let disabled = Color.gray.opacity(0.4)
    public static let black = Color.black
    public static let blue = Color.blue
    public static let white = Color.white
    public static let lightPurple = Color.purple.opacity(0.1)
    public static let smoky = Color(hex: "F6F6FA")
    public static let reviewRatingTrack = Color(hex: "F0ECF4")
    public static let reviewRatingMuted = Color(hex: "9797AF")
    public static let favoriteActive = Color(hex: "E313BF")
    public static let favoriteInactive = Color(hex: "B9B9B8")
}

public enum DSSpacing {
    public static let xs: CGFloat = 4
    public static let sm: CGFloat = 8
    public static let smMd: CGFloat = 10
    public static let md: CGFloat = 12
    public static let lg: CGFloat = 16
    public static let xl: CGFloat = 20
    public static let xxl: CGFloat = 24
    public static let cartTitleSpacingList: CGFloat = 20
}

public enum DSRadius {
    public static let sm: CGFloat = 6
    public static let md: CGFloat = 8
    public static let lg: CGFloat = 12
    public static let xl: CGFloat = 16
    public static let sheet: CGFloat = 20
}

public enum DSTypography {
    public static let display = Font.custom("Inter", size: 32).weight(.medium)
    public static let success = Font.custom("Inter", size: 56).weight(.semibold)
    public static let title = Font.custom("Inter", size: 26).weight(.semibold)
    public static let headline = Font.custom("Inter", size: 24).weight(.bold)
    public static let body = Font.custom("Inter", size: 16)
    public static let bodyBold = Font.custom("Inter", size: 16).weight(.semibold)
    public static let priceBold = Font.custom("Inter", size: 17).weight(.bold)
    public static let order = Font.custom("Inter", size: 20).weight(.semibold)
    public static let button = Font.custom("Inter", size: 14).weight(.semibold)
    public static let caption = Font.custom("Inter", size: 14)
    public static let reviewAvgRating = Font.custom("Inter", size: 94)
}
