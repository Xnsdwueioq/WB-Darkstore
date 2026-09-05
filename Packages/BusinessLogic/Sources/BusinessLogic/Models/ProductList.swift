//
//  ProductList.swift
//  BusinessLogic
//
//  Created by Valeriy Solovey on 04.09.2026.
//

public struct ProductList: Sendable, Equatable {
    public let currentPage: Int
    public let totalPages: Int
    public let products: [Product]

    public init(
        currentPage: Int,
        totalPages: Int,
        products: [Product]
    ) {
        self.currentPage = currentPage
        self.totalPages = totalPages
        self.products = products
    }
}
