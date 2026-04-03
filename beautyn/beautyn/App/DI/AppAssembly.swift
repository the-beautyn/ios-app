import Foundation

final class AppAssembly: Assembly {
    func assemble(container: Container) {
        container.register((any NetworkService).self) { _ in
            NetworkServiceImpl()
        }

        container.register((any AppFactory).self) { resolver in
            AppFactoryImpl(resolver: resolver)
        }
    }
}
