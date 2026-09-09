//
//  ProfileAPITests.swift
//  NetworkPackage
//
//  Created by Valeriy Solovey on 06.09.2026.
//

import Foundation
import HTTPTypes
import OpenAPIRuntime
import Testing
@testable import NetworkPackage

@Suite("ProfileAPI")
struct ProfileAPITests {
    @Test("Decodes all profile fields")
    func getsProfile() async throws {
        let api = makeAPI { request, body in
            #expect(request.method == .get)
            #expect(request.path == "/users/me")
            #expect(body == nil)
            return jsonResponse(Self.profileJSON)
        }

        let profile = try await api.fetchProfile()

        #expect(profile == ProfileDTO(
            name: "Valeriy",
            phone: "+79990000000",
            birthday: "01.01.1999",
            image: "https://example.com/profile.jxl"
        ))
    }

    @Test("Preserves an absent profile image")
    func getsProfileWithoutImage() async throws {
        let api = makeAPI { _, _ in
            jsonResponse(#"{"name":"Valeriy","phone":"+79990000000","birthday":"01.01.1999"}"#)
        }

        #expect(try await api.fetchProfile().image == nil)
    }

    @Test("Sends editable profile fields and accepts an empty response")
    func updatesProfile() async throws {
        let api = makeAPI { request, body in
            #expect(request.method == .put)
            #expect(request.path == "/users/me")
            let contentType = try #require(request.headerFields[.contentType])
            #expect(contentType.split(separator: ";").first == "application/json")
            let body = try #require(body)
            let data = try await Data(collecting: body, upTo: 4096)
            let json = try #require(try JSONSerialization.jsonObject(with: data) as? [String: String])
            #expect(json == [
                "name": "Updated name",
                "birthday": "02.02.2000",
                "imageUri": "data:image/jxl;base64,image-data"
            ])
            return (HTTPResponse(status: .ok), nil)
        }

        try await api.updateProfile(with: NewProfileDTO(
            name: "Updated name",
            birthday: "02.02.2000",
            image: "data:image/jxl;base64,image-data"
        ))
    }

    @Test("Deletes the profile without a request body")
    func deletesProfile() async throws {
        let api = makeAPI { request, body in
            #expect(request.method == .delete)
            #expect(request.path == "/users/me")
            #expect(body == nil)
            return (HTTPResponse(status: .ok), nil)
        }

        try await api.deleteProfile()
    }

    @Test("Logs out without a request body")
    func logsOut() async throws {
        let api = makeAPI { request, body in
            #expect(request.method == .post)
            #expect(request.path == "/logout")
            #expect(body == nil)
            return (HTTPResponse(status: .ok), nil)
        }

        try await api.logout()
    }

    enum Operation: CaseIterable, Sendable {
        case get, update, deleteProfile, logout

        func call(_ api: ProfileAPI) async throws {
            switch self {
            case .get:
                _ = try await api.fetchProfile()
            case .update:
                try await api.updateProfile(with: NewProfileDTO(
                    name: "Valeriy",
                    birthday: "01.01.1999",
                    image: "data:image/jxl;base64,image-data"
                ))
            case .deleteProfile:
                try await api.deleteProfile()
            case .logout:
                try await api.logout()
            }
        }
    }

    @Test("Maps HTTP errors for every operation", arguments: Operation.allCases, [400, 401, 503])
    func mapsErrors(operation: Operation, statusCode: Int) async throws {
        let api = makeAPI { _, _ in
            jsonResponse(#"{"error":"Profile request failed"}"#, statusCode: statusCode)
        }

        do {
            try await operation.call(api)
            Issue.record("Expected APIError for HTTP \(statusCode)")
        } catch let error as APIError {
            switch (statusCode, error) {
            case (400, .badRequest(let message)) where operation == .update:
                #expect(message == "Profile request failed")
            case (401, .unauthorized(let message)):
                #expect(message == "Profile request failed")
            case (_, .server(let actualStatus, let message)):
                #expect(statusCode == 503 || (statusCode == 400 && operation != .update))
                #expect(actualStatus == statusCode)
                #expect(message == "Profile request failed")
            default:
                Issue.record("Unexpected error: \(error)")
            }
        }
    }

    @Test("Rejects malformed or incomplete profile JSON", arguments: ["not json", "{}"])
    func rejectsInvalidProfile(json: String) async {
        let api = makeAPI { _, _ in jsonResponse(json) }

        await #expect(throws: (any Error).self) {
            try await api.fetchProfile()
        }
    }

    @Test("Preserves transport failures", arguments: Operation.allCases)
    func propagatesTransportErrors(operation: Operation) async throws {
        let api = makeAPI { _, _ in throw TransportError.offline }

        do {
            try await operation.call(api)
            Issue.record("Expected a transport failure")
        } catch let error as ClientError {
            #expect(error.underlyingError as? TransportError == .offline)
        }
    }

    private enum TransportError: Error {
        case offline
    }

    private func makeAPI(
        handler: @escaping @Sendable (HTTPRequest, HTTPBody?) async throws -> (HTTPResponse, HTTPBody?)
    ) -> ProfileAPI {
        let transport = StubTransport { request, body in
            #expect(request.headerFields[.authorization] == "Bearer test-token")
            return try await handler(request, body)
        }
        return ProfileAPI(apiClient: APIClient(
            serverURL: URL(string: "https://example.com")!,
            token: "test-token",
            transport: transport
        ))
    }

    private struct StubTransport: ClientTransport {
        let handler: @Sendable (HTTPRequest, HTTPBody?) async throws -> (HTTPResponse, HTTPBody?)

        func send(
            _ request: HTTPRequest,
            body: HTTPBody?,
            baseURL: URL,
            operationID: String
        ) async throws -> (HTTPResponse, HTTPBody?) {
            try await handler(request, body)
        }
    }

    private func jsonResponse(_ json: String, statusCode: Int = 200) -> (HTTPResponse, HTTPBody?) {
        (
            HTTPResponse(status: .init(code: statusCode), headerFields: [.contentType: "application/json"]),
            HTTPBody(json)
        )
    }

    private static let profileJSON = """
    {
      "name":"Valeriy",
      "phone":"+79990000000",
      "birthday":"01.01.1999",
      "imageUrl":"https://example.com/profile.jxl"
    }
    """
}
