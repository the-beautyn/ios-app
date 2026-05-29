import UIKit

extension UIApplication {
    /// Resigns the current first responder, dismissing the on-screen keyboard.
    /// Used to end search-field editing when the user switches tabs.
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
