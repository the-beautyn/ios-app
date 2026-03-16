import Foundation

extension Resolver {
    func require<T>(_ type: T.Type) -> T {
        guard let service = resolve(type) else {
            fatalError("❌ [DI] \(type) is not registered in the container")
        }
        return service
    }

    func require<T>(_ type: T.Type, name: String) -> T {
        guard let service = resolve(type, name: name) else {
            fatalError("❌ [DI] \(type) (name: \(name)) is not registered in the container")
        }
        return service
    }
}
