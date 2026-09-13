import Foundation
import Core

protocol SearchServicing {
    func search(query: String) -> [ProductPreview]
    var recentSearches: [String] { get set }

}

final class SearchService: SearchServicing {
    @Injected private var productService: ProductServicing
    public var recentSearches: [String] = []

    init() {}

    func search(query: String) -> [ProductPreview] {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return [] }
        
        return productService.products.filter {
            $0.name.localizedCaseInsensitiveContains(trimmed)
        }
    }
}
