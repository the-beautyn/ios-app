import Foundation
import Combine

// MARK: - EditProfileViewModel

@MainActor
final class EditProfileViewModel: BaseViewModel {

    // MARK: - Transition

    struct Transition {
        let didFinishEditing: () -> Void
    }

    // MARK: - Published

    @Published var name: String = ""
    @Published var secondName: String = ""
    @Published var phoneDigits: String = ""
    @Published var birthDate: Date?
    @Published var city: String?
    @Published var sex: Sex?

    @Published var isDateSheetPresented: Bool = false
    @Published var isCitySheetPresented: Bool = false
    @Published var isSexDialogPresented: Bool = false
    @Published var isPhoneChangeAlertPresented: Bool = false

    // MARK: - Constants

    let countryCode: String = "+380"

    // MARK: - Snapshot for change detection

    private struct Snapshot: Equatable {
        var name: String
        var secondName: String
        var phoneDigits: String
        var birthDate: Date?
        var city: String
        var sex: Sex?
    }

    private var snapshot: Snapshot = .init(
        name: "", secondName: "", phoneDigits: "", birthDate: nil, city: "", sex: nil
    )

    // MARK: - Dependencies

    private let transition: Transition
    private let getCurrentUserUseCase: any GetCurrentUserUseCase
    private let updateUserProfileUseCase: any UpdateUserProfileUseCase

    // MARK: - Init

    init(
        transition: Transition,
        getCurrentUserUseCase: any GetCurrentUserUseCase,
        updateUserProfileUseCase: any UpdateUserProfileUseCase
    ) {
        self.transition = transition
        self.getCurrentUserUseCase = getCurrentUserUseCase
        self.updateUserProfileUseCase = updateUserProfileUseCase
        super.init()
    }

    // MARK: - Lifecycle

    override func onViewTask() async {
        await loadProfile()
    }

    // MARK: - Computed

    var hasChanges: Bool {
        currentSnapshot() != snapshot
    }

    var isPhoneValid: Bool {
        // Allow empty (initial untouched) or exactly 9 digits (UA mobile).
        phoneDigits.isEmpty || phoneDigits.count == 9
    }

    /// Inline error for the phone field. `nil` while the field is empty so
    /// the error doesn't show on a freshly opened, blank profile.
    var phoneError: String? {
        guard !phoneDigits.isEmpty, !isPhoneValid else { return nil }
        return Localization.validationInvalidPhone
    }

    var canSubmit: Bool {
        hasChanges && isPhoneValid && !isLoading
    }

    // MARK: - Intents

    func didTapBirthDate() { isDateSheetPresented = true }
    func didTapCity()      { isCitySheetPresented = true }
    func didTapSex()       { isSexDialogPresented = true }

    func didSelectBirthDate(_ date: Date) {
        birthDate = date
        isDateSheetPresented = false
    }

    func didSelectCity(_ value: String) {
        city = value
        isCitySheetPresented = false
    }

    func didDismissCitySheet() {
        isCitySheetPresented = false
    }

    func didSelectSex(_ value: Sex) {
        sex = value
        isSexDialogPresented = false
    }

    func sexDisplay(_ value: Sex?) -> String? {
        guard let value else { return nil }
        switch value {
        case .male:           return Localization.profileSexMale
        case .female:         return Localization.profileSexFemale
        case .other:          return Localization.profileSexOther
        case .preferNotToSay: return Localization.profileSexPreferNotToSay
        }
    }

    func didTapConfirm() {
        guard canSubmit else { return }
        let patch = buildPatch()
        guard !patch.isEmpty else { return }

        // Server clears `is_phone_verified` when the patch carries a new phone
        // (see backend user.service.ts), so warn the user before submitting.
        if patch.phone != nil {
            isPhoneChangeAlertPresented = true
            return
        }

        submit(patch)
    }

    func confirmPhoneChange() {
        let patch = buildPatch()
        guard !patch.isEmpty else { return }
        submit(patch)
    }

    private func submit(_ patch: UserProfilePatch) {
        Task { [weak self] in
            guard let self else { return }
            self.showLoader()
            defer { self.hideLoader() }
            do {
                _ = try await self.updateUserProfileUseCase.execute(patch)
                self.transition.didFinishEditing()
            } catch {
                self.showError(error)
            }
        }
    }

    // MARK: - Phone digit handling

    func updatePhoneDigits(_ raw: String) {
        // Keep only digits; length is enforced by `isPhoneValid` rather than
        // a silent truncation, so over-long input surfaces as an inline error.
        phoneDigits = raw.filter(\.isNumber)
    }

    // MARK: - Private

    private func loadProfile() async {
        do {
            let profile = try await getCurrentUserUseCase.execute()
            applyProfile(profile)
        } catch {
            showError(error)
        }
    }

    private func applyProfile(_ profile: UserProfile) {
        let initialDigits = stripCountryCode(from: profile.phone)
        let initialName = profile.name ?? ""
        let initialSecond = profile.secondName ?? ""
        let initialCity = profile.city ?? ""

        name = initialName
        secondName = initialSecond
        phoneDigits = initialDigits
        birthDate = profile.birthDate
        city = initialCity.isEmpty ? nil : initialCity
        sex = profile.sex

        snapshot = Snapshot(
            name: initialName,
            secondName: initialSecond,
            phoneDigits: initialDigits,
            birthDate: profile.birthDate,
            city: initialCity,
            sex: profile.sex
        )
    }

    private func currentSnapshot() -> Snapshot {
        Snapshot(
            name: name.trimmingCharacters(in: .whitespaces),
            secondName: secondName.trimmingCharacters(in: .whitespaces),
            phoneDigits: phoneDigits,
            birthDate: birthDate,
            city: (city ?? "").trimmingCharacters(in: .whitespaces),
            sex: sex
        )
    }

    private func buildPatch() -> UserProfilePatch {
        let current = currentSnapshot()
        var patch = UserProfilePatch()

        if current.name != snapshot.name { patch.name = current.name }
        if current.secondName != snapshot.secondName { patch.secondName = current.secondName }
        if current.phoneDigits != snapshot.phoneDigits, !current.phoneDigits.isEmpty {
            patch.phone = countryCode + current.phoneDigits
        }
        if current.birthDate != snapshot.birthDate { patch.birthDate = current.birthDate }
        if current.city != snapshot.city { patch.city = current.city }
        if current.sex != snapshot.sex { patch.sex = current.sex }

        return patch
    }

    private func stripCountryCode(from phone: String?) -> String {
        guard let phone, !phone.isEmpty else { return "" }
        let digits = phone.filter(\.isNumber)
        // Phone comes back as +380XXXXXXXXX; we want the 9-digit local part.
        if digits.count >= 12, digits.hasPrefix("380") {
            return String(digits.suffix(digits.count - 3))
        }
        return digits
    }
}
