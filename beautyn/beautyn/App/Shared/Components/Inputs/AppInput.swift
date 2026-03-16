import SwiftUI

// MARK: - Shared metrics (private)
//
// Matches Figma "Beautyn / Input" component set (node 1:13139).
// Four types: Text · Password · Phone · Code
// Six states: Default · Typing · Filled · Show · Validate(error) · Disabled

private enum InputMetrics {
    static let cornerRadius: CGFloat = 12
    static let paddingH:     CGFloat = 14
    static let paddingV:     CGFloat = 16
    static let codeSize:     CGFloat = 50
    static let codeSpacing:  CGFloat = 12
    static let hintSpacing:  CGFloat = 4
}

// MARK: - Shared colors (private)

private extension Color {
    static func inputBorder(hasError: Bool) -> Color {
        hasError
            ? Color(hex: "#FA4655")                     // error border
            : Color(hex: "#A6B7C9").opacity(0.20)       // default / disabled / filled
    }
    static let inputCaret       = Color(hex: "#5A483A")
    static let inputPlaceholder = Color(hex: "#898887")
    static let inputText        = Color(hex: "#000000")
    static let inputError       = Color(hex: "#E8414F")
}

// MARK: - Shared modifiers (private)

private extension View {
    /// Standard text styling for field content.
    func inputTextStyle() -> some View {
        font(.App.footnote)
            .foregroundStyle(Color.inputText)
            .tint(Color.inputCaret)
    }

    /// Applies padding + 1 pt border overlay.
    func inputContainer(hasError: Bool) -> some View {
        padding(.horizontal, InputMetrics.paddingH)
            .padding(.vertical, InputMetrics.paddingV)
            .overlay {
                RoundedRectangle(cornerRadius: InputMetrics.cornerRadius, style: .continuous)
                    .stroke(Color.inputBorder(hasError: hasError), lineWidth: 1)
            }
    }

    /// Conditionally applies a transform — used for optional modifiers.
    @ViewBuilder
    func applyIf<V: View>(_ condition: Bool, transform: (Self) -> V) -> some View {
        if condition { transform(self) } else { self }
    }
}

// MARK: - Placeholder (private)

private struct InputPlaceholder: View {
    let text: String
    var body: some View {
        Text(text)
            .font(.App.footnote)
            .foregroundStyle(Color.inputPlaceholder)
            .allowsHitTesting(false)
    }
}

// MARK: - Hint row (private)

private struct InputHintRow: View {
    let message: String
    var body: some View {
        HStack(alignment: .top, spacing: 4) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 11))
                .foregroundStyle(Color.inputError)
                .frame(width: 16, height: 16)
            Text(message)
                .font(.system(size: 12))
                .foregroundStyle(Color.inputError)
                .fixedSize(horizontal: false, vertical: true)
            Spacer(minLength: 0)
        }
    }
}

// MARK: ─────────────────────────────────────────────────────────────────────
// MARK: 1. AppTextField — plain text (email, name, search…)
// MARK: ─────────────────────────────────────────────────────────────────────

struct AppTextField: View {

    let placeholder: String
    @Binding var text: String
    var errorMessage: String?       = nil
    var keyboardType: UIKeyboardType = .default
    var textContentType: UITextContentType? = nil
    var isDisabled: Bool            = false

    var body: some View {
        VStack(alignment: .leading, spacing: InputMetrics.hintSpacing) {
            ZStack(alignment: .leading) {
                if text.isEmpty {
                    InputPlaceholder(text: placeholder)
                }
                fieldView
            }
            .inputContainer(hasError: errorMessage != nil)
            .disabled(isDisabled)
            .opacity(isDisabled ? 0.4 : 1.0)

            if let error = errorMessage {
                InputHintRow(message: error)
            }
        }
    }

    @ViewBuilder
    private var fieldView: some View {
        let base = TextField("", text: $text)
            .inputTextStyle()
            .keyboardType(keyboardType)

        if let ct = textContentType {
            base.textContentType(ct)
        } else {
            base
        }
    }
}

// MARK: ─────────────────────────────────────────────────────────────────────
// MARK: 2. AppSecureField — password with show/hide toggle
// MARK: ─────────────────────────────────────────────────────────────────────

struct AppSecureField: View {

    let placeholder: String
    @Binding var text: String
    var errorMessage: String? = nil
    var isDisabled: Bool      = false

    @State  private var isRevealed = false
    @FocusState private var isFocused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: InputMetrics.hintSpacing) {
            HStack(spacing: 6) {
                ZStack(alignment: .leading) {
                    if text.isEmpty {
                        InputPlaceholder(text: placeholder)
                    }
                    Group {
                        if isRevealed {
                            TextField("", text: $text)
                        } else {
                            SecureField("", text: $text)
                        }
                    }
                    .inputTextStyle()
                    .focused($isFocused)
                }

                Button {
                    let wasFocused = isFocused
                    isRevealed.toggle()
                    if wasFocused {
                        // Re-focus after swapping TextField ↔ SecureField
                        DispatchQueue.main.async { isFocused = true }
                    }
                } label: {
                    Image(systemName: isRevealed ? "eye" : "eye.slash")
                        .font(.system(size: 13))
                        .foregroundStyle(Color.inputPlaceholder)
                        .frame(width: 20, height: 18)
                }
                .buttonStyle(.plain)
            }
            .inputContainer(hasError: errorMessage != nil)
            .disabled(isDisabled)
            .opacity(isDisabled ? 0.4 : 1.0)

            if let error = errorMessage {
                InputHintRow(message: error)
            }
        }
    }
}

// MARK: ─────────────────────────────────────────────────────────────────────
// MARK: 3. AppPhoneField — phone number with tappable country-code prefix
// MARK: ─────────────────────────────────────────────────────────────────────

struct AppPhoneField: View {

    var countryCode: String = "+38"
    @Binding var text: String
    var errorMessage: String?        = nil
    var isDisabled: Bool             = false
    /// Called when the user taps the country-code prefix (show a picker).
    var onCountryCodeTap: (() -> Void)? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: InputMetrics.hintSpacing) {
            HStack(spacing: 12) {
                // Country code + chevron
                Button { onCountryCodeTap?() } label: {
                    HStack(spacing: 8) {
                        Text(countryCode)
                            .font(.App.footnote)
                            .foregroundStyle(Color.inputText)
                        Image(systemName: "chevron.down")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundStyle(Color.inputPlaceholder)
                    }
                }
                .buttonStyle(.plain)
                .fixedSize()

                // Vertical divider
                Rectangle()
                    .fill(Color(hex: "#A6B7C9").opacity(0.20))
                    .frame(width: 1, height: 18)

                // Phone number
                ZStack(alignment: .leading) {
                    if text.isEmpty {
                        InputPlaceholder(text: Localization.inputPhonePlaceholder)
                    }
                    TextField("", text: $text)
                        .inputTextStyle()
                        .keyboardType(.phonePad)
                        .textContentType(.telephoneNumber)
                }
            }
            .inputContainer(hasError: errorMessage != nil)
            .disabled(isDisabled)
            .opacity(isDisabled ? 0.4 : 1.0)

            if let error = errorMessage {
                InputHintRow(message: error)
            }
        }
    }
}

// MARK: ─────────────────────────────────────────────────────────────────────
// MARK: 4. AppCodeField — OTP / PIN with individual digit cells
// MARK: ─────────────────────────────────────────────────────────────────────

struct AppCodeField: View {

    /// The full numeric string (e.g. "1234").  Automatically clamped to `length`.
    @Binding var code: String
    var length: Int        = 4
    var errorMessage: String? = nil

    @FocusState private var isFocused: Bool

    private var digits: [String] {
        let chars = Array(code.prefix(length))
        return (0..<length).map { i in i < chars.count ? String(chars[i]) : "" }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: InputMetrics.hintSpacing) {
            ZStack {
                // Hidden field — sole source of truth for keyboard input
                TextField("", text: Binding(
                    get: { code },
                    set: { code = String($0.filter(\.isNumber).prefix(length)) }
                ))
                .keyboardType(.numberPad)
                .textContentType(.oneTimeCode)
                .focused($isFocused)
                .opacity(0)
                .frame(maxWidth: 0, maxHeight: 0)
                .allowsHitTesting(false)

                // Visual cells
                HStack(spacing: InputMetrics.codeSpacing) {
                    ForEach(0..<length, id: \.self) { index in
                        codeCell(at: index)
                    }
                }
            }
            .contentShape(Rectangle())
            .onTapGesture { isFocused = true }

            if let error = errorMessage {
                InputHintRow(message: error)
            }
        }
    }

    private func codeCell(at index: Int) -> some View {
        // The "active" cell is the next empty slot while the field is focused
        let filled  = digits.prefix(index).allSatisfy { !$0.isEmpty }
        let isEmpty = digits[index].isEmpty
        let isActive = isFocused && isEmpty && filled

        return Text(digits[index])
            .font(.App.footnote)
            .foregroundStyle(Color.inputText)
            .frame(width: InputMetrics.codeSize, height: InputMetrics.codeSize)
            .overlay {
                RoundedRectangle(cornerRadius: InputMetrics.cornerRadius, style: .continuous)
                    .stroke(
                        isActive
                            ? Color.inputCaret
                            : Color.inputBorder(hasError: errorMessage != nil),
                        lineWidth: isActive ? 1.5 : 1
                    )
            }
    }
}

// MARK: - Preview

#if DEBUG
private struct InputPreviewRoot: View {

    @State private var email    = ""
    @State private var password = ""
    @State private var phone    = ""
    @State private var otp      = ""

    @State private var emailError:    String? = nil
    @State private var passwordError: String? = nil
    @State private var phoneError:    String? = nil
    @State private var otpError:      String? = nil

    var body: some View {
        ScrollView {
            VStack(spacing: CGFloat.Spacing.xl) {

                // ── Text ──────────────────────────────────────────────
                section("Text input") {
                    AppTextField(
                        placeholder: "Введить email",
                        text: $email,
                        errorMessage: emailError,
                        keyboardType: .emailAddress,
                        textContentType: .emailAddress
                    )
                    AppTextField(
                        placeholder: "Disabled",
                        text: .constant(""),
                        isDisabled: true
                    )
                    toggleError("Email error", message: "Не правильний логін або незареєстрований", error: $emailError)
                }

                // ── Password ─────────────────────────────────────────
                section("Password input") {
                    AppSecureField(
                        placeholder: "Введить пароль",
                        text: $password,
                        errorMessage: passwordError
                    )
                    toggleError("Password error", message: "Невірний пароль", error: $passwordError)
                }

                // ── Phone ─────────────────────────────────────────────
                section("Phone input") {
                    AppPhoneField(
                        text: $phone,
                        errorMessage: phoneError,
                        onCountryCodeTap: { print("show country picker") }
                    )
                    toggleError("Phone error", message: "Невірний код", error: $phoneError)
                }

                // ── Code ──────────────────────────────────────────────
                section("Code / OTP input") {
                    AppCodeField(
                        code: $otp,
                        errorMessage: otpError
                    )
                    Text("Value: \"\(otp)\"")
                        .font(.App.caption1)
                        .foregroundStyle(Color.App.gray2)
                    toggleError("OTP error", message: "Невірний код", error: $otpError)
                }
            }
            .padding(.horizontal, CGFloat.Spacing.md)
            .padding(.vertical, CGFloat.Spacing.xl)
        }
        .background(Color.App.backgroundLight)
    }

    @ViewBuilder
    private func section<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: CGFloat.Spacing.sm) {
            Text(title)
                .font(.App.headline)
                .foregroundStyle(Color.App.text)
            content()
        }
    }

    @ViewBuilder
    private func toggleError(_ label: String, message: String, error: Binding<String?>) -> some View {
        Button(label) {
            error.wrappedValue = error.wrappedValue == nil ? message : nil
        }
        .font(.App.caption1)
        .foregroundStyle(Color.App.red)
    }
}

#Preview("Inputs") {
    InputPreviewRoot()
}
#endif
