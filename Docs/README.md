# Сервисы

Для использования сервисов импортируй `BusinessLogic`. Model/ViewModel получает нужный сервис через его протокол; экземпляры создаются в `CompositionRoot`.

- [CatalogService](CatalogService.md) — категории и товары.
- [ProductService](ProductService.md) — карточка, избранное и отзывы.
- [CartService](CartService.md) — корзина и количество товаров.
- [OrderService](OrderService.md) — создание и список заказов.
- [AddressService](AddressService.md) — управление адресами.
- [ProfileService](ProfileService.md) — профиль, удаление аккаунта и выход.

Все методы — `async throws`. Состояние загрузки, обработка ошибок и защита от повторных нажатий находятся в Model/ViewModel экрана.
