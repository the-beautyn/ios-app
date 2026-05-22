import Foundation

// MARK: - UserProfilePatch
//
// Domain value object for partial updates to the current user. Each property
// is optional; `nil` means "leave this field alone". Only fields that the user
// actually changed should be set — the data layer encodes those, and only
// those, into the PATCH body.

struct UserProfilePatch: Equatable {
    var name: String?
    var secondName: String?
    var phone: String?
    var birthDate: Date?
    var city: String?
    var sex: Sex?
    var avatarUrl: String?

    var isEmpty: Bool {
        name == nil
            && secondName == nil
            && phone == nil
            && birthDate == nil
            && city == nil
            && sex == nil
            && avatarUrl == nil
    }
}
