//
//  ProfileServiceTests.swift
//  BusinessLogic
//
//  Created by Valeriy Solovey on 06.09.2026.
//

import Foundation
import NetworkPackage
import Testing
@testable import BusinessLogic

@Suite("ProfileService")
struct ProfileServiceTests {
    @Test("Maps every profile field and image URL")
    func getsProfile() async throws {
        let service = ProfileService(profileAPI: ProfileAPIMock())

        let profile = try await service.getProfile()

        #expect(profile == Profile(
            name: "Valeriy",
            phone: "+79990000000",
            birthday: "01.01.1999",
            imageURL: URL(string: "https://example.com/profile.jxl")
        ))
    }

    @Test("Maps an absent or invalid image URL to nil", arguments: [nil, "http://["] as [String?])
    func getsProfileWithoutValidImage(image: String?) async throws {
        let dto = ProfileDTO(
            name: "Valeriy",
            phone: "+79990000000",
            birthday: "01.01.1999",
            image: image
        )
        let service = ProfileService(profileAPI: ProfileAPIMock(profileResult: .success(dto)))

        #expect(try await service.getProfile().imageURL == nil)
    }

    @Test("Passes every editable profile field to the API")
    func updatesProfile() async throws {
        let api = ProfileAPIMock()
        let service = ProfileService(profileAPI: api)
        let imageURL = try #require(URL(string: "data:image/jxl;base64,image-data"))
        let profile = NewProfile(
            name: "Updated name",
            birthday: "02.02.2000",
            imageURL: imageURL
        )

        try await service.updateProfile(with: profile)

        let updatedProfiles = await api.updatedProfiles
        #expect(updatedProfiles == [NewProfileDTO(
            name: "Updated name",
            birthday: "02.02.2000",
            image: "data:image/jxl;base64,image-data"
        )])
    }

    @Test("Forwards profile deletion and logout")
    func forwardsProfileMutations() async throws {
        let api = ProfileAPIMock()
        let service = ProfileService(profileAPI: api)

        try await service.deleteProfile()
        try await service.logout()

        let deleteProfileCallCount = await api.deleteProfileCallCount
        let logoutCallCount = await api.logoutCallCount
        #expect(deleteProfileCallCount == 1)
        #expect(logoutCallCount == 1)
    }

    enum Operation: CaseIterable, Sendable {
        case get, update, deleteProfile, logout

        func call(_ service: ProfileService) async throws {
            switch self {
            case .get:
                _ = try await service.getProfile()
            case .update:
                let imageURL = try #require(URL(string: "data:image/jxl;base64,image-data"))
                try await service.updateProfile(with: NewProfile(
                    name: "Valeriy",
                    birthday: "01.01.1999",
                    imageURL: imageURL
                ))
            case .deleteProfile:
                try await service.deleteProfile()
            case .logout:
                try await service.logout()
            }
        }
    }

    @Test("Propagates errors from every operation", arguments: Operation.allCases)
    func propagatesErrors(operation: Operation) async {
        let api = ProfileAPIMock(
            profileResult: .failure(.requestFailed),
            mutationError: .requestFailed
        )
        let service = ProfileService(profileAPI: api)

        await #expect(throws: ProfileAPIMock.MockError.requestFailed) {
            try await operation.call(service)
        }
    }
}
