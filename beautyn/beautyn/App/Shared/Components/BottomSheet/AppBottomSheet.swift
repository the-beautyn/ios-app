import SwiftUI

// MARK: - SnapPosition
//
// Five positions a draggable sheet can rest at, ordered bottom → top.
// Heights are computed relative to the current screen height so the
// sheet feels consistent on any device.

enum SnapPosition: CaseIterable, Equatable, Comparable {
    /// Off-screen — sheet is not visible.
    case hidden
    /// Peek strip at the bottom — ~120 pt.
    case peek
    /// Compact panel — ~40 % of screen height.
    case compact
    /// Medium panel  — ~60 % of screen height.
    case medium
    /// Large panel   — ~85 % of screen height.
    case large

    func height(screenHeight: CGFloat) -> CGFloat {
        switch self {
        case .hidden:  return 0
        case .peek:    return 120
        case .compact: return screenHeight * 0.40
        case .medium:  return screenHeight * 0.60
        case .large:   return screenHeight * 0.85
        }
    }

    // Enables sorting / Comparable conformance
    private var sortOrder: Int {
        switch self { case .hidden: 0; case .peek: 1; case .compact: 2; case .medium: 3; case .large: 4 }
    }
    static func < (lhs: Self, rhs: Self) -> Bool { lhs.sortOrder < rhs.sortOrder }
}

// MARK: - BottomSheetStyle

enum BottomSheetStyle {
    /// Sheet rests at a fixed height and cannot be dragged.
    case fixed(height: CGFloat)
    /// Sheet snaps between the given positions; drag handle is shown automatically.
    case draggable(
        snapPositions: [SnapPosition] = [.peek, .compact, .medium, .large],
        initial: SnapPosition = .medium
    )
}

// MARK: - AppBottomSheet

/// A bottom sheet that can be either fixed-height or freely draggable across
/// up to five predefined snap positions.
///
/// **Typical usage via the view modifier:**
/// ```swift
/// someView
///     .bottomSheet(isPresented: $showSheet) {
///         MySheetContent()
///     }
/// ```
struct AppBottomSheet<Content: View>: View {

    // MARK: - Configuration

    @Binding var isPresented: Bool
    let style: BottomSheetStyle
    /// Override whether the drag handle is visible.  `nil` = auto (shown when draggable).
    let showDragHandle: Bool?
    let showDimBackground: Bool
    @ViewBuilder let content: () -> Content

    // MARK: - State

    @State private var currentSnap: SnapPosition
    @State private var dragOffset: CGFloat = 0

    // MARK: - Init

    init(
        isPresented: Binding<Bool>,
        style: BottomSheetStyle = .draggable(),
        showDragHandle: Bool? = nil,
        showDimBackground: Bool = true,
        @ViewBuilder content: @escaping () -> Content
    ) {
        _isPresented = isPresented
        self.style = style
        self.showDragHandle = showDragHandle
        self.showDimBackground = showDimBackground
        self.content = content

        if case .draggable(_, let initial) = style {
            _currentSnap = State(initialValue: initial)
        } else {
            _currentSnap = State(initialValue: .medium)
        }
    }

    // MARK: - Body

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .bottom) {
                dimLayer
                sheetLayer(screenHeight: geo.size.height)
            }
            .ignoresSafeArea()
        }
        // Reset snap position each time the sheet is re-presented
        .onChange(of: isPresented) { _, newValue in
            if newValue, case .draggable(_, let initial) = style {
                currentSnap = initial
            }
        }
    }

    // MARK: - Dim background

    @ViewBuilder
    private var dimLayer: some View {
        if showDimBackground {
            Color.black
                .opacity(isPresented ? 0.35 : 0)
                .ignoresSafeArea()
                .onTapGesture { dismissSheet() }
                .animation(.easeInOut(duration: 0.22), value: isPresented)
                .allowsHitTesting(isPresented)
        }
    }

    // MARK: - Sheet panel

    private func sheetLayer(screenHeight: CGFloat) -> some View {
        let height    = resolvedHeight(screenHeight: screenHeight)
        let baseOffset = isPresented ? 0.0 : height      // slides in from below

        return VStack(spacing: 0) {
            if resolvedShowDragHandle {
                dragHandleView
            }
            content()
        }
        .frame(maxWidth: .infinity)
        .frame(height: height, alignment: .top)
        .background(Color.App.white)
        .clipShape(
            UnevenRoundedRectangle(
                topLeadingRadius: 32,
                bottomLeadingRadius: 0,
                bottomTrailingRadius: 0,
                topTrailingRadius: 32
            )
        )
        .shadow(color: .black.opacity(0.10), radius: 24, x: 0, y: -6)
        .offset(y: baseOffset + dragOffset)
        .animation(.spring(response: 0.38, dampingFraction: 0.84), value: isPresented)
        .animation(.spring(response: 0.35, dampingFraction: 0.86), value: currentSnap)
        .gesture(isDraggable ? dragGesture(screenHeight: screenHeight) : nil)
    }

    // MARK: - Drag handle

    private var dragHandleView: some View {
        Capsule()
            .fill(Color(hex: "#CFCFCF"))
            .frame(width: 36, height: 5)
            .padding(.top, 10)
            .padding(.bottom, 6)
    }

    // MARK: - Drag gesture

    private func dragGesture(screenHeight: CGFloat) -> some Gesture {
        DragGesture(minimumDistance: 8)
            .onChanged { value in
                let t = value.translation.height
                // Rubber-band when pulling above the current snap height
                dragOffset = t > 0 ? t : t * 0.12
            }
            .onEnded { value in
                let predicted = value.predictedEndTranslation.height
                let currentH  = currentSnap.height(screenHeight: screenHeight)
                let targetH   = currentH - predicted

                withAnimation(.spring(response: 0.35, dampingFraction: 0.86)) {
                    dragOffset = 0
                    if targetH < 80 {
                        dismissSheet()
                    } else {
                        currentSnap = nearestSnap(to: targetH, screenHeight: screenHeight)
                    }
                }
            }
    }

    // MARK: - Helpers

    private var isDraggable: Bool {
        if case .draggable = style { return true }
        return false
    }

    private var resolvedShowDragHandle: Bool {
        showDragHandle ?? isDraggable
    }

    private func resolvedHeight(screenHeight: CGFloat) -> CGFloat {
        switch style {
        case .fixed(let h):  return h
        case .draggable:     return currentSnap.height(screenHeight: screenHeight)
        }
    }

    private func nearestSnap(to targetH: CGFloat, screenHeight: CGFloat) -> SnapPosition {
        guard case .draggable(let positions, _) = style else { return currentSnap }
        let snappable = positions.filter { $0 != .hidden }
        return snappable.min(by: {
            abs($0.height(screenHeight: screenHeight) - targetH) <
            abs($1.height(screenHeight: screenHeight) - targetH)
        }) ?? currentSnap
    }

    private func dismissSheet() {
        isPresented = false
    }
}

// MARK: - View Modifier

extension View {
    /// Overlays a bottom sheet on this view.
    ///
    /// - Parameters:
    ///   - isPresented: Controls sheet visibility.
    ///   - style: `.fixed(height:)` or `.draggable(snapPositions:initial:)`.
    ///   - showDragHandle: Force-show or hide the drag handle.  `nil` = auto.
    ///   - showDimBackground: Whether a semi-transparent scrim is shown behind the sheet.
    ///   - content: The sheet's content.
    func bottomSheet<SheetContent: View>(
        isPresented: Binding<Bool>,
        style: BottomSheetStyle = .draggable(),
        showDragHandle: Bool? = nil,
        showDimBackground: Bool = true,
        @ViewBuilder content: @escaping () -> SheetContent
    ) -> some View {
        ZStack {
            self
            AppBottomSheet(
                isPresented: isPresented,
                style: style,
                showDragHandle: showDragHandle,
                showDimBackground: showDimBackground,
                content: content
            )
        }
    }
}

// MARK: - Preview

#if DEBUG
private struct PreviewRoot: View {

    @State private var showDraggable = false
    @State private var showFixed     = false
    @State private var showPeek      = false

    var body: some View {
        ZStack {
            Color.App.backgroundLight.ignoresSafeArea()

            VStack(spacing: CGFloat.Spacing.md) {
                AppButton(title: "Draggable (5 snaps)") {
                    showDraggable = true
                }

                AppButton(
                    title: "Fixed height 320 pt",
                    style: .secondary(outlined: true)
                ) {
                    showFixed = true
                }

                AppButton(
                    title: "Peek-only sheet",
                    style: .secondary()
                ) {
                    showPeek = true
                }
            }
            .padding(.horizontal, CGFloat.Spacing.md)
        }
        // Draggable — all 5 snap positions, starts at medium
        .bottomSheet(isPresented: $showDraggable) {
            VStack(alignment: .leading, spacing: CGFloat.Spacing.md) {
                Text("Draggable sheet")
                    .font(.App.title1Bold)
                    .foregroundStyle(Color.App.text)

                Text("Drag the handle to snap between peek → compact → medium → large.")
                    .font(.App.body)
                    .foregroundStyle(Color.App.gray)
                    .tracking(CGFloat.Tracking.body)

                Divider()

                ForEach(["Option A", "Option B", "Option C"], id: \.self) { item in
                    HStack {
                        Text(item).font(.App.callout)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.footnote)
                            .foregroundStyle(Color.App.gray2)
                    }
                    .padding(.vertical, CGFloat.Spacing.xs)
                }
            }
            .padding(.horizontal, CGFloat.Spacing.md)
            .padding(.bottom, CGFloat.Spacing.xl)
        }
        // Fixed height, no drag handle
        .bottomSheet(
            isPresented: $showFixed,
            style: .fixed(height: 320),
            showDragHandle: false
        ) {
            VStack(spacing: CGFloat.Spacing.md) {
                Text("Fixed sheet")
                    .font(.App.title2Bold)
                    .foregroundStyle(Color.App.text)

                Text("Always 320 pt tall. Tap outside to close.")
                    .font(.App.body)
                    .foregroundStyle(Color.App.gray)

                Spacer()

                AppButton(title: "Confirm") { showFixed = false }
                AppButton.secondaryGhost(title: "Cancel") { showFixed = false }
            }
            .padding(CGFloat.Spacing.md)
        }
        // Peek-only — starts at peek, can snap up to compact
        .bottomSheet(
            isPresented: $showPeek,
            style: .draggable(
                snapPositions: [.peek, .compact],
                initial: .peek
            )
        ) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Peek strip")
                        .font(.App.headline)
                        .foregroundStyle(Color.App.text)
                    Text("Drag up for more")
                        .font(.App.footnote)
                        .foregroundStyle(Color.App.gray2)
                }
                Spacer()
                AppButton(title: "Action", style: .primary, size: .small) {
                    showPeek = false
                }
            }
            .padding(.horizontal, CGFloat.Spacing.md)
            .padding(.bottom, CGFloat.Spacing.md)
        }
    }
}

#Preview("Bottom Sheet") {
    PreviewRoot()
}
#endif
