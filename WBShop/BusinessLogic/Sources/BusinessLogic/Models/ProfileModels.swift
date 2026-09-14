import Foundation

public struct User: Hashable, Sendable {
    public var name: String
    public var phone: String
    public var birthday: String
    public var imageUrl: String?

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
