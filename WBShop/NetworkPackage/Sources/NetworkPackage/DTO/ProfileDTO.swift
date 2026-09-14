import Foundation

public struct UserProfileDTO: Sendable, Hashable {
    public let name: String
    public let phone: String
    public let birthday: String
    public let imageUrl: String?

    public init(
        name: String,
        phone: String,
        birthday: String,
        imageUrl: String? = nil
    ) {
        self.name = name
        self.phone = phone
        self.birthday = birthday
        self.imageUrl = imageUrl
    }
}
