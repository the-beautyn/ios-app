import Foundation

// MARK: - Resolver

protocol Resolver: AnyObject {
    func resolve<T>(_ type: T.Type) -> T?
    func resolve<T>(_ type: T.Type, name: String?) -> T?
}

// MARK: - Assembly

protocol Assembly {
    func assemble(container: Container)
}

// MARK: - Container

final class Container {
    private var registrations: [String: Any] = [:]
    private weak var parent: Container?

    init(parent: Container? = nil) {
        self.parent = parent
    }

    func register<T>(_ type: T.Type, factory: @escaping (any Resolver) -> T) {
        registrations[key(for: type)] = factory
    }

    func register<T>(_ type: T.Type, name: String, factory: @escaping (any Resolver) -> T) {
        registrations[key(for: type, name: name)] = factory
    }

    private func key<T>(for type: T.Type, name: String? = nil) -> String {
        name.map { "\(type)_\($0)" } ?? "\(type)"
    }
}

extension Container: Resolver {
    func resolve<T>(_ type: T.Type) -> T? {
        if let factory = registrations[key(for: type)] as? (any Resolver) -> T {
            return factory(self)
        }
        return parent?.resolve(type)
    }

    func resolve<T>(_ type: T.Type, name: String?) -> T? {
        guard let name else { return resolve(type) }
        if let factory = registrations[key(for: type, name: name)] as? (any Resolver) -> T {
            return factory(self)
        }
        return parent?.resolve(type, name: name)
    }
}

// MARK: - Assembler

final class Assembler {
    let container: Container

    var resolver: any Resolver { container }

    init(_ assemblies: [any Assembly], parent: Assembler? = nil) {
        container = Container(parent: parent?.container)
        assemblies.forEach { $0.assemble(container: container) }
    }
}
