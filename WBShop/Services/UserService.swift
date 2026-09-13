import Foundation
import OpenAPIRuntime
import OpenAPIURLSession

@MainActor
protocol UserServicing {
    var addresses: [IdentifiableAddress] { get }
    var orders: [Order] { get }
    var errorMessage: String? { get }

    func currentUserName() async -> String
    func getAddresses() async
    func addAddress(_ address: Components.Schemas.Address) async -> Bool
    func updateAddress(id: String, _ address: Components.Schemas.Address) async -> Bool
    func deleteAddress(id: String) async
    func clearErrorMessage()
    func getOrders() async
    func getProfileInfo() async -> User
    func editProfile(_ user: User) async -> Bool
    func logout() async -> Bool
    func deleteAccount() async -> Bool
}

@Observable
@MainActor
final class UserService: UserServicing {
    var addresses: [IdentifiableAddress] = []
    var orders: [Order] = []
    var errorMessage: String?

    private let client: APIProtocol

    init(client: APIProtocol? = nil) {
        if let client = client {
            self.client = client
        } else {
            do {
                self.client = Client(
                    serverURL: try Servers.Server1.url(),
                    configuration: .init(dateTranscoder: FlexibleISO8601DateTranscoder()),
                    transport: URLSessionTransport(),
                    middlewares: [AuthMiddleware()]
                )
            } catch {
                fatalError("Не удалось создать URL сервера: \(error)")
            }
        }
    }

    func currentUserName() async -> String {
        do {
            let response = try await client.get_sol_users_sol_me(.init())
            switch response {
            case .ok(let okResponse):
                let profile = try okResponse.body.json
                clearErrorMessage()
                return profile.name
            case .unauthorized(let error):
                handleError(try? error.body.json.error, default: "Требуется авторизация")
            case .default(let statusCode, let error):
                handleError(try? error.body.json.error, default: "Ошибка сервера (\(statusCode))")
            }
        } catch {
            handleNetworkError(error)
        }
        return "Гость"
    }

    func getProfileInfo() async -> User {
        do {
            let response = try await client.get_sol_users_sol_me(.init())
            switch response {
            case .ok(let okResponse):
                let profile = try okResponse.body.json
                clearErrorMessage()
                return profile
            case .unauthorized(let error):
                handleError(try? error.body.json.error, default: "Требуется авторизация")
            case .default(let statusCode, let error):
                handleError(try? error.body.json.error, default: "Ошибка сервера (\(statusCode))")
            }
        } catch {
            handleNetworkError(error)
        }
        return User(name: "noname", phone: "", birthday: "")
    }

    func getAddresses() async {
        do {
            let response = try await client.get_sol_addresses(.init())

            switch response {
            case .ok(let okResponse):
                let fetchedAddresses = try okResponse.body.json
                addresses = fetchedAddresses.compactMap { item in
                    guard let id = item.value2.id else { return nil }
                    return IdentifiableAddress(id: id, address: item.value1)
                }
                clearErrorMessage()

            case .unauthorized(let error):
                handleError(try? error.body.json.error, default: "Требуется авторизация")

            case .default(let statusCode, let error):
                handleError(try? error.body.json.error, default: "Ошибка сервера (\(statusCode))")
            }
        } catch {
            handleNetworkError(error)
        }
    }

    func addAddress(_ address: Components.Schemas.Address) async -> Bool {
        do {
            let response = try await client.post_sol_addresses(body: .json(address))

            switch response {
            case .ok:
                await getAddresses()
                return true
            case .badRequest(let error):
                handleError(try? error.body.json.error, default: "Некорректные данные адреса")
            case .unauthorized(let error):
                handleError(try? error.body.json.error, default: "Требуется авторизация")
            case .default(let statusCode, let error):
                handleError(try? error.body.json.error, default: "Ошибка сервера (\(statusCode))")
            }
        } catch {
            handleNetworkError(error)
        }
        return false
    }

    func updateAddress(id: String, _ address: Components.Schemas.Address) async -> Bool {
        do {
            let response = try await client.put_sol_addresses_sol__lcub_id_rcub_(
                path: .init(id: id),
                body: .json(address)
            )

            switch response {
            case .ok:
                await getAddresses()
                return true
            case .badRequest(let error):
                handleError(try? error.body.json.error, default: "Некорректные данные адреса")
            case .unauthorized(let error):
                handleError(try? error.body.json.error, default: "Требуется авторизация")
            case .notFound(let error):
                handleError(try? error.body.json.error, default: "Адрес не найден")
            case .default(let statusCode, let error):
                handleError(try? error.body.json.error, default: "Ошибка сервера (\(statusCode))")
            }
        } catch {
            handleNetworkError(error)
        }
        return false
    }

    func deleteAddress(id: String) async {
        do {
            let response = try await client.delete_sol_addresses_sol__lcub_id_rcub_(path: .init(id: id))
            switch response {
            case .ok:
                await getAddresses()
            case .unauthorized(let error):
                handleError(try? error.body.json.error, default: "Требуется авторизация")
            case .notFound(let error):
                handleError(try? error.body.json.error, default: "Адрес не найден")
            case .default(let statusCode, let error):
                handleError(try? error.body.json.error, default: "Ошибка сервера (\(statusCode))")
            }
        } catch {
            handleNetworkError(error)
        }
    }

    private func handleError(_ message: String?, default defaultMessage: String) {
        errorMessage = message ?? defaultMessage
    }

    private func handleNetworkError(_ error: Error) {
        errorMessage = "Ошибка сети: \(error.localizedDescription)"
    }

    func clearErrorMessage() {
        if errorMessage != nil {
            errorMessage = nil
        }
    }
    
    func getOrders() async {
        do {
            let response = try await client.get_sol_orders(.init())
            switch response {
            case .ok(let okResponse):
                orders = try okResponse.body.json
                clearErrorMessage()
            case .unauthorized(let error):
                handleError(try? error.body.json.error, default: "Требуется авторизация")
            case .default(let statusCode, let error):
                handleError(try? error.body.json.error, default: "Ошибка сервера (\(statusCode))")
            }
        } catch {
            handleNetworkError(error)
        }
    }

    func editProfile(_ user: User) async -> Bool {
        do {
            let payload = Operations.put_sol_users_sol_me.Input.Body.jsonPayload(
                name: user.name,
                birthday: user.birthday,
                imageUri: ""
            )
            let response = try await client.put_sol_users_sol_me(
                body: .json(payload)
            )
            switch response {
            case .ok:
                clearErrorMessage()
                return true
            case .badRequest:
                handleError(nil, default: "Ошибка валидации входных данных")
            case .unauthorized:
                handleError(nil, default: "Требуется авторизация")
            case .default(let statusCode, _):
                handleError(nil, default: "Ошибка сервера (\(statusCode))")
            }
        } catch {
            handleNetworkError(error)
        }
        return false
    }

    func logout() async -> Bool {
        do {
            let response = try await client.post_sol_logout(.init())
            switch response {
            case .ok:
                clearErrorMessage()
                return true
            case .unauthorized(let error):
                handleError(try? error.body.json.error, default: "Требуется авторизация")
            case .default(let statusCode, let error):
                handleError(try? error.body.json.error, default: "Ошибка сервера (\(statusCode))")
            }
        } catch {
            handleNetworkError(error)
        }
        return false
    }

    func deleteAccount() async -> Bool {
        do {
            let response = try await client.delete_sol_users_sol_me(.init())
            switch response {
            case .ok:
                clearErrorMessage()
                return true
            case .unauthorized(let error):
                handleError(try? error.body.json.error, default: "Требуется авторизация")
            case .default(let statusCode, let error):
                handleError(try? error.body.json.error, default: "Ошибка сервера (\(statusCode))")
            }
        } catch {
            handleNetworkError(error)
        }
        return false
    }
}
