import Foundation

// MARK: - ResolverInjector

protocol ResolverInjector: AnyObject {
    var resolver: any Resolver { get }
}

// MARK: - ResolverInjectorImpl

class ResolverInjectorImpl: ResolverInjector {
    let resolver: any Resolver

    init(resolver: any Resolver) {
        self.resolver = resolver
    }
}
