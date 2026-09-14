import Foundation
import OpenAPIRuntime

public protocol ProfileAPIProtocol: Sendable {
    func fetchProfile() async throws -> UserProfileDTO
    func updateProfile(name: String, birthday: String, imageURI: String) async throws
    func deleteAccount() async throws
    func logout() async throws
}

public extension ProfileAPIProtocol {
    func updateProfile(name: String, birthday: String) async throws {
        try await updateProfile(name: name, birthday: birthday, imageURI: "")
    }
}

final class ProfileAPI: ProfileAPIProtocol {
    private let client: any APIProtocol

    init(client: any APIProtocol) {
        self.client = client
    }

    func fetchProfile() async throws -> UserProfileDTO {
        do {
            let response = try await client.get_sol_users_sol_me(.init())

            switch response {
            case .ok(let okResponse):
                let body = try okResponse.body.json
                return UserProfileDTO(
                    name: body.name,
                    phone: body.phone,
                    birthday: body.birthday,
                    imageUrl: body.imageUrl
                )

            case .unauthorized(let unauthorized):
                let message = try? unauthorized.body.json.error
                throw NetworkError.http(statusCode: 401, message: message)

            case .default(let statusCode, let defaultResp):
                let message = try? defaultResp.body.json.error
                throw NetworkError.http(statusCode: statusCode, message: message)
            }
        } catch let error as NetworkError {
            throw error
        } catch {
            throw NetworkError.transport(error.localizedDescription)
        }
    }

    func updateProfile(name: String, birthday: String, imageURI: String) async throws {
        do {
            let payload = Operations.put_sol_users_sol_me.Input.Body.jsonPayload(
                name: name,
                birthday: birthday,
                imageUri: imageURI
            )
            let response = try await client.put_sol_users_sol_me(body: .json(payload))

            switch response {
            case .ok:
                return

            case .badRequest(let badRequest):
                let message = try? badRequest.body.json.error
                throw NetworkError.http(statusCode: 400, message: message ?? "Ошибка валидации входных данных")

            case .unauthorized(let unauthorized):
                let message = try? unauthorized.body.json.error
                throw NetworkError.http(statusCode: 401, message: message)

            case .default(let statusCode, let defaultResp):
                let message = try? defaultResp.body.json.error
                throw NetworkError.http(statusCode: statusCode, message: message)
            }
        } catch let error as NetworkError {
            throw error
        } catch {
            throw NetworkError.transport(error.localizedDescription)
        }
    }

    func deleteAccount() async throws {
        do {
            let response = try await client.delete_sol_users_sol_me(.init())

            switch response {
            case .ok:
                return

            case .unauthorized(let unauthorized):
                let message = try? unauthorized.body.json.error
                throw NetworkError.http(statusCode: 401, message: message)

            case .default(let statusCode, let defaultResp):
                let message = try? defaultResp.body.json.error
                throw NetworkError.http(statusCode: statusCode, message: message)
            }
        } catch let error as NetworkError {
            throw error
        } catch {
            throw NetworkError.transport(error.localizedDescription)
        }
    }

    func logout() async throws {
        do {
            let response = try await client.post_sol_logout(.init())

            switch response {
            case .ok:
                return

            case .unauthorized(let unauthorized):
                let message = try? unauthorized.body.json.error
                throw NetworkError.http(statusCode: 401, message: message)

            case .default(let statusCode, let defaultResp):
                let message = try? defaultResp.body.json.error
                throw NetworkError.http(statusCode: statusCode, message: message)
            }
        } catch let error as NetworkError {
            throw error
        } catch {
            throw NetworkError.transport(error.localizedDescription)
        }
    }
}
