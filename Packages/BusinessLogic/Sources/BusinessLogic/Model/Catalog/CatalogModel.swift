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
    var productsState: ScreenState<ProductList> { get }
    func loadCategories() async
    func loadProducts(categoryID: String?, page: Int?, pageSize: Int?) async
}

@MainActor
@Observable
public final class CatalogModel: CatalogModelProtocol {
    public private(set) var state: ScreenState<[Category]> = .loading
    public private(set) var productsState: ScreenState<ProductList> = .loading

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
    
    public func loadProducts(categoryID: String?, page: Int?, pageSize: Int?) async {
        productsState = .loading
        do {
            let productList = try await catalogService.getProducts(
                categoryID: categoryID,
                page: page,
                pageSize: pageSize
            )
            productsState = .content(productList)
        } catch {
            productsState = .error(error)
        }
    }
}
