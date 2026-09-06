//
//  ProfileService.swift
//  BusinessLogic
//
//  Created by Valeriy Solovey on 06.09.2026.
//

import Foundation
import NetworkPackage

public struct ProfileService: ProfileServiceProtocol {
    private let profileAPI: any ProfileAPIProtocol

    public init(profileAPI: any ProfileAPIProtocol) {
        self.profileAPI = profileAPI
    }

    public func getProfile() async throws -> Profile {
        let profile = try await profileAPI.fetchProfile()

        return .init(
            name: profile.name,
            phone: profile.phone,
            birthday: profile.birthday,
            imageURL: profile.image.flatMap(URL.init(string:))
        )
    }

    public func updateProfile(with newProfile: NewProfile) async throws {
        let dto: NewProfileDTO = .init(
            name: newProfile.name,
            birthday: newProfile.birthday,
            image: newProfile.imageURL.absoluteString
        )
        try await profileAPI.updateProfile(with: dto)
    }

    public func deleteProfile() async throws {
        try await profileAPI.deleteProfile()
    }

    public func logout() async throws {
        try await profileAPI.logout()
    }
}
