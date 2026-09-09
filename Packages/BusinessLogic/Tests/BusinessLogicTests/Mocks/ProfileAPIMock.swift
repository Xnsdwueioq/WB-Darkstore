//
//  ProfileAPIMock.swift
//  BusinessLogic
//
//  Created by Valeriy Solovey on 06.09.2026.
//

import NetworkPackage

actor ProfileAPIMock: ProfileAPIProtocol {
    enum MockError: Error, Equatable {
        case requestFailed
    }

    private let profileResult: Result<ProfileDTO, MockError>
    private let mutationError: MockError?

    private(set) var updatedProfiles: [NewProfileDTO] = []
    private(set) var deleteProfileCallCount = 0
    private(set) var logoutCallCount = 0

    init(
        profileResult: Result<ProfileDTO, MockError> = .success(ProfileDTO(
            name: "Valeriy",
            phone: "+79990000000",
            birthday: "01.01.1999",
            image: "https://example.com/profile.jxl"
        )),
        mutationError: MockError? = nil
    ) {
        self.profileResult = profileResult
        self.mutationError = mutationError
    }

    func fetchProfile() async throws -> ProfileDTO {
        try profileResult.get()
    }

    func updateProfile(with newProfile: NewProfileDTO) async throws {
        updatedProfiles.append(newProfile)
        if let mutationError { throw mutationError }
    }

    func deleteProfile() async throws {
        deleteProfileCallCount += 1
        if let mutationError { throw mutationError }
    }

    func logout() async throws {
        logoutCallCount += 1
        if let mutationError { throw mutationError }
    }
}
