//
//  ProductListDTO.swift
//  NetworkPackage
//
//  Created by Valeriy Solovey on 04.09.2026.
//

public struct ProductListDTO: Sendable, Equatable {
    public let currentPage: Int
    public let totalPages: Int
    public let products: [ProductPreviewDTO]

    public init(
        currentPage: Int,
        totalPages: Int,
        products: [ProductPreviewDTO]
    ) {
        self.currentPage = currentPage
        self.totalPages = totalPages
        self.products = products
    }
}
