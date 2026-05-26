import Foundation

// Typed feature-factory entry points. Exposed on both `Assembler` and `Resolver`
// so controller factories (which hold `AssemblerLike = any Resolver`) can also
// reach `.app` / `.auth` / `.home` / `.profile` without the stringly-typed
// `require(_:)` call.
//
// Usage is restricted by convention to the DI boundary: Coordinators and
// ControllerFactories. ViewModels and Controllers get dependencies through
// plain init parameters.

extension Assembler {
    var app: any AppFactory { resolver.require((any AppFactory).self) }
    var auth: any AuthFactory { resolver.require((any AuthFactory).self) }
    var home: any HomeFactory { resolver.require((any HomeFactory).self) }
    var phoneVerification: any PhoneVerificationFactory { resolver.require((any PhoneVerificationFactory).self) }
    var profile: any ProfileFactory { resolver.require((any ProfileFactory).self) }
    var resetPassword: any ResetPasswordFactory { resolver.require((any ResetPasswordFactory).self) }
    var salonBooking: any SalonBookingFactory { resolver.require((any SalonBookingFactory).self) }
}

extension Resolver {
    var app: any AppFactory { self.require((any AppFactory).self) }
    var auth: any AuthFactory { self.require((any AuthFactory).self) }
    var home: any HomeFactory { self.require((any HomeFactory).self) }
    var phoneVerification: any PhoneVerificationFactory { self.require((any PhoneVerificationFactory).self) }
    var profile: any ProfileFactory { self.require((any ProfileFactory).self) }
    var resetPassword: any ResetPasswordFactory { self.require((any ResetPasswordFactory).self) }
    var salonBooking: any SalonBookingFactory { self.require((any SalonBookingFactory).self) }
}
