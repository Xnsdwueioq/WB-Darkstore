import Foundation
import OpenAPIRuntime

enum APIErrorDecoder {
    static func decodeErrorMessage(from body: OpenAPIRuntime.HTTPBody) async -> String? {
        do {
            let data = try await Data(collecting: body, upTo: 1024 * 1024)
            if let json = try? JSONDecoder().decode(Components.Schemas.ErrorResponse.self, from: data) {
                return json.error
            }
            if let dict = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let error = dict["error"] as? String {
                return error
            }
            return String(data: data, encoding: .utf8)
        } catch {
            return nil
        }
    }
}
