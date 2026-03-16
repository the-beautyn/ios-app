import Foundation

// MARK: - Protocol

protocol AppFactory {
    var networkService: any NetworkService { get }
}

// MARK: - Implementation

final class AppFactoryImpl: AppFactory {
    private let resolver: any Resolver

    init(resolver: any Resolver) {
        self.resolver = resolver
    }

    var networkService: any NetworkService {
        resolver.require((any NetworkService).self)
    }
}
