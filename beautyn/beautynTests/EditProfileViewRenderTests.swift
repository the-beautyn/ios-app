import SwiftUI
import XCTest
@testable import beautyn

// MARK: - EditProfileViewRenderTests
//
// Renders the Edit Profile screen against Figma node 1:8605.
//
// Run:
//   xcodebuild test -scheme beautyn-Production \
//     -destination 'platform=iOS Simulator,name=iPhone 17 Pro Max' \
//     -only-testing:beautynTests/EditProfileViewRenderTests

@MainActor
final class EditProfileViewRenderTests: XCTestCase {

    func testRenderEditProfile() async throws {
        let view = EditProfileView(viewModel: self.makeViewModel())
        try await ViewRenderer.render(view, name: "edit_profile")
    }

    // MARK: - Helpers

    private func makeViewModel() -> EditProfileViewModel {
        EditProfileViewModel(
            transition: .init(
                didFinishEditing: {},
                didChangePhone: { _ in }
            ),
            getCurrentUserUseCase: MockEditProfileGetCurrentUserUseCase(),
            updateUserProfileUseCase: MockEditProfileUpdateUserProfileUseCase()
        )
    }
}

// MARK: - Mocks

private final class MockEditProfileGetCurrentUserUseCase: GetCurrentUserUseCase {
    func execute() async throws -> UserProfile {
        var components = DateComponents()
        components.year = 2002
        components.month = 2
        components.day = 18
        let birth = Calendar(identifier: .gregorian).date(from: components)

        return UserProfile(
            id: "preview",
            email: "olga@example.com",
            role: "client",
            name: "Ольга",
            secondName: "Алтухова",
            phone: "+380506314634",
            avatarUrl: nil,
            birthDate: birth,
            city: "Львів",
            sex: .female,
            authProvider: "credentials",
            isPhoneVerified: true,
            isProfileCreated: true,
            isOnboardingCompleted: true
        )
    }
}

private final class MockEditProfileUpdateUserProfileUseCase: UpdateUserProfileUseCase {
    func execute(_ patch: UserProfilePatch) async throws -> UserProfile {
        try await MockEditProfileGetCurrentUserUseCase().execute()
    }
}
