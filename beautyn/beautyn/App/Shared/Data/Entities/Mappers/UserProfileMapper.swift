import Foundation

// MARK: - UserProfileMapper

enum UserProfileMapper {

    static func map(_ dto: UserProfileDTO) -> UserProfile {
        UserProfile(
            id: dto.id,
            email: dto.email,
            role: dto.role,
            name: dto.name,
            secondName: dto.secondName,
            phone: dto.phone,
            avatarUrl: dto.avatarUrl,
            birthDate: dto.birthDate.flatMap(birthDateFormatter.date(from:)),
            city: dto.city,
            sex: dto.sex.flatMap(Sex.init(rawValue:)),
            authProvider: dto.authProvider,
            isPhoneVerified: dto.isPhoneVerified,
            isProfileCreated: dto.isProfileCreated
        )
    }

    private static let birthDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
}
