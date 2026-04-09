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
            authProvider: dto.authProvider,
            isPhoneVerified: dto.isPhoneVerified,
            isProfileCreated: dto.isProfileCreated,
            isOnboardingCompleted: dto.isOnboardingCompleted
        )
    }
}
