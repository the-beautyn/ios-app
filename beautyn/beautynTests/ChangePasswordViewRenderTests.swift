import SwiftUI
import XCTest
@testable import beautyn

// MARK: - ChangePasswordViewRenderTests
//
// Renders the Change Password screen against Figma nodes 1:8679 (empty)
// and 1:8708 (filled). Toolbar (back + checkmark) lives in
// `ChangePasswordController` (UIKit) and is not part of these renders.
//
// Run:
//   xcodebuild test -scheme beautyn-Production \
//     -destination 'platform=iOS Simulator,name=iPhone 17 Pro Max' \
//     -only-testing:beautynTests/ChangePasswordViewRenderTests

@MainActor
final class ChangePasswordViewRenderTests: XCTestCase {

    func testRenderChangePasswordEmpty() async throws {
        let view = ChangePasswordView(viewModel: self.makeViewModel())
        try await ViewRenderer.render(view, name: "change_password_empty")
    }

    func testRenderChangePasswordFilled() async throws {
        let viewModel = self.makeViewModel()
        viewModel.oldPassword = "OldPassw0rd"
        viewModel.newPassword = "NewPassw0rd"
        viewModel.confirmPassword = "NewPassw0rd"
        let view = ChangePasswordView(viewModel: viewModel)
        try await ViewRenderer.render(view, name: "change_password_filled")
    }

    func testRenderChangePasswordSameAsOld() async throws {
        let viewModel = self.makeViewModel()
        viewModel.oldPassword = "SamePassw0rd"
        viewModel.newPassword = "SamePassw0rd"
        viewModel.confirmPassword = ""
        try await Task.sleep(nanoseconds: 50_000_000)
        let view = ChangePasswordView(viewModel: viewModel)
        try await ViewRenderer.render(view, name: "change_password_same_as_old")
    }

    // MARK: - Helpers

    private func makeViewModel() -> ChangePasswordViewModel {
        ChangePasswordViewModel(
            transition: .init(didFinishChanging: {}),
            changePasswordUseCase: MockChangePasswordUseCase()
        )
    }
}

// MARK: - Mocks

private final class MockChangePasswordUseCase: ChangePasswordUseCase {
    func execute(currentPassword: String, newPassword: String) async throws {}
}
