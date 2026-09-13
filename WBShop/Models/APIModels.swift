//
//  APIModels.swift
//  WBShop
//
//  Created by Полина Гельман on 01.07.2026.
//

import Foundation

typealias ProductPreview = Components.Schemas.ProductPreview

typealias Product = Components.Schemas.Product

typealias Category = Components.Schemas.Category

typealias Review = Components.Schemas.Review

struct IdentifiableAddress: Identifiable, Hashable {
    let id: String
    var address: Components.Schemas.Address
}

typealias Order = Components.Schemas.Order

typealias OrderItem = Components.Schemas.OrderItem

typealias User = Components.Schemas.UserProfile

extension Category: Identifiable {}

struct CartModel {
    var items: [String: Int] // [productId: quantity]

    var totalQuantity: Int {
        items.values.reduce(0, +)
    }

    init(from products: [CartProduct]) {
        self.items = Dictionary(uniqueKeysWithValues: products.map { ($0.id, $0.quantity) })
    }
}
