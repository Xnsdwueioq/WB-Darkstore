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
    
    //MARK: - Public
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
        let previousState = state
        if case .content(let cart) = state {
            state = .content(applyingIncrement(to: productID, in: cart))
        }
        do {
            _ = try await cartService.addToCart(productID: productID)
            await refreshSilently()
        } catch {
            rollback(to: previousState, error: error)
        }
    }
    
    public func removeFromCart(productID: String) async {
        let previousState = state
        if case .content(let cart) = state {
            state = .content(applyingDecrement(to: productID, in: cart))
        }
        do {
            _ = try await cartService.removeFromCart(productID: productID)
            await refreshSilently()
        } catch {
            rollback(to: previousState, error: error)
        }
    }
    
    // MARK: - Private
    
    private func rollback(to previousState: ScreenState<Cart>, error: Error) {
        if case .content = previousState {
            state = previousState
        } else {
            state = .error(error)
        }
    }
    
    private func refreshSilently() async {
        if let cart = try? await cartService.getCart() {
            state = .content(cart)
        }
    }
    
    private func applyingIncrement(to productID: String, in cart: Cart) -> Cart {
        guard let index = cart.items.firstIndex(where: { $0.id == productID }) else {
            return cart
        }
        var items = cart.items
        let item = items[index]
        items[index] = CartItem(
            id: item.id,
            name: item.name,
            imageURL: item.imageURL,
            weight: item.weight,
            price: item.price,
            quantity: item.quantity + 1,
            available: item.available
        )
        return recomputed(items: items, basedOn: cart)
    }
    
    private func applyingDecrement(to productID: String, in cart: Cart) -> Cart {
        guard let index = cart.items.firstIndex(where: { $0.id == productID }) else {
            return cart
        }
        var items = cart.items
        let item = items[index]
        if item.quantity > 1 {
            items[index] = CartItem(
                id: item.id,
                name: item.name,
                imageURL: item.imageURL,
                weight: item.weight,
                price: item.price,
                quantity: item.quantity - 1,
                available: item.available
            )
        } else {
            items.remove(at: index)
        }
        return recomputed(items: items, basedOn: cart)
    }
    
    private func recomputed(items: [CartItem], basedOn cart: Cart) -> Cart {
        let orderPrice = items.reduce(0) { $0 + $1.price * $1.quantity }
        let totalItems = items.reduce(0) { $0 + $1.quantity }
        return Cart(
            deliveryTime: cart.deliveryTime,
            orderPrice: orderPrice,
            deliveryPrice: cart.deliveryPrice,
            totalPrice: orderPrice + cart.deliveryPrice,
            totalItems: totalItems,
            items: items
        )
    }
}

