import Foundation

// MARK: - UserProfilePatchDTO
//
// Mirrors the backend `UpdateUserDto` (snake_case). Only fields with a non-nil
// value are encoded — the controller treats absent keys as "leave alone" and
// `null` as "set to null", so we must omit untouched fields entirely.

struct UserProfilePatchDTO: Encodable {
    let name: String?
    let secondName: String?
    let phone: String?
    let birthDate: String?
    let city: String?
    let sex: String?
    let avatarUrl: String?

    enum CodingKeys: String, CodingKey {
        case name
        case secondName = "second_name"
        case phone
        case birthDate = "birth_date"
        case city
        case sex
        case avatarUrl = "avatar_url"
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(name, forKey: .name)
        try container.encodeIfPresent(secondName, forKey: .secondName)
        try container.encodeIfPresent(phone, forKey: .phone)
        try container.encodeIfPresent(birthDate, forKey: .birthDate)
        try container.encodeIfPresent(city, forKey: .city)
        try container.encodeIfPresent(sex, forKey: .sex)
        try container.encodeIfPresent(avatarUrl, forKey: .avatarUrl)
    }
}
