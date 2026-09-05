# CatalogService и CatalogAPI
Каталог состоит из двух публичных слоёв:
```text
UI / CatalogModel
        ↓
CatalogServiceProtocol / CatalogService        BusinessLogic
        ↓
CatalogAPIProtocol / CatalogAPI                NetworkPackage
        ↓
APIClient → сгенерированный OpenAPI Client → backend
```
- `CatalogAPI` выполняет HTTP-запросы, разбирает ответы OpenAPI-клиента и возвращает DTO.
- `CatalogService` преобразует DTO в доменные модели, с которыми работают модель экрана и UI.
- UI не должен импортировать `NetworkPackage` и работать с DTO напрямую.

Отдельные `CategoriesAPI` и `ProductListAPI` сейчас не создаются: оба endpoint относятся к каталогу и собраны в одном `CatalogAPI`.
## CatalogServiceProtocol
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

Модель `Product` содержит:
| Поле | Тип |
| --- | --- |
| `id` | `String` |
| `name` | `String` |
| `imageURL` | `URL?` |
| `weight` | `Double` |
| `price` | `Int` |
| `rating` | `Float` |
| `reviewCount` | `Int` |
| `isFavorite` | `Bool` |
| `discount` | `Double?` |
`Product` описывает элемент списка. Полная карточка товара из `GET /products/{id}` пока не реализована.
## CatalogAPIProtocol
`CatalogAPIProtocol` предоставляет два метода:
```swift
func fetchCategories() async throws -> [CategoryDTO]

func fetchProducts(
    categoryID: String?,
    page: Int?,
    pageSize: Int?
) async throws -> ProductListDTO
```
`CatalogAPI` вызывает методы сгенерированного клиента:
- `getCategories` для `GET /categories`;
- `getProducts` для `GET /products`.
Сгенерированные OpenAPI-типы остаются внутренней деталью `NetworkPackage`. Наружу возвращаются стабильные DTO проекта: `CategoryDTO`, `ProductPreviewDTO` и `ProductListDTO`.

## APIError
Методы пробрасывают transport/decoding errors без изменения. Ответы backend преобразуются в `APIError`:
```swift
public enum APIError: Error, Sendable {
    case badRequest(message: String)
    case unauthorized(message: String)
    case server(statusCode: Int, message: String)
}
```
- `400` → `.badRequest`;
- `401` → `.unauthorized`;
- остальные документированные ошибки → `.server` с HTTP-кодом.
Интерпретация ошибки для пользователя должна выполняться выше — например, в `CatalogModel`. `CatalogService` не скрывает и не заменяет ошибки API.

## DI
Рабочая цепочка создаётся в `CompositionRoot`:
```swift
let apiClient = try APIClient(token: token)
let catalogAPI = CatalogAPI(apiClient: apiClient)
let catalogService = CatalogService(api: catalogAPI)
```
`APIClient` добавляет bearer token через `BearerTokenMiddleware`. Для запуска приложения и интеграционного теста требуется переменная окружения `BEARER_TOKEN`.

## Что использовать следующему слою
`CatalogModel` должен зависеть от `CatalogServiceProtocol`, а не от конкретного `CatalogService` или `CatalogAPIProtocol`.
Минимальный сценарий загрузки товаров категории:
```swift
let result = try await catalogService.getProducts(
    categoryID: category.id,
    page: 1,
    pageSize: 20
)

products = result.products
currentPage = result.currentPage
totalPages = result.totalPages
```
Для следующей страницы нужно увеличить `page`, повторить запрос и добавить `result.products` к уже загруженному массиву.
