protocol AuthServicing {
    func login(username: String, password: String) -> Bool
}

final class AuthService: AuthServicing {
    func login(username: String, password: String) -> Bool {
        !username.isEmpty && !password.isEmpty
    }
}
