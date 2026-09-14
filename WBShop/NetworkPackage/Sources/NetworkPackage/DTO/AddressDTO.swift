import Foundation

public struct AddressDTO: Sendable, Hashable {
    public let addressLine: String
    public let coordinates: [Double]
    public let floor: String?
    public let entrance: String?
    public let intercomCode: String?
    public let comment: String?

    public init(
        addressLine: String,
        coordinates: [Double],
        floor: String? = nil,
        entrance: String? = nil,
        intercomCode: String? = nil,
        comment: String? = nil
    ) {
        self.addressLine = addressLine
        self.coordinates = coordinates
        self.floor = floor
        self.entrance = entrance
        self.intercomCode = intercomCode
        self.comment = comment
    }
}

public struct IdentifiedAddressDTO: Sendable, Hashable, Identifiable {
    public let id: String
    public let address: AddressDTO

    public init(id: String, address: AddressDTO) {
        self.id = id
        self.address = address
    }
}
