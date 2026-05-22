import SwiftUI
import XCTest
@testable import beautyn

// MARK: - ProfileSettingsViewRenderTests
//
// Renders the Profile Settings screen against Figma node 1:8647.
//
// Run:
//   xcodebuild test -scheme beautyn-Production \
//     -destination 'platform=iOS Simulator,name=iPhone 17 Pro Max' \
//     -only-testing:beautynTests/ProfileSettingsViewRenderTests

@MainActor
final class ProfileSettingsViewRenderTests: XCTestCase {

    func testRenderProfileSettings() async throws {
        let view = ProfileSettingsView(viewModel: self.makeViewModel())
        try await ViewRenderer.render(view, name: "profile_settings")
    }

    // MARK: - Helpers

    private func makeViewModel() -> ProfileSettingsViewModel {
        ProfileSettingsViewModel(
            transition: .init(
                didTapChangePassword: {},
                didLogout: {},
                didDeleteAccount: {}
            ),
            logoutUseCase: MockLogoutUseCase(),
            deleteAccountUseCase: MockDeleteAccountUseCase()
        )
    }
}

// MARK: - Mocks

private final class MockLogoutUseCase: LogoutUseCase {
    func execute() async {}
}

private final class MockDeleteAccountUseCase: DeleteAccountUseCase {
    func execute() async throws {}
}
