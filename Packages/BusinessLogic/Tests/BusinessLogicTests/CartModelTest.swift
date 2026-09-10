//
//  CartServiceMock.swift
//  BusinessLogic
//
//  Created by Илья Ермаков on 10.09.2026.
//


import Foundation
import Testing
@testable import BusinessLogic

@Suite("CartModel")
@MainActor
struct CartModelTests {
    @Test("Initial state is loading")
    func initialStateIsLoading() {
        let service = CartServiceMock()
        let model = CartModel(cartService: service)

        guard case .loading = model.state else {
            Issue.record("Expected initial state to be .loading")
            return
        }
    }

    @Test("Loads cart and updates state to content")
    func loadCartSuccess() async {
        let expectedCart = BusinessLogic.Cart(
            deliveryTime: 30,
            orderPrice: 1200,
            deliveryPrice: 0,
            totalPrice: 1200,
            totalItems: 2,
            items: [
                BusinessLogic.CartItem(
                    id: "item-1",
                    name: "Tomatoes",
                    imageURL: URL(string: "https://example.com/tomatoes.png"),
                    weight: 500,
                    price: 249,
                    quantity: 2,
                    available: true
                )
            ]
        )
        let service = CartServiceMock(cartResult: .success(expectedCart))
        let model = CartModel(cartService: service)

        await model.loadCart()

        guard case .content(let cart) = model.state else {
            Issue.record("Expected state to be .content after successful load")
            return
        }
        #expect(cart == expectedCart)
    }

    @Test("Propagates service error into error state on load")
    func loadCartFailure() async {
        let service = CartServiceMock(cartResult: .failure(.requestFailed))
        let model = CartModel(cartService: service)

        await model.loadCart()

        guard case .error = model.state else {
            Issue.record("Expected state to be .error after failed load")
            return
        }
    }

    @Test("Adding an item reloads the cart into content")
    func addToCartSuccess() async {
        let expectedCart = BusinessLogic.Cart(
            deliveryTime: 30,
            orderPrice: 500,
            deliveryPrice: 0,
            totalPrice: 500,
            totalItems: 1,
            items: []
        )
        let service = CartServiceMock(cartResult: .success(expectedCart), addResult: .success(1))
        let model = CartModel(cartService: service)

        await model.addToCart(productID: "product-1")

        guard case .content(let cart) = model.state else {
            Issue.record("Expected state to be .content after successful add")
            return
        }
        #expect(cart == expectedCart)
    }

    @Test("Failed add-to-cart moves state to error without reloading")
    func addToCartFailure() async {
        let service = CartServiceMock(
            cartResult: .success(
                BusinessLogic.Cart(deliveryTime: 0, orderPrice: 0, deliveryPrice: 0, totalPrice: 0, totalItems: 0, items: [])
            ),
            addResult: .failure(.requestFailed)
        )
        let model = CartModel(cartService: service)

        await model.addToCart(productID: "product-1")

        guard case .error = model.state else {
            Issue.record("Expected state to be .error after failed add")
            return
        }
    }

    @Test("Removing an item reloads the cart into content")
    func removeFromCartSuccess() async {
        let expectedCart = BusinessLogic.Cart(
            deliveryTime: 30,
            orderPrice: 0,
            deliveryPrice: 0,
            totalPrice: 0,
            totalItems: 0,
            items: []
        )
        let service = CartServiceMock(cartResult: .success(expectedCart), removeResult: .success(0))
        let model = CartModel(cartService: service)

        await model.removeFromCart(productID: "product-1")

        guard case .content(let cart) = model.state else {
            Issue.record("Expected state to be .content after successful remove")
            return
        }
        #expect(cart == expectedCart)
    }
}
