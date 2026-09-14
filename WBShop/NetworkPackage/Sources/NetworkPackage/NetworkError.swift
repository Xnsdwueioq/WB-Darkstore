import Foundation

public enum NetworkError: Error, Sendable, Equatable {
    case http(statusCode: Int, message: String?)
    case transport(String)
    case unexpectedResponse(String)
    case decoding(String)

    public var localizedDescription: String {
        switch self {
        case .http(let statusCode, let message):
            if let message {
                return message
            }
            return "Ошибка HTTP (\(statusCode))"
        case .transport(let message):
            return "Ошибка сети: \(message)"
        case .unexpectedResponse(let message):
            return "Неожиданный ответ сервера: \(message)"
        case .decoding(let message):
            return "Ошибка декодирования: \(message)"
        }
    }
}
