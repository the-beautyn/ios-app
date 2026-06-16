import Foundation

// MARK: - WebBookingField
//
// One autofillable field on a provider's booking form. `keywords` are matched
// (case-insensitively) against an input's placeholder / aria-label / name / id /
// data-* / associated <label>; `preferredInputTypes` (e.g. "email", "tel")
// narrows the candidate inputs. All provider-agnostic — the concrete values come
// from `WebBookingAutofill`.

struct WebBookingField: Equatable {
    enum Kind: Equatable {
        case firstName
        case lastName
        case email
        case phone
    }

    let kind: Kind
    let keywords: [String]
    let preferredInputTypes: [String]
}

// MARK: - WebBookingConfiguration
//
// Provider-agnostic description of how to drive a web booking widget in a
// `WKWebView`: which page autofills, which fields to fill, which page signals
// completion, and how to extract the resulting booking id. A new provider is
// added by supplying a new value of this type — no engine changes.

struct WebBookingConfiguration: Equatable {
    /// The form page is detected when the current URL's path ends with this
    /// suffix (e.g. "/confirm").
    let autofillPathSuffix: String

    /// Fields to autofill on the form page.
    let fields: [WebBookingField]

    /// Completion is detected when the current URL's path ends with this suffix
    /// (e.g. "/thank-you").
    let completionPathSuffix: String

    /// Regular-expression sources (passed to JS `new RegExp(_, "i")`) tried in
    /// order against the page HTML / innerText / app state to extract the booking
    /// id. Capture group 1 is the id.
    let bookingIdRegexes: [String]
}
