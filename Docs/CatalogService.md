# Catalog и Product: API и сервисы

```text
UI / Model
    ↓
CatalogService или ProductService       BusinessLogic
    ↓
CatalogAPI или ProductAPI               NetworkPackage
    ↓
APIClient → OpenAPI Client → backend
```

UI работает только с сервисами и domain-моделями. DTO и API остаются внутри сетевого и бизнес-слоёв.

## CatalogService

Категории и список товаров:

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
| `getCategories()` | Все категории |
| `getProducts(...)` | Страница товаров, при необходимости отфильтрованная по категории |

`ProductList` содержит `currentPage`, `totalPages` и `[Product]`. `Product` — краткая модель для карточки в каталоге.

## CatalogAPI

```swift
public protocol CatalogAPIProtocol: Sendable {
    func fetchCategories() async throws -> [CategoryDTO]

    func fetchProducts(
        categoryID: String?,
        page: Int?,
        pageSize: Int?
    ) async throws -> ProductListDTO
}
```

| Метод | Endpoint |
| --- | --- |
| `fetchCategories()` | `GET /categories` |
| `fetchProducts(...)` | `GET /products` |

## ProductService

Детальная карточка, избранное и отправка отзыва:

```swift
public protocol ProductServiceProtocol: Sendable {
    func getProduct(id: String) async throws -> ProductDetails
    func setFavorite(_ isFavorite: Bool, productID: String) async throws
    func submitReview(productID: String, review: NewReview) async throws
}
```

| Метод | Назначение |
| --- | --- |
| `getProduct(id:)` | Возвращает полную карточку вместе с `[Review]` |
| `setFavorite(true, productID:)` | Добавляет товар в избранное |
| `setFavorite(false, productID:)` | Удаляет товар из избранного |
| `submitReview(productID:review:)` | Отправляет новый отзыв |

После успешной отправки отзыва endpoint не возвращает созданный объект. Для обновления автора, даты, рейтинга и списка отзывов нужно повторно вызвать `getProduct(id:)`.

## ProductAPI

```swift
public protocol ProductAPIProtocol: Sendable {
    func fetchProduct(id: String) async throws -> ProductDetailsDTO
    func addToFavorites(productID: String) async throws
    func removeFromFavorites(productID: String) async throws
    func submitReview(productID: String, review: NewReviewDTO) async throws
}
```

| Метод | Endpoint |
| --- | --- |
| `fetchProduct(id:)` | `GET /products/{id}` |
| `addToFavorites(productID:)` | `POST /products/{id}/favourite` |
| `removeFromFavorites(productID:)` | `DELETE /products/{id}/favourite` |
| `submitReview(productID:review:)` | `POST /products/{id}/reviews` |

`ProductService.setFavorite` сам выбирает `addToFavorites` или `removeFromFavorites`. UI не должен вызывать `ProductAPI` напрямую.

## Domain-модели

| Модель | Использование |
| --- | --- |
| `Category` | Категория каталога |
| `Product` | Краткая карточка товара в списке |
| `ProductList` | Страница товаров и данные пагинации |
| `ProductDetails` | Полная карточка, описание и отзывы |
| `Review` | Полученный отзыв |
| `NewReview` | Данные для отправки нового отзыва |

## Dependency Injection

В `CompositionRoot` уже создаются оба сервиса:

```swift
let apiClient = try APIClient(token: token)

let catalogAPI = CatalogAPI(apiClient: apiClient)
catalogService = CatalogService(api: catalogAPI)

let productAPI = ProductAPI(apiClient: apiClient)
productService = ProductService(productAPI: productAPI)
```

Следующий слой должен зависеть от `CatalogServiceProtocol` и `ProductServiceProtocol`, а не от API или DTO.