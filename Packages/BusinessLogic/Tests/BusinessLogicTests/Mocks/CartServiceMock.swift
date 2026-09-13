//
//  CartServiceMock.swift
//  BusinessLogic
//
//  Created by Илья Ермаков on 10.09.2026.
//

import Foundation
@testable import BusinessLogic

struct CartServiceMock: CartServiceProtocol {
    enum MockError: Error {
        case requestFailed
    }

    enum CartResult {
        case success(BusinessLogic.Cart)
        case failure(MockError)
    }

    enum QuantityResult {
        case success(Int)
        case failure(MockError)
    }

    let cartResult: CartResult
    let addResult: QuantityResult
    let removeResult: QuantityResult

    init(
        cartResult: CartResult = .success(
            BusinessLogic.Cart(deliveryTime: 0, orderPrice: 0, deliveryPrice: 0, totalPrice: 0, totalItems: 0, items: [])
        ),
        addResult: QuantityResult = .success(1),
        removeResult: QuantityResult = .success(0)
    ) {
        self.cartResult = cartResult
        self.addResult = addResult
        self.removeResult = removeResult
    }

    func getCart() async throws -> BusinessLogic.Cart {
        switch cartResult {
        case .success(let cart):
            cart
        case .failure(let error):
            throw error
        }
    }

    func addToCart(productID: String) async throws -> Int {
        switch addResult {
        case .success(let quantity):
            quantity
        case .failure(let error):
            throw error
        }
    }

    func removeFromCart(productID: String) async throws -> Int {
        switch removeResult {
        case .success(let quantity):
            quantity
        case .failure(let error):
            throw error
        }
    }
}
