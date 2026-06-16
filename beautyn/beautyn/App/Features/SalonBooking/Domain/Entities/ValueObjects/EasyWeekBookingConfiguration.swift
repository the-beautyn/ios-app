import Foundation

// MARK: - WebBookingConfiguration + EasyWeek
//
// EasyWeek runs a Nuxt web widget. The user fills the booking form on a
// `/confirm` page and lands on `/thank-you` once the booking is created, where
// the booking UUID appears in the page (and in `window.__NUXT__.state`).
// Keyword lists cover Ukrainian / Russian / English labels.

extension WebBookingConfiguration {
    static let easyWeek = WebBookingConfiguration(
        autofillPathSuffix: "/confirm",
        fields: [
            WebBookingField(
                kind: .firstName,
                keywords: ["ім'я", "imya", "name", "first name", "імя", "имя"],
                preferredInputTypes: []
            ),
            WebBookingField(
                kind: .lastName,
                keywords: ["прізвище", "prizvyshche", "фамилия", "surname", "last name"],
                preferredInputTypes: []
            ),
            WebBookingField(
                kind: .email,
                keywords: ["електронна пошта", "email", "e-mail", "mail", "почта", "электронная почта"],
                preferredInputTypes: ["email"]
            ),
            WebBookingField(
                kind: .phone,
                keywords: ["телефон", "phone", "tel", "мобільний", "мобильный"],
                preferredInputTypes: ["tel"]
            )
        ],
        completionPathSuffix: "/thank-you",
        bookingIdRegexes: [
            "booking/([0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12})",
            "booking:?[\\s\\n]+([0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12})"
        ]
    )
}

// MARK: - SalonBookingProvider → WebBookingConfiguration
//
// The switchboard that makes the in-app web-booking popup provider-agnostic:
// each web-widget provider returns its configuration; non-web providers (Altegio,
// booked in-app) and unknown providers return nil. Add a provider by adding a
// case here plus its `WebBookingConfiguration`.

extension SalonBookingProvider {
    var webBookingConfiguration: WebBookingConfiguration? {
        switch self {
        case .easyweek: return .easyWeek
        case .altegio, .unknown: return nil
        }
    }
}
