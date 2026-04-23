import Foundation

// MARK: - PasswordValidator

enum PasswordValidator {

    /// Validates password complexity.
    /// Returns `nil` if valid, or the first failing rule's localized message.
    static func validate(_ password: String) -> String? {
        if !password.allSatisfy({ $0.isASCII && !$0.isNewline }) {
            return Localization.validationPasswordLatinOnly
        }
        if password.count < 8 {
            return Localization.validationPasswordMinLength
        }
        if password.count > 50 {
            return Localization.validationPasswordMaxLength
        }
        if password.rangeOfCharacter(from: .uppercaseLetters) == nil {
            return Localization.validationPasswordUppercase
        }
        if password.rangeOfCharacter(from: .lowercaseLetters) == nil {
            return Localization.validationPasswordLowercase
        }
        if password.rangeOfCharacter(from: .decimalDigits) == nil {
            return Localization.validationPasswordDigit
        }
        return nil
    }
}
