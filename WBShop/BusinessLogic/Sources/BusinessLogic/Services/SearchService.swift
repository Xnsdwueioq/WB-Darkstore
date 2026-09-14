import Foundation

@MainActor
public protocol SearchServicing: AnyObject {
    func search(query: String) -> [ProductPreview]
    var recentSearches: [String] { get set }
}

@Observable
@MainActor
public final class SearchService: SearchServicing {
    private let productService: any ProductServicing
    public var recentSearches: [String] = []

    public init(productService: any ProductServicing) {
        self.productService = productService
    }

    public func search(query: String) -> [ProductPreview] {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return [] }

        return productService.products.filter {
            $0.name.localizedCaseInsensitiveContains(trimmed)
        }
    }
}
