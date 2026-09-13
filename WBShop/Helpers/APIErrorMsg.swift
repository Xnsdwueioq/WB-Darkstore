import Foundation

extension Components.Responses._401 {
    var errorMessage: String? { (try? body.json)?.error }
}

extension Components.Responses._404 {
    var errorMessage: String? { (try? body.json)?.error }
}

extension Components.Responses.BadRequestError {
    var errorMessage: String? { (try? body.json)?.error }
}

extension Components.Responses.InternalServerError {
    var errorMessage: String? { (try? body.json)?.error }
}
