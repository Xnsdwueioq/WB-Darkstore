import Foundation
import OpenAPIRuntime
import HTTPTypes

struct AuthMiddleware: ClientMiddleware {
    func intercept(
        _ request: HTTPTypes.HTTPRequest,
        body: OpenAPIRuntime.HTTPBody?,
        baseURL: URL,
        operationID: String,
        next: @concurrent @Sendable (HTTPTypes.HTTPRequest, OpenAPIRuntime.HTTPBody?, URL) async throws -> (HTTPTypes.HTTPResponse, OpenAPIRuntime.HTTPBody?)
    ) async throws -> (HTTPTypes.HTTPResponse, OpenAPIRuntime.HTTPBody?) {
        var request = request
        let serviceName = "com.wbshop.api"
        let accountName = "authToken"
        
        if let token = KeychainHelper.shared.read(service: serviceName, account: accountName) {
            request.headerFields[.authorization] = "Bearer \(token)"
        } else {
            print("Токен не найден в Keychain")
        }
        
        return try await next(request, body, baseURL)
    }
}
