//
//  ProfileAPI.swift
//  NetworkPackage
//
//  Created by Valeriy Solovey on 06.09.2026.
//

public struct ProfileAPI: ProfileAPIProtocol {
    private let apiClient: APIClient

    public init(apiClient: APIClient) {
        self.apiClient = apiClient
    }

    public func fetchProfile() async throws -> ProfileDTO {
        let output = try await apiClient.client.getUsersMe()

        switch output {
        case .ok(let response):
            let profile = try response.body.json
            return .init(
                name: profile.name,
                phone: profile.phone,
                birthday: profile.birthday,
                image: profile.imageUrl
            )

        case .unauthorized(let response):
            let error = try response.body.json
            throw APIError.unauthorized(message: error.error)

        case .default(statusCode: let statusCode, let response):
            let error = try response.body.json
            throw APIError.server(statusCode: statusCode, message: error.error)
        }
    }

    public func updateProfile(with newProfile: NewProfileDTO) async throws {
        let output = try await apiClient.client.putUsersMe(body: .json(
            .init(
                name: newProfile.name,
                birthday: newProfile.birthday,
                imageUri: newProfile.image
            )
        ))

        switch output {
        case .ok:
            return

        case .badRequest(let response):
            let error = try response.body.json
            throw APIError.badRequest(message: error.error)

        case .unauthorized(let response):
            let error = try response.body.json
            throw APIError.unauthorized(message: error.error)

        case .default(statusCode: let statusCode, let response):
            let error = try response.body.json
            throw APIError.server(statusCode: statusCode, message: error.error)
        }
    }

    public func deleteProfile() async throws {
        let output = try await apiClient.client.deleteUsersMe()

        switch output {
        case .ok:
            return

        case .unauthorized(let response):
            let error = try response.body.json
            throw APIError.unauthorized(message: error.error)

        case .default(statusCode: let statusCode, let response):
            let error = try response.body.json
            throw APIError.server(statusCode: statusCode, message: error.error)
        }
    }

    public func logout() async throws {
        let output = try await apiClient.client.postLogout()

        switch output {
        case .ok:
            return

        case .unauthorized(let response):
            let error = try response.body.json
            throw APIError.unauthorized(message: error.error)

        case .default(statusCode: let statusCode, let response):
            let error = try response.body.json
            throw APIError.server(statusCode: statusCode, message: error.error)
        }
    }
}
