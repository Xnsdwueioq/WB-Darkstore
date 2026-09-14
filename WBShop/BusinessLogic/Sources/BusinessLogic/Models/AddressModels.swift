import Foundation

public struct Address: Hashable, Sendable {
    public var coordinates: [Double]
    public var addressLine: String
    public var floor: String?
    public var entrance: String?
    public var intercomCode: String?
    public var comment: String?

    public init(
        coordinates: [Double],
        addressLine: String,
        floor: String? = nil,
        entrance: String? = nil,
        intercomCode: String? = nil,
        comment: String? = nil
    ) {
        self.coordinates = coordinates
        self.addressLine = addressLine
        self.floor = floor
        self.entrance = entrance
        self.intercomCode = intercomCode
        self.comment = comment
    }
}

public struct IdentifiableAddress: Identifiable, Hashable, Sendable {
    public let id: String
    public var address: Address

    public init(id: String, address: Address) {
        self.id = id
        self.address = address
    }
}
