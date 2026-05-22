import UIKit

// MARK: - LocationPickerController
//
// Hosts `LocationPickerView` for SwiftUI sheet presentation. The screen is
// self-contained (no navigation pushes) — the sheet's "back" button
// dismisses, and tapping a suggestion fires the completion before dismissal.

final class LocationPickerController: BaseHostingViewController<LocationPickerViewModel, LocationPickerView> {

    init(viewModel: LocationPickerViewModel) {
        let view = LocationPickerView(viewModel: viewModel)
        super.init(viewModel: viewModel, rootView: view)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
