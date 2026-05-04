import Foundation

// MARK: - UserProfilePatchMapper
//
// Converts a domain `UserProfilePatch` into the snake_case `UserProfilePatchDTO`
// the backend expects. Birth date is serialized as `yyyy-MM-dd` to match the
// backend's `@IsISO8601({ strict: true }) @Matches(/^\d{4}-\d{2}-\d{2}$/)`.

enum UserProfilePatchMapper {

    static func map(_ patch: UserProfilePatch) -> UserProfilePatchDTO {
        UserProfilePatchDTO(
            name: patch.name,
            secondName: patch.secondName,
            phone: patch.phone,
            birthDate: patch.birthDate.map(birthDateFormatter.string(from:)),
            city: patch.city,
            sex: patch.sex?.rawValue,
            avatarUrl: patch.avatarUrl
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
