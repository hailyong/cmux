import SwiftUI

/// A procedurally-rendered planet archetype used by the cosmos sidebar style.
///
/// Each workspace is mapped to a `PlanetKind` deterministically (see
/// ``PlanetKind/forWorkspace(_:)``) so a given workspace always shows the same
/// planet across launches. The kind drives palette, banding, and whether a
/// Saturn-style ring is drawn.
enum PlanetKind: CaseIterable, Hashable {
    /// Banded gas giant — warm amber/sand bands.
    case jupiter
    /// Deep-blue ice giant — smooth, cool gradient.
    case neptune
    /// Ringed gas giant — pale gold with an orbital ring.
    case saturn
    /// Frozen world — desaturated ice-blue with a bright limb.
    case ice
    /// Volcanic world — magenta/ember core glow.
    case ember

    /// Core surface gradient stops (light side → terminator).
    var surface: [Color] {
        switch self {
        case .jupiter: [.planet("f6d29b"), .planet("c98a4b"), .planet("7a4a22")]
        case .neptune: [.planet("9ec3ff"), .planet("3f6fd6"), .planet("1b2f6b")]
        case .saturn: [.planet("f3e4b8"), .planet("c9a25e"), .planet("7c5a2e")]
        case .ice: [.planet("e8f4ff"), .planet("9ec3ff"), .planet("41618b")]
        case .ember: [.planet("ffd1a8"), .planet("d8568a"), .planet("5c1f4a")]
        }
    }

    /// Atmosphere rim-light color drawn just inside the limb.
    var atmosphere: Color {
        switch self {
        case .jupiter: .planet("ffd479")
        case .neptune: .planet("9ec3ff")
        case .saturn: .planet("ffe9a8")
        case .ice: .planet("bfe0ff")
        case .ember: .planet("ff8ab0")
        }
    }

    /// Whether this kind draws a Saturn-style orbital ring.
    var hasRing: Bool { self == .saturn }

    /// Whether this kind paints horizontal cloud bands (gas giants).
    var isBanded: Bool { self == .jupiter || self == .saturn }

    /// Deterministically maps a workspace identifier to a planet so the same
    /// workspace always renders the same world.
    static func forWorkspace(_ id: UUID) -> PlanetKind {
        let all = PlanetKind.allCases
        let bytes = id.uuid
        let sum = bytes.0 &+ bytes.1 &+ bytes.2 &+ bytes.3
            &+ bytes.4 &+ bytes.5 &+ bytes.6 &+ bytes.7
        return all[Int(sum) % all.count]
    }
}

extension Color {
    /// Non-failable hex helper for the static, known-valid palette literals in
    /// ``PlanetKind``. Falls back to clear only if a literal is malformed.
    static func planet(_ hex: String) -> Color {
        Color(hex: hex) ?? .clear
    }
}
