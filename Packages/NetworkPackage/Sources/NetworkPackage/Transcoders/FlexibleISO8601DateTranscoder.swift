//
// FlexibleISO8601DateTranscoder.swift
// WBTech
//

import Foundation
import OpenAPIRuntime

public struct FlexibleISO8601DateTranscoder: DateTranscoder {
  public init() {}

  public func encode(_ date: Date) throws -> String {
    let formatter = ISO8601DateFormatter()
    formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
    return formatter.string(from: date)
  }

  public func decode(_ dateString: String) throws -> Date {
    let isoWithFractional = ISO8601DateFormatter()
    isoWithFractional.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
    if let date = isoWithFractional.date(from: dateString) {
      return date
    }

    let isoStandard = ISO8601DateFormatter()
    isoStandard.formatOptions = [.withInternetDateTime]
    if let date = isoStandard.date(from: dateString) {
      return date
    }

    let formatPatterns = [
      "yyyy-MM-dd'T'HH:mm:ss.SSSZ",
      "yyyy-MM-dd HH:mm:ss",
      "yyyy-MM-dd"
    ]

    for pattern in formatPatterns {
      let df = DateFormatter()
      df.dateFormat = pattern
      df.locale = Locale(identifier: "en_US_POSIX")
      if let date = df.date(from: dateString) {
        return date
      }
    }

    throw DecodingError.dataCorrupted(
      .init(
        codingPath: [],
        debugDescription: "Could not parse date string: \(dateString)"
      )
    )
  }
}
