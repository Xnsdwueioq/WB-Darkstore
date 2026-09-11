//
//  FavoritesModel.swift
//  BusinessLogic
//
//  Created by Илья Ермаков on 11.09.2026.
//

import Foundation

@MainActor
public protocol FavoritesModelProtocol: AnyObject, Observable {
    var state: ScreenState<Bool> { get }
    func setFavorite(_ isFavorite: Bool, productID: String) async
}

@MainActor
@Observable
public final class FavoritesModel: FavoritesModelProtocol {
    public private(set) var state: ScreenState<Bool> = .loading

    private let productService: any ProductServiceProtocol

    public init(productService: any ProductServiceProtocol) {
        self.productService = productService
    }

    public func setFavorite(_ isFavorite: Bool, productID: String) async {
        let previousState = state
        state = .content(isFavorite)
        do {
            try await productService.setFavorite(isFavorite, productID: productID)
        } catch {
            if case .content = previousState {
                state = previousState
            } else {
                state = .error(error)
            }
        }
    }
}
