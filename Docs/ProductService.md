# ProductService

Карточка товара, избранное и отзывы.

```swift
public protocol ProductServiceProtocol: Sendable {
    func getProduct(id: String) async throws -> ProductDetails
    func setFavorite(_ isFavorite: Bool, productID: String) async throws
    func submitReview(productID: String, review: NewReview) async throws
}
```

| Метод | Результат |
| --- | --- |
| `getProduct(id:)` | `ProductDetails`, включая `reviews: [Review]` |
| `setFavorite(_:productID:)` | `true` — добавить в избранное, `false` — удалить; возвращает `Void` |
| `submitReview(productID:review:)` | Отправить отзыв; возвращает `Void` |

`NewReview`: `rating: Int` (1–5), `content: String`, `images: [URL]` — ссылки на уже загруженные изображения.

После отправки отзыва повторно вызови `getProduct(id:)`, чтобы обновить карточку и отзывы.
