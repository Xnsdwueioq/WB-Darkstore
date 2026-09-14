import OpenAPIRuntime
import Foundation

struct FlexibleISO8601DateTranscoder: DateTranscoder {
    private var formatter: ISO8601DateFormatter {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        return formatter
    }

    func encode(_ date: Date) throws -> String {
        formatter.string(from: date)
    }

    func decode(_ string: String) throws -> Date {
        let cleaned: String

        if let dotIndex = string.firstIndex(of: ".") {
            let fractionalEnd = string[dotIndex...]
                .firstIndex(where: { $0 == "Z" || $0 == "+" || $0 == "-" })

            if let fractionalEnd {
                cleaned = String(string[..<dotIndex]) + String(string[fractionalEnd...])
            } else {
                cleaned = String(string[..<dotIndex])
            }
        } else {
            cleaned = string
        }

        guard let date = formatter.date(from: cleaned) else {
            throw DecodingError.dataCorrupted(.init(codingPath: [], debugDescription: "Bad date: \(string)"))
        }
        return date
    }
}
