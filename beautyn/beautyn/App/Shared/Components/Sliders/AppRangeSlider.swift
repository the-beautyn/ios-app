import SwiftUI

// MARK: - AppRangeSlider
//
// Two-knob range slider — SwiftUI has no native one. Styled after the app's
// slider look (6pt track, brown fill between the knobs, white capsule
// thumbs). Values snap to `step` and the knobs keep one step of separation.

struct AppRangeSlider: View {

    @Binding var lowerValue: Double
    @Binding var upperValue: Double
    let bounds: ClosedRange<Double>
    let step: Double

    private static let trackHeight: CGFloat = 6
    private static let knobSize = CGSize(width: 36, height: 24)
    /// Invisible slop around each knob so the 24pt thumb is a 44pt target.
    private static let knobHitSize: CGFloat = 44

    /// The knob the in-flight drag grabbed — locked on the first change so a
    /// drag that runs into the other knob keeps controlling the one it
    /// started on (no mid-drag hand-off, no jump).
    @State private var activeKnob: Knob?

    private enum Knob { case lower, upper }

    var body: some View {
        GeometryReader { geo in
            // Knob centers travel between the half-widths so the thumbs stay
            // fully inside the control at both extremes.
            let usableWidth = max(1, geo.size.width - Self.knobSize.width)
            let lowerX = knobCenterX(for: lowerValue, usableWidth: usableWidth)
            let upperX = knobCenterX(for: upperValue, usableWidth: usableWidth)
            let centerY = geo.size.height / 2

            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color.App.gray.opacity(0.2))
                    .frame(height: Self.trackHeight)
                    .frame(maxHeight: .infinity, alignment: .center)

                Capsule()
                    .fill(Color.App.brown2)
                    .frame(width: max(Self.trackHeight, upperX - lowerX), height: Self.trackHeight)
                    .offset(x: lowerX)
                    .frame(maxHeight: .infinity, alignment: .center)

                knob.position(x: lowerX, y: centerY)
                knob.position(x: upperX, y: centerY)
            }
            // One gesture over the whole control, routed to the knob the drag
            // starts nearest to. Two separate per-knob gestures overlap when
            // the values are close (44pt targets ≫ the gap) and the topmost
            // one silently steals the touch, making the lower knob
            // unreachable and the upper knob jump.
            .contentShape(Rectangle())
            .gesture(dragGesture(usableWidth: usableWidth, lowerX: lowerX, upperX: upperX))
        }
        .frame(height: Self.knobHitSize)
    }

    // MARK: - Knob

    private var knob: some View {
        Capsule()
            .fill(Color.App.white)
            .frame(width: Self.knobSize.width, height: Self.knobSize.height)
            .shadow(color: .black.opacity(0.12), radius: 4, y: 1)
            .shadow(color: .black.opacity(0.12), radius: 13, y: 6)
    }

    // MARK: - Math

    private func knobCenterX(for value: Double, usableWidth: CGFloat) -> CGFloat {
        let span = bounds.upperBound - bounds.lowerBound
        guard span > 0 else { return Self.knobSize.width / 2 }
        let fraction = (value - bounds.lowerBound) / span
        return Self.knobSize.width / 2 + usableWidth * fraction
    }

    private func value(atX x: CGFloat, usableWidth: CGFloat) -> Double {
        let fraction = Double((x - Self.knobSize.width / 2) / usableWidth)
        let raw = bounds.lowerBound + fraction * (bounds.upperBound - bounds.lowerBound)
        let snapped = (raw / step).rounded() * step
        return min(max(snapped, bounds.lowerBound), bounds.upperBound)
    }

    private func dragGesture(usableWidth: CGFloat, lowerX: CGFloat, upperX: CGFloat) -> some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { drag in
                let knob = activeKnob ?? nearestKnob(toX: drag.startLocation.x, lowerX: lowerX, upperX: upperX)
                activeKnob = knob
                let dragged = value(atX: drag.location.x, usableWidth: usableWidth)
                switch knob {
                case .lower:
                    // Keep a step of separation AND stay on the track, even
                    // if the bindings arrived collapsed (min == max).
                    lowerValue = max(min(dragged, upperValue - step), bounds.lowerBound)
                case .upper:
                    upperValue = min(max(dragged, lowerValue + step), bounds.upperBound)
                }
            }
            .onEnded { _ in activeKnob = nil }
    }

    private func nearestKnob(toX x: CGFloat, lowerX: CGFloat, upperX: CGFloat) -> Knob {
        abs(x - lowerX) <= abs(x - upperX) ? .lower : .upper
    }
}

// MARK: - Preview

#if DEBUG
private struct RangeSliderPreview: View {
    @State private var lower: Double = 200
    @State private var upper: Double = 800

    var body: some View {
        VStack(spacing: CGFloat.Spacing.md) {
            Text("\(Int(lower)) – \(Int(upper))")
                .font(.App.footnote)
            AppRangeSlider(lowerValue: $lower, upperValue: $upper, bounds: 100...1200, step: 100)
        }
        .padding(CGFloat.Spacing.md)
    }
}

#Preview {
    RangeSliderPreview()
}
#endif
