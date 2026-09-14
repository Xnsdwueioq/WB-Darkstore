import Foundation
import NetworkPackage

enum CartMapper {
    static func mapCartItem(_ dto: CartItemDTO) -> CartProduct {
        CartProduct(
            id: dto.id,
            image: dto.image,
            name: dto.name,
            weight: dto.weight,
            price: dto.price,
            quantity: dto.quantity,
            isAvailable: dto.isAvailable
        )
    }

    static func mapCartItems(_ dtos: [CartItemDTO]) -> [CartProduct] {
        dtos.map(mapCartItem)
    }
}
