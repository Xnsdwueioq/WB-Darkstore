# AddressService

Список адресов, добавление, редактирование и удаление.

```swift
public protocol AddressServiceProtocol: Sendable {
    func getAddresses() async throws -> [SavedAddress]
    func addAddress(_ address: Address) async throws
    func updateAddress(addressID: String, address: Address) async throws
    func deleteAddress(addressID: String) async throws
}
```

| Метод | Результат |
| --- | --- |
| `getAddresses()` | `[SavedAddress]` |
| `addAddress(_:)` | Сохранить новый адрес; возвращает `Void` |
| `updateAddress(addressID:address:)` | Обновить адрес по ID; возвращает `Void` |
| `deleteAddress(addressID:)` | Удалить адрес по ID; возвращает `Void` |

`SavedAddress`: `id: String` и `address: Address`. Используй `id` для изменения, удаления и оформления заказа.

`Address`: `coordinates: AddressCoordinates`, `addressLine: String`, необязательные `floor`, `entrance`, `intercomCode`, `comment` (все `String?`).

`AddressCoordinates` содержит `longitude` и `latitude`. При создании или редактировании передавай `Address` без ID. После изменения повторно вызови `getAddresses()`, чтобы обновить список и получить ID нового адреса.
