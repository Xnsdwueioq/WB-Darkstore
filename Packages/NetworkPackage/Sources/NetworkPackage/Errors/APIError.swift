//
//  APIError.swift
//  NetworkPackage
//
//  Created by Valeriy Solovey on 04.09.2026.
//

public enum APIError: Error, Sendable {
    case unauthorized(message: String)
    case server(statusCode: Int, message: String)
}
