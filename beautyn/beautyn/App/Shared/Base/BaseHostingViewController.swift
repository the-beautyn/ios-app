import UIKit
import SwiftUI

class BaseHostingViewController<VM: BaseViewModel & ViewModelLifecycle, Content: View>: UIHostingController<Content>, UIGestureRecognizerDelegate {

    private(set) var viewModel: VM

    init(viewModel: VM, rootView: Content) {
        self.viewModel = viewModel
        super.init(rootView: rootView)
    }

    @MainActor required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.onViewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.onViewWillAppear()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewModel.onViewDidAppear()
        // Workaround for iOS 18 issue where an interrupted edge-swipe leaves
        // _UISystemGestureGateGestureRecognizer stuck and freezes touches on
        // SwiftUI screens that contain a TextField.
        navigationController?.interactivePopGestureRecognizer?.delegate = self
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        viewModel.onViewWillDisappear()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        viewModel.onViewDidDisappear()
    }

    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        (navigationController?.viewControllers.count ?? 0) > 1
    }
}
