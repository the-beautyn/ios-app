import SwiftUI
import XCTest
@testable import beautyn

// MARK: - AuthViewRenderTests
//
// Renders all 8 authorization screens to PNG files for visual verification:
// Email Check, Login, Forgot Password, Sign Up, Phone Verification,
// Phone Code, Set New Password, Check Email Sent.
//
// Run:
//   xcodebuild test -scheme beautyn-Production \
//     -destination 'platform=iOS Simulator,name=iPhone 17 Pro' \
//     -only-testing:beautynTests/AuthViewRenderTests

@MainActor
final class AuthViewRenderTests: XCTestCase {

    // MARK: - 1. Email Check

    func testRenderEmailCheck() async throws {
        let viewModel = EmailCheckViewModel(
            transition: .init(
                didClose: {},
                didCheckEmail: { _, _ in },
                didTapAppleSignIn: {},
                didTapGoogleSignIn: {}
            ),
            checkEmailUseCase: MockCheckEmailUseCase()
        )
        let view = EmailCheckView(viewModel: viewModel)
        try await ViewRenderer.render(view, name: "auth_email_check")
    }

    func testRenderEmailCheckFilled() async throws {
        let viewModel = EmailCheckViewModel(
            transition: .init(
                didClose: {},
                didCheckEmail: { _, _ in },
                didTapAppleSignIn: {},
                didTapGoogleSignIn: {}
            ),
            checkEmailUseCase: MockCheckEmailUseCase()
        )
        viewModel.email = "anna@example.com"
        let view = EmailCheckView(viewModel: viewModel)
        try await ViewRenderer.render(view, name: "auth_email_check_filled")
    }

    // MARK: - 2. Login

    func testRenderLogin() async throws {
        let viewModel = LoginViewModel(
            email: "anna@example.com",
            transition: .init(
                didClose: {},
                didLogin: {},
                didTapForgotPassword: { _ in },
                didRequestPhoneVerification: {}
            ),
            loginUseCase: MockLoginUseCase()
        )
        let view = LoginView(viewModel: viewModel)
        try await ViewRenderer.render(view, name: "auth_login")
    }

    func testRenderLoginFilled() async throws {
        let viewModel = LoginViewModel(
            email: "anna@example.com",
            transition: .init(
                didClose: {},
                didLogin: {},
                didTapForgotPassword: { _ in },
                didRequestPhoneVerification: {}
            ),
            loginUseCase: MockLoginUseCase()
        )
        viewModel.password = "mypassword"
        let view = LoginView(viewModel: viewModel)
        try await ViewRenderer.render(view, name: "auth_login_filled")
    }

    // MARK: - 3. Forgot Password

    func testRenderForgotPassword() async throws {
        let viewModel = ForgotPasswordViewModel(
            email: "anna@example.com",
            transition: .init(didClose: {}, didSendResetEmail: {}),
            forgotPasswordUseCase: MockForgotPasswordUseCase()
        )
        let view = ForgotPasswordView(viewModel: viewModel)
        try await ViewRenderer.render(view, name: "auth_forgot_password")
    }

    // MARK: - 4. Sign Up

    func testRenderSignUp() async throws {
        let viewModel = SignUpViewModel(
            email: "anna@example.com",
            transition: .init(
                didClose: {},
                didRegister: {},
                didRequestPhoneVerification: {}
            ),
            registerUseCase: MockRegisterUseCase()
        )
        let view = SignUpView(viewModel: viewModel)
        try await ViewRenderer.render(view, name: "auth_sign_up")
    }

    func testRenderSignUpFilled() async throws {
        let viewModel = SignUpViewModel(
            email: "anna@example.com",
            transition: .init(
                didClose: {},
                didRegister: {},
                didRequestPhoneVerification: {}
            ),
            registerUseCase: MockRegisterUseCase()
        )
        viewModel.firstName = "Анна"
        viewModel.lastName = "Коваленко"
        viewModel.password = "mypassword"
        let view = SignUpView(viewModel: viewModel)
        try await ViewRenderer.render(view, name: "auth_sign_up_filled")
    }

    // MARK: - 5. Phone Verification

    func testRenderPhoneVerification() async throws {
        let viewModel = PhoneVerificationViewModel(
            transition: .init(didClose: {}, didSendCode: { _ in }),
            sendPhoneOTPUseCase: MockSendPhoneOTPUseCase()
        )
        let view = PhoneVerificationView(viewModel: viewModel)
        try await ViewRenderer.render(view, name: "auth_phone_verification")
    }

    func testRenderPhoneVerificationFilled() async throws {
        let viewModel = PhoneVerificationViewModel(
            transition: .init(didClose: {}, didSendCode: { _ in }),
            sendPhoneOTPUseCase: MockSendPhoneOTPUseCase()
        )
        viewModel.phoneNumber = "501234567"
        let view = PhoneVerificationView(viewModel: viewModel)
        try await ViewRenderer.render(view, name: "auth_phone_verification_filled")
    }

    func testRenderPhoneVerificationPrefilled() async throws {
        let viewModel = PhoneVerificationViewModel(
            transition: .init(didClose: {}, didSendCode: { _ in }),
            sendPhoneOTPUseCase: MockSendPhoneOTPUseCase(),
            initialPhone: "+380501234567"
        )
        let view = PhoneVerificationView(viewModel: viewModel)
        try await ViewRenderer.render(view, name: "auth_phone_verification_prefilled")
    }

    // MARK: - 6. Phone Code

    func testRenderPhoneCode() async throws {
        let viewModel = PhoneCodeViewModel(
            phone: "+380501234567",
            transition: .init(
                didClose: {},
                didVerifyPhone: {},
                didTapChangeNumber: {}
            ),
            verifyPhoneOTPUseCase: MockVerifyPhoneOTPUseCase(),
            sendPhoneOTPUseCase: MockSendPhoneOTPUseCase()
        )
        let view = PhoneCodeView(viewModel: viewModel)
        try await ViewRenderer.render(view, name: "auth_phone_code")
    }

    func testRenderPhoneCodePartial() async throws {
        let viewModel = PhoneCodeViewModel(
            phone: "+380501234567",
            transition: .init(
                didClose: {},
                didVerifyPhone: {},
                didTapChangeNumber: {}
            ),
            verifyPhoneOTPUseCase: MockVerifyPhoneOTPUseCase(),
            sendPhoneOTPUseCase: MockSendPhoneOTPUseCase()
        )
        viewModel.code = "12"
        let view = PhoneCodeView(viewModel: viewModel)
        try await ViewRenderer.render(view, name: "auth_phone_code_partial")
    }

    // MARK: - 7. Set New Password

    func testRenderSetNewPassword() async throws {
        let viewModel = SetNewPasswordViewModel(
            email: "helga.altuhova@gmail.com",
            code: "mock-code",
            transition: .init(didResetPassword: {}),
            resetPasswordUseCase: MockResetPasswordUseCase(),
            forgotPasswordUseCase: MockForgotPasswordUseCase()
        )
        let view = SetNewPasswordView(viewModel: viewModel)
        try await ViewRenderer.render(view, name: "auth_set_new_password")
    }

    func testRenderSetNewPasswordFilled() async throws {
        let viewModel = SetNewPasswordViewModel(
            email: "helga.altuhova@gmail.com",
            code: "mock-code",
            transition: .init(didResetPassword: {}),
            resetPasswordUseCase: MockResetPasswordUseCase(),
            forgotPasswordUseCase: MockForgotPasswordUseCase()
        )
        viewModel.newPassword = "NewPassword1"
        viewModel.confirmPassword = "NewPassword1"
        let view = SetNewPasswordView(viewModel: viewModel)
        try await ViewRenderer.render(view, name: "auth_set_new_password_filled")
    }

    // MARK: - 8. Check Email Sent

    func testRenderCheckEmailSent() async throws {
        let viewModel = CheckEmailSentViewModel(
            email: "anna@example.com",
            transition: .init(didClose: {})
        )
        let view = CheckEmailSentView(viewModel: viewModel)
        try await ViewRenderer.render(view, name: "auth_check_email_sent")
    }
}

// MARK: - Mock Use Cases

private final class MockCheckEmailUseCase: CheckEmailUseCase {
    func execute(email: String) async throws -> EmailStatus {
        .password
    }
}

private final class MockLoginUseCase: LoginUseCase {
    func execute(email: String, password: String) async throws -> AuthSession {
        AuthSession(accessToken: "mock", refreshToken: "mock", expiresIn: 900, phoneVerificationRequired: false)
    }
}

private final class MockForgotPasswordUseCase: ForgotPasswordUseCase {
    func execute(email: String) async throws {}
}

private final class MockRegisterUseCase: RegisterUseCase {
    func execute(email: String, password: String, name: String, secondName: String) async throws -> AuthSession {
        AuthSession(accessToken: "mock", refreshToken: "mock", expiresIn: 900, phoneVerificationRequired: true)
    }
}

private final class MockSendPhoneOTPUseCase: SendPhoneOTPUseCase {
    func execute(phone: String) async throws {}
}

private final class MockVerifyPhoneOTPUseCase: VerifyPhoneOTPUseCase {
    func execute(phone: String, code: String) async throws -> Bool {
        true
    }
}

private final class MockResetPasswordUseCase: ResetPasswordUseCase {
    func execute(token: String, newPassword: String) async throws {}
}
