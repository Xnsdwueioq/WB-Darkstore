//
//  AddressAPITests.swift
//  NetworkPackage
//
//  Created by Valeriy Solovey on 05.09.2026.
//

import Foundation
import HTTPTypes
import OpenAPIRuntime
import Testing
@testable import NetworkPackage

@Suite("AddressAPI")
struct AddressAPITests {
    @Test("Decodes saved IDs and allOf address fields in server order")
    func fetchesAddresses() async throws {
        let api = makeAPI { request, body in
            #expect(request.method == .get)
            #expect(request.path == "/addresses")
            #expect(body == nil)
            return jsonResponse(Self.addressesJSON)
        }

        let addresses = try await api.fetchAddresses()

        #expect(addresses == [
            SavedAddressDTO(id: "address-2", address: makeAddress(withDetails: true)),
            SavedAddressDTO(id: "address-1", address: makeAddress(withDetails: false))
        ])
    }

    @Test("Decodes an empty address list")
    func fetchesEmptyAddresses() async throws {
        let api = makeAPI { _, _ in jsonResponse("[]") }

        #expect(try await api.fetchAddresses().isEmpty)
    }

    @Test("Sends address JSON and accepts empty POST and PUT responses", arguments: [false, true], [false, true])
    func writesAddress(updating: Bool, withDetails: Bool) async throws {
        let address = makeAddress(withDetails: withDetails)
        let api = makeAPI { request, body in
            #expect(request.method == (updating ? .put : .post))
            #expect(request.path == (updating ? "/addresses/address%201" : "/addresses"))
            let contentType = try #require(request.headerFields[.contentType])
            #expect(contentType.split(separator: ";").first == "application/json")
            let body = try #require(body)
            let data = try await Data(collecting: body, upTo: 4096)
            let json = try #require(try JSONSerialization.jsonObject(with: data) as? [String: Any])
            #expect(json["coordinates"] as? [Double] == [92.87, 56.01])
            #expect(json["addressLine"] as? String == "Мира, 10")
            #expect(json["floor"] as? String == address.floor)
            #expect(json["entrance"] as? String == address.entrance)
            #expect(json["intercomCode"] as? String == address.intercomCode)
            #expect(json["comment"] as? String == address.comment)
            #expect(json["id"] == nil)
            return (HTTPResponse(status: .ok), nil)
        }

        if updating {
            try await api.updateAddress(addressID: "address 1", address: address)
        } else {
            try await api.addAddress(address)
        }
    }

    @Test("Deletes using the encoded address ID without a request body")
    func deletesAddress() async throws {
        let api = makeAPI { request, body in
            #expect(request.method == .delete)
            #expect(request.path == "/addresses/address%201")
            #expect(body == nil)
            return (HTTPResponse(status: .ok), nil)
        }

        try await api.deleteAddress(addressID: "address 1")
    }

    enum Operation: CaseIterable, Sendable {
        case fetch, add, update, delete

        func call(_ api: AddressAPI) async throws {
            let address = AddressDTO(
                coordinates: [92.87, 56.01], addressLine: "Мира, 10",
                floor: nil, entrance: nil, intercomCode: nil, comment: nil
            )
            switch self {
            case .fetch: _ = try await api.fetchAddresses()
            case .add: try await api.addAddress(address)
            case .update: try await api.updateAddress(addressID: "address-1", address: address)
            case .delete: try await api.deleteAddress(addressID: "address-1")
            }
        }
    }

    @Test("Maps HTTP errors for every operation", arguments: Operation.allCases, [400, 401, 404, 503])
    func mapsErrors(operation: Operation, statusCode: Int) async throws {
        let api = makeAPI { _, _ in
            jsonResponse(#"{"error":"Address request failed"}"#, statusCode: statusCode)
        }

        do {
            try await operation.call(api)
            Issue.record("Expected APIError for HTTP \(statusCode)")
        } catch let error as APIError {
            switch (statusCode, error) {
            case (400, .badRequest(let message)) where operation == .add || operation == .update:
                #expect(message == "Address request failed")
            case (401, .unauthorized(let message)):
                #expect(message == "Address request failed")
            case (404, .notFound(let message)) where operation == .update || operation == .delete:
                #expect(message == "Address request failed")
            case (_, .server(let actualStatus, let message)):
                let isDefault = statusCode == 503
                    || (statusCode == 400 && (operation == .fetch || operation == .delete))
                    || (statusCode == 404 && (operation == .fetch || operation == .add))
                #expect(isDefault)
                #expect(actualStatus == statusCode)
                #expect(message == "Address request failed")
            default:
                Issue.record("Unexpected error: \(error)")
            }
        }
    }

    @Test("Rejects missing or null saved address IDs", arguments: ["", #", "id":null"#])
    func rejectsMissingID(idField: String) async throws {
        let api = makeAPI { _, _ in
            jsonResponse("[{\"coordinates\":[92.87,56.01],\"addressLine\":\"Мира, 10\"\(idField)}]")
        }

        do {
            _ = try await api.fetchAddresses()
            Issue.record("Expected a missing address ID error")
        } catch let error as APIError {
            guard case .invalidResponse(let message) = error else {
                Issue.record("Unexpected error: \(error)")
                return
            }
            #expect(message == "Address ID is missing")
        }
    }

    @Test("Rejects malformed or incomplete address JSON", arguments: ["not json", "[{}]"])
    func rejectsInvalidAddresses(json: String) async {
        let api = makeAPI { _, _ in jsonResponse(json) }

        await #expect(throws: (any Error).self) {
            try await api.fetchAddresses()
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

    private func makeAddress(withDetails: Bool) -> AddressDTO {
        AddressDTO(
            coordinates: [92.87, 56.01], addressLine: "Мира, 10",
            floor: withDetails ? "5" : nil, entrance: withDetails ? "2" : nil,
            intercomCode: withDetails ? "42" : nil, comment: withDetails ? "Позвонить" : nil
        )
    }

    private func makeAPI(
        handler: @escaping @Sendable (HTTPRequest, HTTPBody?) async throws -> (HTTPResponse, HTTPBody?)
    ) -> AddressAPI {
        let transport = StubTransport { request, body in
            #expect(request.headerFields[.authorization] == "Bearer test-token")
            return try await handler(request, body)
        }
        return AddressAPI(apiClient: APIClient(
            serverURL: URL(string: "https://example.com")!, token: "test-token", transport: transport
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
        (HTTPResponse(status: .init(code: statusCode), headerFields: [.contentType: "application/json"]), HTTPBody(json))
    }

    private static let addressesJSON = """
    [
      {"id":"address-2","coordinates":[92.87,56.01],"addressLine":"Мира, 10",
       "floor":"5","entrance":"2","intercomCode":"42","comment":"Позвонить"},
      {"id":"address-1","coordinates":[92.87,56.01],"addressLine":"Мира, 10"}
    ]
    """
}
