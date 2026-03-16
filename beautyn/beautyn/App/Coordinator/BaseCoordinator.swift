import Foundation

@MainActor
class BaseCoordinator {
    var childCoordinators: [BaseCoordinator] = []
    var onFinish: (() -> Void)?

    func start() {
        fatalError("start() must be implemented by subclass")
    }

    func addChild(_ coordinator: BaseCoordinator) {
        childCoordinators.append(coordinator)
    }

    func removeChild(_ coordinator: BaseCoordinator) {
        childCoordinators.removeAll { $0 === coordinator }
    }

    func releaseChildren() {
        childCoordinators.removeAll()
    }
}
