//
//  CompositionRoot.swift
//  WBDarkstore
//
//  Created by Valeriy Solovey on 04.09.2026.
//

import BusinessLogic
import NetworkPackage

struct CompositionRoot {
    let catalogService: CatalogService
    let productService: ProductService
    let cartService: CartService
    let orderService: OrderService
    let addressService: AddressService

    init(token: String) throws {
        let apiClient = try APIClient(token: token)
        let catalogAPI = CatalogAPI(apiClient: apiClient)
        let productAPI = ProductAPI(apiClient: apiClient)
        let cartAPI = CartAPI(apiClient: apiClient)
        let orderAPI = OrderAPI(apiClient: apiClient)
        let addressAPI = AddressAPI(apiClient: apiClient)

        catalogService = CatalogService(api: catalogAPI)
        productService = ProductService(productAPI: productAPI)
        cartService = CartService(cartAPI: cartAPI)
        orderService = OrderService(orderAPI: orderAPI)
        addressService = AddressService(addressAPI: addressAPI)
    }
}
