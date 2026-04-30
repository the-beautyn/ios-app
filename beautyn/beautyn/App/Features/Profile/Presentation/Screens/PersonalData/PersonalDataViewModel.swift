import Foundation
import Combine

// MARK: - PersonalDataViewModel

@MainActor
final class PersonalDataViewModel: BaseViewModel {

    // MARK: - Transition

    struct Transition {
        let didTapEditProfile: () -> Void
        let didTapEditAvatar: () -> Void
    }

    // MARK: - Display (Presentation Entity)

    struct Display {
        let displayName: String
        let avatarURL: URL?
        let birthDate: String
        let phone: String
        let email: String
        let city: String
        let sex: String

        static let empty = Display(
            displayName: "",
            avatarURL: nil,
            birthDate: Localization.commonNotSpecified,
            phone: Localization.commonNotSpecified,
            email: Localization.commonNotSpecified,
            city: Localization.commonNotSpecified,
            sex: Localization.commonNotSpecified
        )
    }

    // MARK: - Published

    @Published private(set) var display: Display = .empty

    // MARK: - Dependencies

    private let transition: Transition
    private let getCurrentUserUseCase: any GetCurrentUserUseCase

    // MARK: - Init

    init(
        transition: Transition,
        getCurrentUserUseCase: any GetCurrentUserUseCase
    ) {
        self.transition = transition
        self.getCurrentUserUseCase = getCurrentUserUseCase
        super.init()
        Task { [weak self] in await self?.loadProfile() }
    }

    // MARK: - Actions

    func didTapEditProfile() { transition.didTapEditProfile() }
    func didTapEditAvatar() { transition.didTapEditAvatar() }

    // MARK: - Private

    private func loadProfile() async {
        do {
            let profile = try await getCurrentUserUseCase.execute()
            display = makeDisplay(from: profile)
        } catch {
            showError(error)
        }
    }

    private func makeDisplay(from profile: UserProfile) -> Display {
        let placeholder = Localization.commonNotSpecified

        let nameParts = [profile.name, profile.secondName].compactMap { $0 }
        let joined = nameParts.joined(separator: " ")
        let displayName = joined.isEmpty ? profile.email : joined

        let birthDate = profile.birthDate.map(Self.birthDateFormatter.string(from:)) ?? placeholder
        let phone = profile.phone ?? placeholder
        let email = profile.email.isEmpty ? placeholder : profile.email
        let city = profile.city ?? placeholder
        let sex = sexLabel(profile.sex)
        let avatarURL = profile.avatarUrl.flatMap(URL.init(string:))

        return Display(
            displayName: displayName,
            avatarURL: avatarURL,
            birthDate: birthDate,
            phone: phone,
            email: email,
            city: city,
            sex: sex
        )
    }

    private func sexLabel(_ sex: Sex?) -> String {
        guard let sex else { return Localization.commonNotSpecified }
        switch sex {
        case .male:           return Localization.profileSexMale
        case .female:         return Localization.profileSexFemale
        case .other:          return Localization.profileSexOther
        case .preferNotToSay: return Localization.profileSexPreferNotToSay
        }
    }

    private static let birthDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "dd/MM/yyyy"
        return formatter
    }()
}
