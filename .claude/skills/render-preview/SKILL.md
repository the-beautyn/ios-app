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

## Step 3: Compare against Figma (if available)

Fetch the Figma design screenshot:
```
mcp__figma__get_screenshot(fileKey: "jhPfJ6hh8NTS6zc1R1A5kE", nodeId: "...")
```

Compare the render against the Figma screenshot. Also fetch the design context via `get_design_context` to get exact values for spacing, colors, and typography — don't rely only on visual comparison.

### Checklist — go through EVERY item

**Spacing & Padding:**
- Horizontal padding on section headers — do they match Figma's left/right insets?
- Horizontal padding on scrollable rows — do cards/items start at the correct inset from the screen edge?
- Vertical spacing between sections — compare gap sizes
- Internal padding within cards, badges, chips — check all four sides
- Padding inside the header area (top, bottom, between elements)

**Alignment:**
- Are all items in a horizontal row aligned to the same baseline/top? (e.g., category chips with different label lengths should align at the top, not center-vertically)
- Are section headers left-aligned consistently?
- Are card elements (badges, buttons, text) positioned correctly relative to the card?

**Shadows & Effects:**
- Does the design have shadows? If yes, where exactly — top, bottom, all sides?
- Is the shadow direction correct? (e.g., bottom-only vs all-around)
- Do child elements incorrectly inherit shadows from their parent? (e.g., images inside a shadowed container should NOT have their own shadow unless Figma shows one)
- Check blur, opacity, and gradients

**Typography:**
- Font size, weight, line height — compare against Figma's text styles
- Letter spacing / tracking
- Text color — exact hex match

**Colors & Backgrounds:**
- Background colors of sections, cards, badges, chips
- Border/stroke colors if any
- Opacity values

**Components & Content:**
- Are all sections from Figma present in the render?
- Correct order of sections?
- Are badges, icons, overlays present where Figma shows them?

**Shape & Clipping:**
- Corner radius on cards, images, badges, chips
- Are images clipped to their container shape?
- Circle vs rounded-rect — match Figma exactly

## Step 4: Fix and re-render

If you spot discrepancies:
1. Fix the SwiftUI code
2. Re-run the render test (Step 1)
3. Re-read the PNG (Step 2)
4. Repeat until it matches the design

This is the edit → render → verify loop. Keep iterating until satisfied.

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
