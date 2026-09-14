import Foundation
import NetworkPackage

enum ProfileMapper {
    static func mapProfile(_ dto: UserProfileDTO) -> User {
        User(
            name: dto.name,
            phone: dto.phone,
            birthday: dto.birthday,
            imageUrl: dto.imageUrl
        )
    }
}
