# CartService

Содержимое корзины, добавление и удаление товаров.

```swift
public protocol CartServiceProtocol: Sendable {
    func getCart() async throws -> Cart

    func addToCart(productID: String) async throws -> Int

    func removeFromCart(productID: String) async throws -> Int
}
```

| Метод | Результат |
| --- | --- |
| `getCart()` | `Cart` с товарами и итоговыми суммами |
| `addToCart(productID:)` | Новое общее количество товаров в корзине: `Int` |
| `removeFromCart(productID:)` | Новое общее количество товаров в корзине: `Int` |

`Cart`: `deliveryTime` (минуты), `orderPrice`, `deliveryPrice`, `totalPrice`, `totalItems`, `items: [CartItem]`.

У `CartItem` есть `quantity` и `available`. Возвращаемый счётчик относится ко всей корзине. Для обновления списка и сумм после изменения вызови `getCart()`.
