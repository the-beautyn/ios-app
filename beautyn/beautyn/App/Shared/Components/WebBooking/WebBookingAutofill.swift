import Foundation

// MARK: - WebBookingAutofill
//
// The signed-in user's contact details, resolved by the caller (which has DI
// access to the current user) and injected into a provider's booking form by
// the web-booking engine. Provider-agnostic.

struct WebBookingAutofill: Equatable {
    let firstName: String
    let lastName: String
    let email: String
    let phone: String

    /// The value to type into a field of the given kind. Empty values are skipped
    /// by the engine.
    func value(for kind: WebBookingField.Kind) -> String {
        switch kind {
        case .firstName: return firstName
        case .lastName: return lastName
        case .email: return email
        case .phone: return phone
        }
    }
}
