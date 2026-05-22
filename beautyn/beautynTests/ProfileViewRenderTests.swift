import SwiftUI
import XCTest
@testable import beautyn

// MARK: - ProfileViewRenderTests
//
// Renders the Profile screen to a PNG file for visual verification against
// Figma node 1:8552.
//
// Run:
//   xcodebuild test -scheme beautyn-Production \
//     -destination 'platform=iOS Simulator,name=iPhone 17 Pro Max' \
//     -only-testing:beautynTests/ProfileViewRenderTests

@MainActor
final class ProfileViewRenderTests: XCTestCase {

    func testRenderProfile() async throws {
        let view = ProfileView(viewModel: self.makeViewModel())
        try await ViewRenderer.render(view, name: "profile")
    }

    // MARK: - Helpers

    private func makeViewModel() -> ProfileViewModel {
        ProfileViewModel(
            transition: .init(
                didTapPersonalData: {},
                didTapSavedSalons: {},
                didTapSettings: {},
                didTapLanguage: {}
            ),
            getCurrentUserUseCase: MockGetCurrentUserUseCase(),
            getUserSettingsUseCase: MockGetUserSettingsUseCase(),
            updateNotificationSettingsUseCase: MockUpdateNotificationSettingsUseCase()
        )
    }
}

// MARK: - Mocks

private final class MockGetCurrentUserUseCase: GetCurrentUserUseCase {
    func execute() async throws -> UserProfile {
        throw URLError(.userAuthenticationRequired)
    }
}

private final class MockGetUserSettingsUseCase: GetUserSettingsUseCase {
    func execute() async throws -> UserSettings {
        UserSettings(
            notifications: NotificationSettings(
                pushEnabled: true,
                emailEnabled: true,
                smsEnabled: true
            )
        )
    }
}

private final class MockUpdateNotificationSettingsUseCase: UpdateNotificationSettingsUseCase {
    func execute(
        pushEnabled: Bool?,
        emailEnabled: Bool?,
        smsEnabled: Bool?
    ) async throws -> UserSettings {
        UserSettings(
            notifications: NotificationSettings(
                pushEnabled: pushEnabled ?? true,
                emailEnabled: emailEnabled ?? true,
                smsEnabled: smsEnabled ?? true
            )
        )
    }
}
