# WB Darkstore

![iOS](https://img.shields.io/badge/iOS-18.0%2B-black)
![Swift](https://img.shields.io/badge/Swift-6-orange)
![SwiftUI](https://img.shields.io/badge/UI-SwiftUI-blue)
![Architecture](https://img.shields.io/badge/Architecture-MV%20%2B%20Service-informational)

iOS dark store delivery app built as a team project.

## Tech Stack

- iOS 18.0+
- Swift 6
- SwiftUI
- Swift Concurrency
- Swift Package Manager
- Swift OpenAPI Generator
- MapKit
- Swift Testing
- XCTest

## Architecture

- MV + Service
- Modular architecture with SPM
## Запуск (Настройка токена)
### Шаг 1: Создайте файл конфигурации

В терминале в корневой папке проекта выполните команду, чтобы создать локальный конфиг из шаблона:

```bash
cp WBShop/Config.xcconfig.template WBShop/Config.xcconfig
```

### Шаг 2: Впишите свой токен

Откройте `WBShop/Config.xcconfig` и укажите значение токена:

```
API_TOKEN = your_token_here
```

### Шаг 3: Запустите проект

При первом запуске приложение автоматически:

1. Читает значение `API_TOKEN` из `Info.plist` (куда оно попадает из локального `WBShop/Config.xcconfig` через build settings);
2. Сохраняет токен в Keychain через `KeychainHelper`;
3. Все последующие запросы к API уже читают токен только из Keychain, а не из конфига.
