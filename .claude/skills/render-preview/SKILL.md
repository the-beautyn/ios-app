---
name: render-preview
description: "Render SwiftUI views to PNG screenshots for visual verification after UI changes. IMPORTANT: Always use this skill after completing any UI work — creating new screens, modifying views, updating components, or fixing layout issues. Also use when the user says /render-preview, 'show me the preview', 'render the view', 'check how it looks', 'does it match the design', or asks to compare implementation against Figma. This is the iOS app's visual regression check — if you touched a SwiftUI file, render it."
---

# Render Preview

Visually verify SwiftUI screens by rendering the actual views to PNG screenshots. This uses XCTest render tests that host real views (with `@StateObject`, full lifecycle) in a `UIWindow` with mock data — what you see in the PNG is exactly what the user would see in the app.

The pipeline exists because Xcode SwiftUI Previews aren't accessible from the CLI. This is the equivalent: build → render → screenshot → verify.

## When to use this

**IMPORTANT: Always ask the user for permission before running any build or render. Never run xcodebuild automatically.** Ask something like "Want me to build and render a preview?" and wait for confirmation.

- **After any UI change** — new screen, modified view, updated component, layout fix
- **After implementing a Figma design** — render and compare against the Figma screenshot
- **When the user asks** — "show me how it looks", "render preview", "check the UI"
- **As the final step of a UI task** — before reporting completion to the user or team lead

## Step 1: Run render tests

### Important performance rules
- **NEVER pipe xcodebuild output** (`| grep`, `| tail`) — it buffers stdout and hides results. Always log to file, then grep the file.
- **Use iPhone 17 Pro Max** — it's typically already booted, saving ~60s of simulator cold boot.
- **For re-renders** (no source changes, just re-running): use `test-without-building` to skip compilation entirely.

### First run (builds + tests):
```bash
cd /Users/dmytropogrebniak/projects/beautyn/ios-app/beautyn

xcodebuild test \
  -scheme beautyn-Production \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro Max' \
  -only-testing:beautynTests/HomeViewRenderTests \
  2>&1 > /tmp/render_build.log; \
  echo "EXIT: $?"; \
  grep -E "✅|error:|TEST SUCCEEDED|TEST FAILED|Executed" /tmp/render_build.log
```

### Fast re-render (skip build, ~3-5 seconds):
```bash
xcodebuild test-without-building \
  -scheme beautyn-Production \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro Max' \
  -only-testing:beautynTests/HomeViewRenderTests \
  2>&1 > /tmp/render_build.log; \
  echo "EXIT: $?"; \
  grep -E "✅|error:|TEST SUCCEEDED|TEST FAILED|Executed" /tmp/render_build.log
```

### Pre-build shortcut (build once, test many):
```bash
# Build once:
xcodebuild build-for-testing \
  -scheme beautyn-Production \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro Max' \
  2>&1 > /tmp/render_build.log

# Then render any screen instantly:
xcodebuild test-without-building \
  -scheme beautyn-Production \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro Max' \
  -only-testing:beautynTests/AuthViewRenderTests/testRenderEmailCheck \
  2>&1 > /tmp/render_build.log; \
  grep -E "✅|error:|TEST SUCCEEDED|TEST FAILED" /tmp/render_build.log
```

Adjust `-only-testing:` to target the specific test class (or individual test method) for the screen you changed. Current render test classes:

| Screen | Test class | Output files |
|--------|-----------|-------------|
| Home | `HomeViewRenderTests` | `home_unauthorized.png`, `home_authorized.png` |
| Auth: EmailCheck | `AuthViewRenderTests/testRenderEmailCheck*` | `auth_email_check.png`, `auth_email_check_filled.png` |
| Auth: Login | `AuthViewRenderTests/testRenderLogin*` | `auth_login.png`, `auth_login_filled.png` |
| Auth: ForgotPassword | `AuthViewRenderTests/testRenderForgotPassword` | `auth_forgot_password.png` |
| Auth: SignUp | `AuthViewRenderTests/testRenderSignUp*` | `auth_sign_up.png`, `auth_sign_up_filled.png` |
| Auth: PhoneVerification | `AuthViewRenderTests/testRenderPhoneVerification*` | `auth_phone_verification.png`, `auth_phone_verification_filled.png` |
| Auth: PhoneCode | `AuthViewRenderTests/testRenderPhoneCode*` | `auth_phone_code.png`, `auth_phone_code_partial.png` |

If **TEST FAILED**, read the full log: `cat /tmp/render_build.log | grep "error:"` to see compiler errors, then fix and re-run.

## Step 2: Read the screenshots

Use the Read tool to view each PNG:

```
/tmp/beautyn_previews/home_unauthorized.png
/tmp/beautyn_previews/home_authorized.png
```

These are full-resolution renders at 2x scale. The view height auto-expands to show all content (no vertical clipping). Images from the network appear as beige placeholders.

## Step 3: Verify the render

Reading the PNG is necessary but not sufficient — the whole point of rendering is to catch where the implementation drifts from the design. There are two distinct passes, and they don't substitute for each other: a render-specific pass that only this pipeline can do, and the full design comparison.

### 3a. Render-specific sanity checks (do these first)

These matter because the PNG came out of a test harness, not the live app. `audit-ui` looks at a static image and has no way to know any of this — so catching it here is on you:

- **Clipping / cut-off artifacts.** The renderer auto-expands *height* to fit content, so nothing clips vertically — but horizontal overflow and stroke/shadow clipping still happen. The classic case: a `Circle().stroke(…)` whose line is centered on the frame edge, so its outer half spills outside the laid-out bounds and an enclosing `ScrollView` shaves it (often ~1px on one edge). Scan every border, ring, rounded corner, and row edge for shaved pixels.
- **Placeholder rendering is expected.** Network images render as beige (`Color.App.beige2`) placeholders — that's the harness, not a bug. Don't "fix" it, and don't audit dynamic image *content*; judge only the frame + clip shape.
- **Did the data actually load?** The harness waits ~0.5s for async work. If the screen still shows a loading spinner, an empty state, or stub values, the mock isn't wired right — fix the test/mock, not the view.
- **Auto-height means there's no fold.** The render shows the full intrinsic height with no scrolling, so content that sits below the fold in-app is fully visible here. Judge sticky headers, `.safeAreaInset` bars, and bottom CTAs with that in mind — their position in the PNG isn't where they pin on a real screen.
- **Everything is 2× scale.** Pixel measurements in the PNG are double the point values. Halve them before comparing to Figma's pt units.

### 3b. Full design comparison → hand off to `audit-ui`

For the actual design-fidelity pass — structure, position/sizing, spacing, typography, colors, images, icons, components, effects, states, localization, touch targets, responsiveness, chrome — **invoke the `audit-ui` skill**, giving it the rendered PNG path (from Step 2) and the Figma node.

`audit-ui` is the single source of truth for comparison depth: it walks 15 categories (A–O), reads exact values from `get_design_context`, maps every Figma value to a `Font.App.*` / `Color.App.*` / `CGFloat.Spacing.*` token, applies severity thresholds, and returns a triaged report (Critical / Minor / Nits / Looks correct / Open questions). Deliberately **don't** keep a parallel checklist here — a second copy would only drift from `audit-ui` and rot. Improve the comparison depth by improving `audit-ui`.

If there's **no Figma reference** to compare against, there's nothing to hand off — just confirm via 3a that the render is structurally sane and report what you see.

## Step 4: Fix and re-render

When 3a finds a render artifact or `audit-ui` surfaces a discrepancy:
1. Fix the SwiftUI code
2. Re-run the render test (Step 1)
3. Re-read the PNG (Step 2)
4. Re-verify (Step 3) — re-run the audit on the new PNG so findings reflect the current render

This is the edit → render → verify loop. Keep iterating until the render is clean and the audit comes back with nothing actionable.

## Adding render tests for a new screen

When you build a new screen, add a render test so it's part of the pipeline.

### 1. Create a test file in `beautynTests/`

```swift
import SwiftUI
import XCTest
@testable import beautyn

@MainActor
final class NewScreenRenderTests: XCTestCase {

    func testRenderNewScreen() async throws {
        let view = NewScreenView(
            viewModel: self.makeViewModel()
        )
        try await ViewRenderer.render(view, name: "new_screen")
    }

    private func makeViewModel() -> NewScreenViewModel {
        NewScreenViewModel(
            transition: .init(/* stub all closures */),
            useCase: MockNewScreenUseCase()
        )
    }
}

private final class MockNewScreenUseCase: NewScreenUseCase {
    func execute() async throws -> SomeModel {
        .previewData  // Return realistic mock data
    }
}
```

### 2. Add preview data

Create a static extension on your domain model with realistic Ukrainian-language preview data that covers all visual states of the screen.

### 3. Update the table above

Add the new test class and output files to the table in Step 1 so future runs know what to target.

## How ViewRenderer works (for reference)

`ViewRenderer.render(_:name:)` does this:
1. Wraps the SwiftUI view in a `UIHostingController`
2. Attaches it to a `UIWindow` (triggers `onAppear`, `.task`)
3. Waits 0.5s for async data loading to complete
4. Measures intrinsic content height via `sizeThatFits`
5. Resizes to full height, enables `clipsToBounds`
6. Captures via `UIGraphicsImageRenderer` at 2x scale
7. Saves PNG to `/tmp/beautyn_previews/{name}.png`

The window is retained in memory to prevent `@StateObject` dealloc crashes with Swift Concurrency in Xcode 26.
