---
name: audit-ui
description: "Systematically compare a rendered iOS screenshot against a Figma design. Walks 15 categories of checks (structure, position, spacing, typography, colors, images, icons, components, effects, states, content, responsiveness, etc.) using this project's design tokens (Font.App.*, Color.App.*, CGFloat.Spacing.*), then produces a triaged report. Use when the user says /audit-ui, 'compare to figma', 'audit ui', 'find differences', 'does this match figma', 'check the design', 'verify against figma', 'find discrepancies', or pastes a simulator screenshot and a Figma link."
---

# Audit UI vs Figma

Systematically compare a rendered iOS screenshot against the Figma design and produce a triaged report of discrepancies. Tuned to this project: every check references the in-house design tokens, so findings double as direct code-level fixes (e.g. "use `Font.App.footnote`, not `.subheadline`").

The skill assumes a screenshot already exists. If it doesn't, ask the user to run `/render-preview` first or paste a simulator screenshot — never proceed without one. This skill never invokes builds or renders on its own.

## When to use this

- After running `/render-preview` and you want to verify against Figma
- When the user pastes a simulator screenshot and provides a Figma link
- Before declaring a UI task complete
- When the user asks: "compare with figma", "audit ui", "are these aligned", "find differences", "does this match"

## Inputs needed

1. **Screenshot** — PNG path on disk, pasted image, or a Read tool result
2. **Figma URL** — must contain `fileKey` and `nodeId`. Extract them from URLs like `https://www.figma.com/design/<fileKey>/...?node-id=<int>-<int>` and convert `-` to `:` in nodeId.

If either is missing, STOP and ask the user. Don't guess.

## Step 1: Fetch the Figma reference

Get BOTH the rendered design and the underlying spec — the spec lets you read exact values instead of eyeballing pixels.

```
mcp__figma__get_screenshot(fileKey: <key>, nodeId: <id>)
mcp__figma__get_design_context(fileKey: <key>, nodeId: <id>)
```

The design context returns React+Tailwind code that mirrors the Figma layer tree. Read it for exact `text-[Npx]`, `leading-[Npx]`, `padding-[Npx]`, color hex values, corner radii, etc. Don't trust the React structure — translate the values.

## Step 2: Walk the checklist

Walk every category. For each item state PASS / MISMATCH / N/A and one concrete note. Skipping categories misses bugs.

### A. Structure & Layout

- Every top-level Figma element appears in the screenshot (and no extras)
- Reading order matches (top → bottom, leading → trailing)
- Z-order correct (overlays above content, sticky above scrollable)
- Status bar visibility matches design
- Navigation bar visibility matches (usually hidden on this app's screens)
- Tab bar visibility matches — `hidesBottomBarWhenPushed` on pushed screens
- Safe area / full-bleed handling — cover photos with `.ignoresSafeArea(.top)`, action bars via `.safeAreaInset(.bottom)`
- Sticky elements pinned, scrollable regions scroll

### B. Position & Sizing

Eyeball-compare each visible element:
- Horizontal position (left edge / right edge / centered)
- Vertical position (top edge / bottom edge)
- Width vs Figma
- Height vs Figma
- Aspect ratio (images, cards)

Off by > ~8pt = mismatch. Off by < ~4pt = nit.

### C. Spacing & Padding

- Container padding (cards, badges, buttons, inputs)
- Gap between siblings in stacks
- Section header spacing above/below
- Edge insets from the screen edge
- Internal alignment (icon ↔ text, image ↔ label)

Map Figma `px` values to `CGFloat.Spacing.*`:
- `2` → `.xxs` · `4` → `.xs` · `8` → `.sm` · `16` → `.md`
- `24` → `.lg` · `32` → `.xl` · `48` → `.xxl` · `64` → `.xxxl`

### D. Typography

For every text element check:
- Font family — must be `AeonikPro.*` (none of the `Font.system` shortcuts)
- Size + line height + tracking
- Color (from `Color.App.*`)
- Alignment + truncation behavior (`.lineLimit`, ellipsis)

Figma → project token map:
- `22pt Medium · lh 26 · tr 0.32` → `.App.title2Medium` + `CGFloat.Tracking.title2`
- `17pt Medium · lh 22` → `.App.headline`
- `17pt Regular · lh 22 · tr -0.41` → `.App.body` + `CGFloat.Tracking.body`
- `16pt Regular · lh 22 · tr -0.32` → `.App.callout` + `CGFloat.Tracking.callout`
- `15pt Regular · lh 20 · tr -0.24` → `.App.subheadline` + `CGFloat.Tracking.subheadline`
- `13pt Regular · lh 18` → `.App.footnote`
- `12pt Regular · lh 16` → `.App.caption1`
- `11pt Regular · lh 13 · tr 0.06` → `.App.caption2` + `CGFloat.Tracking.caption2`

If a Figma text style has no token match, flag it — don't invent a custom font size.

### E. Colors

For each colored surface (background, foreground, border, accent, scrim):
- Foreground / text colors
- Background colors (panels, cards, badges, buttons)
- Border / stroke colors
- Accent colors (active, error, success)
- Opacity values

Map Figma hex to `Color.App.*` (see `AppColors.swift`). If the Figma color isn't in the palette, flag it — don't hardcode hex in the view.

Common ones in this project:
- `#5A483A` → `.App.brown1` (primary)
- `#EFE8D8` → `.App.beige2` (background)
- `#D0DEAE` → `.App.sage`
- `#F7DB58` → `.App.sun` (rating star)
- `#FFFFFF` → `.App.white`
- `#404040` → `.App.text`
- `#898887` → `.App.gray2`
- `#575553` → `.App.gray`
- `rgba(166,183,201,0.2)` → `.App.blueTransparency` (hairline dividers)

### F. Images

- Asset identity for static images (logos, illustrations, decorative)
- Aspect ratio preserved
- Clip shape — `Circle`, `RoundedRectangle(cornerRadius:)`, custom `UnevenRoundedRectangle`
- Content mode (`.fill` / `.fit`)
- Dark overlay or scrim, if present
- Placeholder when image is loading/missing — must be graceful (`Color.App.beige2` is the project default)

For DYNAMIC images (user avatars, salon photos, service thumbnails), verify only the FRAME + clip shape — state "skipped — dynamic content" for the asset itself.

### G. Icons (separate from buttons)

- SF Symbol name correct (`chevron.left`, `heart` vs `heart.fill`, `square.and.arrow.up`)
- Weight matches Figma stroke weight (`.regular` / `.medium` / `.semibold`)
- Size in pt
- Color from `Color.App.*`
- Filled vs outlined variant

### H. Components

For each component instance check that the right design-system view is used and configured correctly:
- `AppButton` — variant (`.primary` / `.secondary(outlined:)`), size (`.big` / `.small`), `icon`, `isLoading`, `isDisabled`
- `AppTextField` / `SalonSearchField` — placeholder, icon, padding
- `TabSelectorView` — tabs array, selectedIndex binding
- `RatingBadgeView`, `TagBadgeView`, `FavoriteButtonView`, `CachedImage`
- `GlassCircleButton` — alone or merged via `.glassEffect(in: Capsule())` for grouped buttons
- `SalonStickyActionBar` — count + CTA pinned via `.safeAreaInset(.bottom)`

If a UI matches Figma visually but rebuilds the component inline (raw `Button`, raw `TextField`), flag it as "Component identity" mismatch — same visual, worse maintainability.

### I. Effects & Decoration

- Corner radii (`.continuous` style preferred for app surfaces)
- Border widths + colors
- Shadows: x/y offset, blur, color, opacity
- Blur / material effects (`.ultraThinMaterial`, iOS 26 `.glassEffect(.regular.interactive(), in: …)`)
- Gradients
- Dividers / hairlines (use `Color.App.blueTransparency`)

### J. States

The screenshot only shows one state. If the screen has more:
- Empty state — correct message, illustration, action
- Loading state — `.loader(isLoading:)` modifier visible
- Error state — `.handleError`/alert appearance
- Selected vs unselected — tabs, list rows
- Authenticated vs anonymous — different content (greeting, favorites)

### K. Content & Localization

- Text content matches Figma (placeholder, labels, body)
- Strings come from `Localization.*` — no hardcoded literal text in views
- Correct language for current locale (uk + en parity)
- Long strings don't overflow / clip awkwardly — uk is ~15-25% longer than en
- Numbers, dates, currency formatted per locale

### L. Component identity

Verify the screenshot uses the right design-system tokens AND types, not inline equivalents. Look for these red flags in the codebase that backs the screenshot:
- Raw `Color(hex:)` or `Color.gray` — should be `Color.App.*`
- Raw `Font.system(size:)` — should be `Font.App.*`
- Hardcoded `16`, `8`, `24` — should be `CGFloat.Spacing.*`
- Raw `Button` for CTAs — should be `AppButton`
- Inline glass blur — should be `GlassCircleButton` or `.glassEffect()`

### M. Touch targets & accessibility hints

- Interactive elements have a minimum 44pt hit area (use `.frame(width: 44, height: 44)` even when the visual is smaller — see `GlassCircleButton`)
- Disabled states are visually distinct (faded, no shadow, no press feedback)
- Color contrast is reasonable on photographic backgrounds (the glass header buttons are the case study)

### N. Responsiveness

- No hardcoded `UIScreen.main.bounds.*` — deprecated in iOS 26; use `GeometryReader` or `containerRelativeFrame`
- Dimensions scale with viewport where appropriate (cover height ≈ proportion of screen, not a constant)
- Constants clamped reasonably (`min(max, ratio * viewport)`) so SE-class and iPad-class devices both look sensible
- Layout survives Dynamic Type (or is intentionally pinned via fixed sizes)

### O. Environment / chrome

- Status bar style matches design (light text over dark cover; default elsewhere)
- Glass header overlay sits visually above the cover photo and stays legible across light + dark imagery
- Bottom safe area inset isn't swallowed by `.ignoresSafeArea(.bottom)` on the wrong layer

## Step 3: Report

Output one consolidated report. Use these headers; group findings by severity, not by category.

```
## UI Audit: <screen name>

### Critical (breaks design intent, visible to user)
1. <Issue> — at <location>. Figma: <X>. Screenshot: <Y>. Fix: <concrete action with project token>.
…

### Minor (polish, off-by-a-few-pt or one-step-removed token)
1. …

### Nits (would be nicer, no user-visible impact)
1. …

### Looks correct ✅
- <category name>
- <category name>
…

### Open questions
- <If an element exists in Figma but not the screenshot — ask whether it's intentionally scoped out (e.g. "Top 10 Masters" tag when no data)>
- <If an element exists in the screenshot but not Figma — ask whether it's intentional or stale>
```

Don't enumerate everything that's fine — just list the categories that pass. The user wants a triaged action list, not an audit log.

## Tips

- **Read Figma spec, don't eyeball.** `get_design_context` gives exact `text-[Npx]`, `bg-[hex]`, `rounded-[Npx]` values. Use them. Only fall back to visual estimation when the design context isn't available.
- **Skip dynamic content explicitly.** For user avatars, salon photos, service thumbnails, state "skipped — dynamic". Audit the frame, not the asset.
- **Cite the project token, not the raw value.** "Use `.App.subheadline`" beats "Use 15pt Aeonik Regular".
- **Group what's correct.** Listing every passing item drowns the actionable findings.
- **Flag scope decisions.** If Figma has a tag/section that's intentionally absent (e.g. "Top 10 Masters" with no data), confirm with the user — don't report it as a missing element.
- **Compare images side by side.** If you can, read both the Figma screenshot and the implementation screenshot in the same response — gives you a visual diff sense before walking the checklist.
