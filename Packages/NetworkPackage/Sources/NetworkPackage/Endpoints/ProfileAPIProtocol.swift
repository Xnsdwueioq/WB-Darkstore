//
//  ProfileAPIProtocol.swift
//  NetworkPackage
//
//  Created by Valeriy Solovey on 06.09.2026.
//

public protocol ProfileAPIProtocol: Sendable {
    func fetchProfile() async throws -> ProfileDTO
    func updateProfile(with newProfile: NewProfileDTO) async throws
    func deleteProfile() async throws
    func logout() async throws
}
