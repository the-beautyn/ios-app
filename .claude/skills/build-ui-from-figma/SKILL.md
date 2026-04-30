---
name: build-ui-from-figma
description: "Translate a specific Figma node into SwiftUI in this iOS project with strict 1:1 visual fidelity. Use this skill ONLY when the user provides a Figma source — a figma.com/design/... URL, an explicit reference to a Figma node/file/frame, or an attached Figma screenshot — paired with a request to build, implement, translate, update, or match a SwiftUI screen/view/component from it. Do NOT use this skill for UI work that has no Figma source (general SwiftUI tweaks, refactors, bug fixes, changes driven by user description alone, or generic 'add a screen' requests without a Figma reference). When it does apply, prefer this skill over invoking `figma:figma-implement-design` or `render-preview` standalone — it chains them with project-specific token-mapping and a static code-vs-Figma review loop that catches font-tier and spacing-token mismatches those tools miss."
---

# Build UI from Figma

This is the canonical workflow for translating a Figma node into SwiftUI in this project. Follow the steps in order. Skipping a step — especially Step 5 — is the most common cause of visual-fidelity bugs.

## Why this skill exists

The `figma:figma-implement-design` plugin skill outputs generic React+Tailwind reference code. The `render-preview` skill verifies visual output but cannot catch font-tier or spacing-token mismatches — these slip past the eye in screenshots. This skill bridges them with a project-specific workflow centered on Step 3's token map and Step 5's static code-vs-Figma review loop. Both have caught real bugs (e.g. `PersonalDataView` shipped with `title2Medium` (22pt) when Figma specified 28pt, and `InfoRowView` used `Font.App.headline` (Medium) when Figma was Body Regular — both would have been caught at Step 5 without ever rendering).

## Step 1 — Inventory the design system

Read these before reading the Figma. Without this inventory, mapping Figma styles to project tokens accurately is not possible, and the agent will over-rely on token *names* instead of token *metrics*.

- `App/Shared/DesignSystem/AppTypography.swift` — `Font.App.*` and `CGFloat.Tracking.*`. The file's leading comment is a table mapping every tier to (family, weight, size, lineHeight, tracking). That table is the source of truth — keep it open while building the token map.
- `App/Shared/DesignSystem/AppColors.swift` (or wherever `Color.App` is declared) and `Colors.xcassets`.
- `App/Shared/DesignSystem/AppSpacing.swift` (or wherever `CGFloat.Spacing.*` lives) — note all available rungs (`xxs`, `xs`, `sm`, `md`, `lg`, `xl`, …) and their pt values.
- Existing reusable components — search both `App/Shared/Components/` and `App/Features/<feature>/Presentation/Components/` before assuming you need to build something new. Likely-relevant candidates include `InfoRowView`, `AppButton`, `CachedImage`, `AppNavigationBar`.

## Step 2 — Fetch the Figma node

Call `mcp__figma__get_design_context` with the Figma URL the user shared (or invoke `figma:figma-implement-design` if you also need its scaffolding output). Extract and keep handy:

- The screenshot — you'll need it for the Step 7 visual comparison.
- Every distinct text style: family, weight, size, lineHeight, tracking, color (including opacity).
- Every distinct spacing value (gaps, paddings, frame sizes).
- Every distinct color and corner radius.
- Component descriptions and any Code Connect mappings — they tell you which existing project component the designer intended.

## Step 3 — Build a token map (scratch text, not committed)

Before writing any SwiftUI, draft a mapping table in your working notes. The map is the single artifact that keeps Steps 4 and 5 honest.

| Figma element | Figma raw style | Project token / composition |
|---|---|---|
| Screen title | Aeonik Medium 28/34/+0.33 | `Font.App.title1Medium` + `Tracking.title1` |
| Row label | Aeonik Regular 17/22/0 | `Font.App.body` |
| Row value | Aeonik Regular 15/20/0 | `Font.App.subheadline` |
| Body BG | #efe8d8 | `Color.App.backgroundLight` |
| Section gap | 6pt | `CGFloat.Spacing.xxs + 2` (no exact token; composed) |

Rules for the map:

- **Match by exact size + weight + family + tracking — not by token name.** "Title2" in Figma may not equal `Font.App.title2` in this project; pick by metrics. The most common bug this skill prevents is selecting a token because its name matched, not because its size/weight/tracking matched.
- **If no exact-matching token exists, compose from existing tokens** (e.g. `CGFloat.Spacing.xxs + 2`, `CGFloat.Spacing.sm + CGFloat.Spacing.xxs`). Record both the Figma raw value AND the composed expression in the map. Composition makes the relationship to the design system explicit and reviewable; a bare literal (`6`, `12`) hides that relationship.
- **This project does not extend the design system mid-feature.** Composition is the standard fallback, not a workaround. If a value cannot be composed reasonably from existing tokens, pause and surface it — the design likely needs to align to existing tokens, or the rare case where a new token is genuinely warranted needs a separate decision.
- **Never write a bare literal.** If you find yourself wanting to type `.padding(.top, 6)`, stop and re-derive from tokens.
- **Reuse before recreating.** For every reusable Figma component (row, card, badge, button, avatar), name the matching project component in the map. If one exists, use it. If one doesn't, search again — the surface area is small enough that most things already exist.

## Step 4 — Implement

Write the View / ViewModel / Controller / Coordinator wiring per `AGENTS.md` §1–§17. Apply visual rules per `AGENTS.md` §19. Use only the tokens and compositions recorded in the Step 3 map.

When line-height differs from the SwiftUI default, apply it via the existing `.lineHeight(_:fontSize:)` extension — don't reach for raw `.lineSpacing` math at the call site.

## Step 5 — Code-vs-Figma static review loop (mandatory, before any rendering)

Before invoking any review skill or asking to render, walk the SwiftUI code you just wrote modifier-by-modifier and cross-check each one against the Figma styles from Step 2 and the token map from Step 3. This catches font-tier and spacing-token mismatches without needing a screenshot — they're the most common bugs and the cheapest to fix at this stage.

For every `Text`, `Image`, container, and modifier in the new code, verify:

1. **Font** — family, weight, size, tracking, line-height all match the Figma element. (A 17pt Medium token applied to a 17pt Regular Figma element is a real bug; the size matches but the weight does not.)
2. **Color** — including opacity. `labels/secondary` at 60% black is not the same as a solid mid-gray.
3. **Spacing** — every `.padding`, `spacing:`, `.frame(height:)` traces back to a `CGFloat.Spacing.*` token or a composition recorded in the map.
4. **Corner radius / stroke** — match Figma values; use the design system's radius constants where available.
5. **Alignment** — `alignment:` parameter on stacks and frames matches the Figma layout (top vs. center vs. leading).
6. **Hierarchy** — the heaviest visual element in the rendered code is the heaviest in the Figma. If the Figma title is bigger and bolder than its subtitle, the code's title must be too.
7. **Structure** — same grouping (which elements are nested together inside a VStack/HStack), same order top-to-bottom and leading-to-trailing.

If anything is off, fix it in code and re-walk the checklist. Repeat until every item aligns.

This loop is the failure-mode-prevention point of the skill. Treat it as mandatory — Steps 6 and 7 are downstream verifications, not substitutes.

## Step 6 — `swiftui-pro` review

Invoke the project-local `swiftui-pro` skill on the new files. Address its findings before proceeding to render. This is a code-quality pass (modern API usage, performance, maintainability), separate from the visual-fidelity loop in Step 5.

## Step 7 — Render and visually compare

The user's standing rule is: never run `xcodebuild` or `render-preview` automatically. **Ask first.** Phrase it like: "Want me to build and render a preview of `<ViewName>`?"

After they approve and the preview is rendered (`render-preview` writes PNGs you can read inline), compare each rendered PNG against the Figma screenshot from Step 2 element-by-element using the same checklist as Step 5. Fix and re-render until the comparison is 1:1, or until the remaining differences are explicitly approved by the user.

When the screen has multiple meaningful states (populated vs. empty, authenticated vs. unauthenticated, single item vs. many), render fixtures for each — visual bugs often hide in non-default states.

## Step 8 — Hardcoded-value audit

Before declaring the task done, grep the changes for hardcoded literals. Use ripgrep against the files you modified or created.

Patterns to search:

- `\.font\(\.system` and `Font\.custom\(` — should be zero matches in feature code; everything routes through `Font.App.*`.
- `Color\(red:` and `Color\(\.` and raw hex (`#[0-9a-fA-F]{3,8}`) — should be zero in feature code; routes through `Color.App.*`.
- Bare numeric literals in `.padding(\d`, `spacing: \d`, `width: \d`, `height: \d`, `cornerRadius(\d`, `lineWidth: \d`. Some are legitimate (e.g. icon sizes already established by a parent component's API), but each match must either be a design-system token, a composition documented per `AGENTS.md` §19.2, or have a one-line comment explaining why a literal is appropriate here.

Anything that doesn't pass this audit gets refactored to a token, replaced with a composition, or removed.

## Common failure modes this skill prevents

- **Token-name match, metric mismatch.** Picking `Font.App.title2Medium` because Figma calls it "Title 2" without verifying that the code's `title2Medium` is the same size/weight as the Figma's "Title 2". (Real example: this project's `title2Medium` is 22pt; Figma's "Title 1 Medium" tier is 28pt — close in name, far apart visually.)
- **Wrong weight at right size.** `Font.App.headline` and `Font.App.body` are both 17pt but differ in weight (Medium vs. Regular). Picking the wrong one looks "almost right" until you compare side-by-side.
- **Hardcoded spacing for "just this one place".** A literal `12` in a padding modifier is invisible to refactor tools and quietly drifts away from the design system over time. Composition (`CGFloat.Spacing.sm`) keeps the relationship explicit.
- **Skipping Step 5 because the screenshot will catch it.** Screenshots reliably surface layout breakage and gross color mismatches; they do not reliably surface 1pt size differences, weight differences, or 2pt spacing differences. Step 5 catches what Step 7 cannot.
