import Foundation
import NetworkPackage

enum OrderMapper {
    static func mapOrderItem(_ dto: OrderItemDTO) -> OrderItem {
        OrderItem(
            id: dto.id,
            image: dto.image,
            name: dto.name,
            weight: dto.weight,
            price: dto.price,
            quantity: dto.quantity
        )
    }

    static func mapOrder(_ dto: OrderDTO) -> Order {
        let status = OrderStatus(rawValue: dto.status) ?? .active
        let address = AddressMapper.mapAddress(dto.address)
        let items = dto.items.map(mapOrderItem)

        return Order(
            id: dto.id,
            status: status,
            deliveryDate: dto.deliveryDate,
            address: address,
            orderPrice: dto.orderPrice,
            deliveryPrice: dto.deliveryPrice,
            totalPrice: dto.totalPrice,
            totalItems: dto.totalItems,
            items: items
        )
    }

    static func mapOrders(_ dtos: [OrderDTO]) -> [Order] {
        dtos.map(mapOrder)
    }
}
