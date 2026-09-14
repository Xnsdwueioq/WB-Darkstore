import Foundation
import NetworkPackage

enum AddressMapper {
    static func mapAddress(_ dto: AddressDTO) -> Address {
        Address(
            coordinates: dto.coordinates,
            addressLine: dto.addressLine,
            floor: dto.floor,
            entrance: dto.entrance,
            intercomCode: dto.intercomCode,
            comment: dto.comment
        )
    }

    static func mapIdentifiedAddress(_ dto: IdentifiedAddressDTO) -> IdentifiableAddress {
        IdentifiableAddress(
            id: dto.id,
            address: mapAddress(dto.address)
        )
    }

    static func mapIdentifiedAddresses(_ dtos: [IdentifiedAddressDTO]) -> [IdentifiableAddress] {
        dtos.map(mapIdentifiedAddress)
    }

    static func toDTO(_ model: Address) -> AddressDTO {
        AddressDTO(
            addressLine: model.addressLine,
            coordinates: model.coordinates,
            floor: model.floor,
            entrance: model.entrance,
            intercomCode: model.intercomCode,
            comment: model.comment
        )
    }
}
