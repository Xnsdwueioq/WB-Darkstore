//
//  BearerTokenMiddleware.swift
//  NetworkPackage
//
//  Created by Valeriy Solovey on 05.09.2026.
//

import Foundation
import OpenAPIRuntime
import HTTPTypes

struct BearerTokenMiddleware: ClientMiddleware {
  let token: String

  func intercept(
    _ request: HTTPRequest,
    body: HTTPBody?,
    baseURL: URL,
    operationID: String,
    next: @concurrent @Sendable (HTTPRequest, HTTPBody?, URL) async throws -> (HTTPResponse, HTTPBody?)
  ) async throws -> (HTTPResponse, HTTPBody?) {
    var request = request
    request.headerFields[.authorization] = "Bearer \(token)"
    return try await next(request, body, baseURL)
  }
}
