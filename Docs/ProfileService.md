# ProfileService

Получение и изменение профиля, удаление аккаунта и выход из системы.

```swift
public protocol ProfileServiceProtocol: Sendable {
    func getProfile() async throws -> Profile
    func updateProfile(with newProfile: NewProfile) async throws
    func deleteProfile() async throws
    func logout() async throws
}
```

| Метод | Результат |
| --- | --- |
| `getProfile()` | Текущий `Profile` |
| `updateProfile(with:)` | Обновить имя, дату рождения и изображение; возвращает `Void` |
| `deleteProfile()` | Сбросить аккаунт к настройкам по умолчанию; возвращает `Void` |
| `logout()` | Завершить текущую сессию; возвращает `Void` |

`Profile`: `name: String`, `phone: String`, `birthday: String`, `imageURL: URL?`.

`NewProfile`: `name: String`, `birthday: String`, `imageURL: URL`. Изображение обязательно передаётся в формате JXL. Телефон доступен только в полученном `Profile` и через этот сервис не изменяется.

После обновления повторно вызови `getProfile()`, чтобы получить актуальные серверные данные. После `logout()` или `deleteProfile()` очисти локальное состояние авторизации и покажи экран входа.
