//
//  CompositionRoot.swift
//  WBDarkstore
//
//  Created by Valeriy Solovey on 04.09.2026.
//

import BusinessLogic
import NetworkPackage
import Foundation
import Core

public struct CompositionRoot {
    public init(token: String) throws {
        let apiClient = APIClient(serverURL: URL(string: "https://eat-and-pay.t02.ru")!, token: token)

        let addressAPI = AddressAPI(apiClient: apiClient)
        let cartAPI = CartAPI(apiClient: apiClient)
        let catalogAPI = CatalogAPI(apiClient: apiClient)
        let orderAPI = OrderAPI(apiClient: apiClient)
        let productAPI = ProductAPI(apiClient: apiClient)
        let profileAPI = ProfileAPI(apiClient: apiClient)

        ServiceLocator.shared.register(service: AddressService(addressAPI: addressAPI) as AddressServiceProtocol)
        ServiceLocator.shared.register(service: CartService(cartAPI: cartAPI) as CartServiceProtocol)
        ServiceLocator.shared.register(service: CatalogService(api: catalogAPI) as CatalogServiceProtocol)
        ServiceLocator.shared.register(service: OrderService(orderAPI: orderAPI) as OrderServiceProtocol)
        ServiceLocator.shared.register(service: ProductService(productAPI: productAPI) as ProductServiceProtocol)
        ServiceLocator.shared.register(service: ProfileService(profileAPI: profileAPI) as ProfileServiceProtocol)
    }
}
