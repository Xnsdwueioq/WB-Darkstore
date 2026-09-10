# OrderService

Создание заказа и история заказов пользователя.

```swift
public protocol OrderServiceProtocol: Sendable {
    func createOrder(paymentMethod: String, addressID: String) async throws
    func getOrders() async throws -> [Order]
}
```

| Метод | Результат |
| --- | --- |
| `createOrder(paymentMethod:addressID:)` | Создать заказ из текущей корзины; возвращает `Void` |
| `getOrders()` | `[Order]` в серверном порядке |

`addressID` — `id` выбранного `SavedAddress`. Пока способ оплаты не используется, передавай `paymentMethod: ""`.

`Order`: `id`, `status` (`active` / `completed`), `deliveryDate: String?`, `address: Address`, суммы, `totalItems`, `items: [OrderItem]`.

После создания вызови `getOrders()`, чтобы получить обновлённый список. Для обновления корзины используй `CartService.getCart()`.
