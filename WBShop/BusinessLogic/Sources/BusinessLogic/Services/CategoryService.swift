import Foundation
import NetworkPackage

@MainActor
public protocol CategoryServicing: AnyObject {
    func fetchCategories() async
    var errorMessage: String? { get }
    var categories: [Category] { get }
    func clearErrorMessage()
}

@Observable
@MainActor
public final class CategoryService: CategoryServicing {
    private let catalogAPI: any CatalogAPIProtocol
    public var errorMessage: String?
    public private(set) var categories: [Category] = []
    private var isFetching = false

    public init(catalogAPI: any CatalogAPIProtocol) {
        self.catalogAPI = catalogAPI
    }

    public func fetchCategories() async {
        guard !isFetching else { return }
        isFetching = true
        defer { isFetching = false }

        do {
            let categoryDTOs = try await catalogAPI.fetchCategories()
            self.categories = CatalogMapper.mapCategories(categoryDTOs)
            clearErrorMessage()
        } catch let error as NetworkError {
            self.errorMessage = error.localizedDescription
        } catch {
            self.errorMessage = "Ошибка сети: \(error.localizedDescription)"
        }
    }

    public func clearErrorMessage() {
        if errorMessage != nil {
            errorMessage = nil
        }
    }
}
