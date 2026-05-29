import Foundation
import SwiftUI

/// Feature-flag keys and defaults for the cosmos ("deep space") sidebar style.
///
/// Every cosmic element sits behind these flags; the defaults reproduce stock
/// upstream behavior so a fresh install is visually identical to vanilla cmux.
/// Toggle ``enabledKey`` to swap the classic workspace list for planet orbs.
enum CosmosSidebarSettings {
    /// `UserDefaults`/`@AppStorage` key. `true` renders planet orbs; `false`
    /// (default) keeps the classic sidebar. Matches the beta-toggle key shape
    /// used by the right-sidebar dock flag (`rightSidebar.beta.dock.enabled`).
    static let enabledKey = "sidebar.beta.cosmos.enabled"

    /// Default is `false` so the cosmos style is opt-in and upstream-identical.
    static let enabledDefault = false

    /// `UserDefaults`/`@AppStorage` key holding the attention/unread ring color
    /// as a 6-digit hex string (no leading `#`). Empty falls back to the stock
    /// `.systemBlue` notification ring.
    static let ringColorHexKey = "notifications.paneRing.colorHex"

    /// Resolves the configured ring color, or `nil` to use the stock system
    /// blue when unset/malformed.
    static func ringColor(
        hex: String? = UserDefaults.standard.string(forKey: ringColorHexKey)
    ) -> Color? {
        guard let hex, !hex.isEmpty else { return nil }
        return Color(hex: hex)
    }

    /// Default cosmic ring color (soft ice-blue), suggested when a user first
    /// enables the cosmos style. Stored as hex via ``ringColorHexKey``.
    static let suggestedRingColorHex = "6ee7ff"
}
