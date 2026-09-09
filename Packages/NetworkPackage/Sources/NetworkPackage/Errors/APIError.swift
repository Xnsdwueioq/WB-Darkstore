//
//  APIError.swift
//  NetworkPackage
//
//  Created by Valeriy Solovey on 04.09.2026.
//

public enum APIError: Error, Sendable {
    case invalidResponse(message: String)
    case badRequest(message: String)
    case unauthorized(message: String)
    case notFound(message: String)
    case server(statusCode: Int, message: String)
}
