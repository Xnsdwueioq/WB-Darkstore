//
//  ProfileServiceProtocol.swift
//  BusinessLogic
//
//  Created by Valeriy Solovey on 06.09.2026.
//

public protocol ProfileServiceProtocol: Sendable {
    func getProfile() async throws -> Profile
    func updateProfile(with newProfile: NewProfile) async throws
    func deleteProfile() async throws
    func logout() async throws
}
