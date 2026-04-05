import Foundation

public enum AppRoute: Equatable, Sendable {
    case auth
    case completeProfile(AppUser)
    case feed(AppUser)
}
