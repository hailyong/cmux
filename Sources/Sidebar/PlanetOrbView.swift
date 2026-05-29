import SwiftUI

/// A small, self-contained procedural planet used as a workspace glyph in the
/// cosmos sidebar style.
///
/// The orb is drawn entirely with SwiftUI primitives (no raster assets) so it
/// is resolution-independent and theme-driven. Visual layers, from back to
/// front: optional back half-ring, soft attention halo, the lit orb (offset
/// radial gradient + terminator shadow), horizontal cloud bands for gas giants,
/// an atmosphere rim-light, and the optional front half-ring.
///
/// It takes only value inputs — no model references — so it is safe to use
/// inside a `LazyVStack`/`ForEach` row subtree per the sidebar snapshot-boundary
/// rule.
///
/// ```swift
/// PlanetOrbView(kind: .saturn, diameter: 18, isSelected: true, isWaiting: false)
/// ```
struct PlanetOrbView: View {
    /// The planet archetype to render.
    let kind: PlanetKind
    /// Orb diameter in points. The halo and ring extend beyond this.
    var diameter: CGFloat = 18
    /// Whether the owning workspace is currently selected (brightens the limb).
    var isSelected: Bool = false
    /// Whether the workspace has a waiting/attention agent (pulsing halo).
    var isWaiting: Bool = false
    /// Halo / accent color, defaults to the planet's atmosphere tint.
    var haloColor: Color?

    private var halo: Color { haloColor ?? kind.atmosphere }

    var body: some View {
        // Reserve room for the ring/halo overhang around the orb.
        let canvas = diameter * 1.7

        ZStack {
            if isWaiting {
                attentionHalo
            }
            if kind.hasRing {
                ringHalf(front: false)
            }
            orb
            if kind.hasRing {
                ringHalf(front: true)
            }
        }
        .frame(width: canvas, height: canvas)
        .accessibilityHidden(true)
    }

    // MARK: Orb

    private var orb: some View {
        Circle()
            .fill(
                RadialGradient(
                    colors: kind.surface,
                    center: UnitPoint(x: 0.34, y: 0.30),
                    startRadius: 0,
                    endRadius: diameter * 0.82
                )
            )
            .overlay { if kind.isBanded { bands } }
            .overlay { terminator }
            .overlay { atmosphereRim }
            .frame(width: diameter, height: diameter)
            .clipShape(Circle())
            .shadow(color: halo.opacity(isSelected ? 0.55 : 0.28), radius: isSelected ? 5 : 3)
    }

    /// Horizontal cloud banding for gas giants, blended softly over the surface.
    private var bands: some View {
        LinearGradient(
            stops: [
                .init(color: .white.opacity(0.00), location: 0.00),
                .init(color: .white.opacity(0.14), location: 0.18),
                .init(color: .black.opacity(0.12), location: 0.34),
                .init(color: .white.opacity(0.10), location: 0.52),
                .init(color: .black.opacity(0.14), location: 0.70),
                .init(color: .white.opacity(0.08), location: 0.88),
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        .blendMode(.softLight)
    }

    /// The night-side terminator: a dark inner shadow opposite the light source.
    private var terminator: some View {
        RadialGradient(
            colors: [.clear, .clear, .black.opacity(0.62)],
            center: UnitPoint(x: 0.34, y: 0.30),
            startRadius: diameter * 0.18,
            endRadius: diameter * 0.72
        )
    }

    /// A thin bright rim just inside the limb suggesting a scattering atmosphere.
    private var atmosphereRim: some View {
        Circle()
            .strokeBorder(
                RadialGradient(
                    colors: [.clear, halo.opacity(isSelected ? 0.85 : 0.5)],
                    center: UnitPoint(x: 0.66, y: 0.72),
                    startRadius: diameter * 0.30,
                    endRadius: diameter * 0.52
                ),
                lineWidth: max(1, diameter * 0.08)
            )
    }

    // MARK: Halo

    private var attentionHalo: some View {
        Circle()
            .fill(halo)
            .frame(width: diameter * 1.45, height: diameter * 1.45)
            .blur(radius: diameter * 0.34)
            .opacity(0.55)
    }

    // MARK: Ring

    /// One half of a Saturn-style ring. `front == true` draws the segment that
    /// passes in front of the orb; `false` draws the segment behind it.
    @ViewBuilder
    private func ringHalf(front: Bool) -> some View {
        let ringWidth = diameter * 1.55
        let ringHeight = diameter * 0.42

        Ellipse()
            .strokeBorder(
                LinearGradient(
                    colors: [
                        kind.atmosphere.opacity(0.0),
                        kind.atmosphere.opacity(0.85),
                        .white.opacity(0.6),
                        kind.atmosphere.opacity(0.85),
                        kind.atmosphere.opacity(0.0),
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                ),
                lineWidth: max(1.5, diameter * 0.12)
            )
            .frame(width: ringWidth, height: ringHeight)
            .rotationEffect(.degrees(-18))
            // Clip to top/bottom half so the orb sits between the two segments.
            .mask(alignment: front ? .bottom : .top) {
                Rectangle().frame(height: ringHeight)
            }
    }
}
