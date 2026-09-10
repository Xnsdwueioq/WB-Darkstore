# CatalogService

Категории и список товаров.

```swift
public protocol CatalogServiceProtocol {
    func getCategories() async throws -> [Category]
    func getProducts(
        categoryID: String?,
        page: Int?,
        pageSize: Int?
    ) async throws -> ProductList
}
```

| Метод | Результат |
| --- | --- |
| `getCategories()` | Все категории: `[Category]` |
| `getProducts(categoryID:page:pageSize:)` | Страница товаров: `ProductList` |

`ProductList`: `currentPage`, `totalPages`, `products: [Product]`.

Для всех товаров передай `categoryID: nil`. Параметры `page` и `pageSize` тоже принимают `nil`; для следующей страницы передай её номер явно.
