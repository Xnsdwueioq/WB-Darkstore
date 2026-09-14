import Foundation
import NetworkPackage

@MainActor
public protocol UserServicing: AnyObject {
    var addresses: [IdentifiableAddress] { get }
    var orders: [Order] { get }
    var errorMessage: String? { get }

    func currentUserName() async -> String
    func getAddresses() async
    func addAddress(_ address: Address) async -> Bool
    func updateAddress(id: String, _ address: Address) async -> Bool
    func deleteAddress(id: String) async
    func clearErrorMessage()
    func getOrders() async
    func getProfileInfo() async -> User
    func editProfile(_ user: User) async -> Bool
    func logout() async -> Bool
    func deleteAccount() async -> Bool
    func getActiveOrder() async -> Order?
}

@Observable
@MainActor
public final class UserService: UserServicing {
    public var addresses: [IdentifiableAddress] = []
    public var orders: [Order] = []
    public var errorMessage: String?

    private let profileAPI: any ProfileAPIProtocol
    private let addressAPI: any AddressAPIProtocol
    private let orderAPI: any OrderAPIProtocol

    public init(
        profileAPI: any ProfileAPIProtocol,
        addressAPI: any AddressAPIProtocol,
        orderAPI: any OrderAPIProtocol
    ) {
        self.profileAPI = profileAPI
        self.addressAPI = addressAPI
        self.orderAPI = orderAPI
    }

    public func currentUserName() async -> String {
        do {
            let profileDTO = try await profileAPI.fetchProfile()
            clearErrorMessage()
            return profileDTO.name
        } catch let error as NetworkError {
            self.errorMessage = error.localizedDescription
        } catch {
            self.errorMessage = "Ошибка сети: \(error.localizedDescription)"
        }
        return "Гость"
    }

    public func getProfileInfo() async -> User {
        do {
            let profileDTO = try await profileAPI.fetchProfile()
            clearErrorMessage()
            return ProfileMapper.mapProfile(profileDTO)
        } catch let error as NetworkError {
            self.errorMessage = error.localizedDescription
        } catch {
            self.errorMessage = "Ошибка сети: \(error.localizedDescription)"
        }
        return User(name: "noname", phone: "", birthday: "")
    }

    public func getAddresses() async {
        do {
            let addressDTOs = try await addressAPI.fetchAddresses()
            addresses = AddressMapper.mapIdentifiedAddresses(addressDTOs)
            clearErrorMessage()
        } catch let error as NetworkError {
            self.errorMessage = error.localizedDescription
        } catch {
            self.errorMessage = "Ошибка сети: \(error.localizedDescription)"
        }
    }

    public func addAddress(_ address: Address) async -> Bool {
        do {
            let dto = AddressMapper.toDTO(address)
            try await addressAPI.addAddress(dto)
            await getAddresses()
            return true
        } catch let error as NetworkError {
            self.errorMessage = error.localizedDescription
        } catch {
            self.errorMessage = "Ошибка сети: \(error.localizedDescription)"
        }
        return false
    }

    public func updateAddress(id: String, _ address: Address) async -> Bool {
        do {
            let dto = AddressMapper.toDTO(address)
            try await addressAPI.updateAddress(id: id, address: dto)
            await getAddresses()
            return true
        } catch let error as NetworkError {
            self.errorMessage = error.localizedDescription
        } catch {
            self.errorMessage = "Ошибка сети: \(error.localizedDescription)"
        }
        return false
    }

    public func deleteAddress(id: String) async {
        do {
            try await addressAPI.deleteAddress(id: id)
            await getAddresses()
        } catch let error as NetworkError {
            self.errorMessage = error.localizedDescription
        } catch {
            self.errorMessage = "Ошибка сети: \(error.localizedDescription)"
        }
    }

    public func clearErrorMessage() {
        if errorMessage != nil {
            errorMessage = nil
        }
    }

    public func getOrders() async {
        do {
            let orderDTOs = try await orderAPI.fetchOrders()
            orders = OrderMapper.mapOrders(orderDTOs)
            clearErrorMessage()
        } catch let error as NetworkError {
            self.errorMessage = error.localizedDescription
        } catch {
            self.errorMessage = "Ошибка сети: \(error.localizedDescription)"
        }
    }

    public func editProfile(_ user: User) async -> Bool {
        do {
            try await profileAPI.updateProfile(name: user.name, birthday: user.birthday, imageURI: "")
            clearErrorMessage()
            return true
        } catch let error as NetworkError {
            self.errorMessage = error.localizedDescription
        } catch {
            self.errorMessage = "Ошибка сети: \(error.localizedDescription)"
        }
        return false
    }

    public func logout() async -> Bool {
        do {
            try await profileAPI.logout()
            clearErrorMessage()
            return true
        } catch let error as NetworkError {
            self.errorMessage = error.localizedDescription
        } catch {
            self.errorMessage = "Ошибка сети: \(error.localizedDescription)"
        }
        return false
    }

    public func deleteAccount() async -> Bool {
        do {
            try await profileAPI.deleteAccount()
            clearErrorMessage()
            return true
        } catch let error as NetworkError {
            self.errorMessage = error.localizedDescription
        } catch {
            self.errorMessage = "Ошибка сети: \(error.localizedDescription)"
        }
        return false
    }

    public func getActiveOrder() async -> Order? {
        if orders.isEmpty {
            await getOrders()
        }
        return orders.first(where: { $0.status == .active })
    }
}
