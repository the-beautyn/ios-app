import Foundation

// Typed feature-factory entry points. Exposed on both `Assembler` and `Resolver`
// so controller factories (which hold `AssemblerLike = any Resolver`) can also
// reach `.app` / `.auth` / `.main` without the stringly-typed `require(_:)` call.
//
// Usage is restricted by convention to the DI boundary: Coordinators and
// ControllerFactories. ViewModels and Controllers get dependencies through
// plain init parameters.

extension Assembler {
    var app: any AppFactory { resolver.require((any AppFactory).self) }
    var auth: any AuthFactory { resolver.require((any AuthFactory).self) }
    var main: any MainFactory { resolver.require((any MainFactory).self) }
    var resetPassword: any ResetPasswordFactory { resolver.require((any ResetPasswordFactory).self) }
}

extension Resolver {
    var app: any AppFactory { self.require((any AppFactory).self) }
    var auth: any AuthFactory { self.require((any AuthFactory).self) }
    var main: any MainFactory { self.require((any MainFactory).self) }
    var resetPassword: any ResetPasswordFactory { self.require((any ResetPasswordFactory).self) }
}
