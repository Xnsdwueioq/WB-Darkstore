//
//  CartModel.swift
//  BusinessLogic
//
//  Created by Илья Ермаков on 10.09.2026.
//

import Foundation

@MainActor
public protocol CartModelProtocol: AnyObject, Observable {
    var state: ScreenState<Cart> { get }
    func loadCart() async
    func addToCart(productID: String) async
    func removeFromCart(productID: String) async
}

@MainActor
@Observable
public final class CartModel: CartModelProtocol {
    public private(set) var state: ScreenState<Cart> = .loading

    private let cartService: any CartServiceProtocol

    public init(cartService: any CartServiceProtocol) {
        self.cartService = cartService
    }

    public func loadCart() async {
        state = .loading
        do {
            let cart = try await cartService.getCart()
            state = .content(cart)
        } catch {
            state = .error(error)
        }
    }

    public func addToCart(productID: String) async {
        do {
            _ = try await cartService.addToCart(productID: productID)
            await loadCart()
        } catch {
            state = .error(error)
        }
    }

    public func removeFromCart(productID: String) async {
        do {
            _ = try await cartService.removeFromCart(productID: productID)
            await loadCart()
        } catch {
            state = .error(error)
        }
    }
}
