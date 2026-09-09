//
//  CatalogModel.swift.swift
//  BusinessLogic
//
//  Created by Илья Ермаков on 09.09.2026.
//

import Foundation

@MainActor
public protocol CatalogModelProtocol: AnyObject, Observable {
    var state: ScreenState<[Category]> { get }
    func loadCategories() async
}

@MainActor
@Observable
public final class CatalogModel: CatalogModelProtocol {
    public private(set) var state: ScreenState<[Category]> = .loading

    private let catalogService: any CatalogServiceProtocol

    public init(catalogService: any CatalogServiceProtocol) {
        self.catalogService = catalogService
    }

    public func loadCategories() async {
        state = .loading
        do {
            let categories = try await catalogService.getCategories()
            state = .content(categories)
        } catch {
            state = .error(error)
        }
    }
}
